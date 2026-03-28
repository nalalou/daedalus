#!/usr/bin/env bash
set -euo pipefail

# ── test-agent.sh ───────────────────────────────────────────────────────────
# Background agent that finds untested source files, generates integration
# tests via Claude, validates them, and commits to chore/auto-tests.
#
# Usage:
#   ./scripts/test-agent.sh start [--max-iterations N] [--interval M]
#   ./scripts/test-agent.sh stop
#   ./scripts/test-agent.sh status
#   ./scripts/test-agent.sh --dry-run
#
# The agent runs in a tmux session. Attach with: tmux attach -t test-agent
# Review results: cat .agent/report.md
# Review tests: git log chore/auto-tests
#
# Placeholders filled in by the skill at install time:
#   %%PKG_MANAGER%%          — package manager binary (e.g. pnpm, npm, yarn)
#   %%COVERAGE_CMD%%         — full coverage command including reportsDirectory flag
#   %%COVERAGE_CMD_FILE%%    — coverage command for a single test file including reportsDirectory flag
#   %%TEST_CMD%%             — test runner command (e.g. pnpm vitest run, npm test --)
#   %%INSTALL_CMD%%          — install command (e.g. pnpm install --frozen-lockfile)
#   %%CLASSIFY_FUNCTION%%    — classify_file() body mapping source paths to categories
#   %%EXEMPLAR_FUNCTION%%    — get_exemplar() body mapping categories to example test paths
#   %%TEST_PATH_FUNCTION%%   — get_test_path() body mapping source+category to output test path
#   %%PATTERN_NAME_FUNCTION%% — get_pattern_name() body mapping categories to pattern descriptions
# ────────────────────────────────────────────────────────────────────────────

# ── Config ──────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKTREE_PATH="$REPO_ROOT/.worktrees/test-agent"
AGENT_DIR="$REPO_ROOT/.agent"
PID_FILE="$AGENT_DIR/pid"
REPORT_FILE="$AGENT_DIR/report.md"
SKIP_LIST="$REPO_ROOT/scripts/test-agent-skip.txt"
PROMPT_TEMPLATE="$REPO_ROOT/scripts/test-agent-prompt.md"
BRANCH="chore/auto-tests"

MAX_ITERATIONS=10
INTERVAL=600  # seconds (10 minutes)
DRY_RUN=false

# ── Argument parsing ───────────────────────────────────────────────────────
CMD="${1:-}"
shift 2>/dev/null || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --interval)       INTERVAL=$(( $2 * 60 )); shift 2 ;;
    --dry-run)        DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Helpers ────────────────────────────────────────────────────────────────
# Cross-platform in-place sed (macOS uses -i '', GNU uses -i)
sedi() {
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "$@"
  else
    sedi "$@"
  fi
}

check_deps() {
  local required_cmds=("jq" "bc" "%%PKG_MANAGER%%" "claude")
  # tmux only needed for detached start, not dry-run
  if [[ "$DRY_RUN" != true ]]; then
    required_cmds+=("tmux")
  fi
  local missing=()
  for cmd in "${required_cmds[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing required commands: ${missing[*]}"
    exit 1
  fi
  if ! command -v gloss >/dev/null 2>&1; then
    echo "Note: 'gloss' not found — output will be plain text. Install for a prettier TUI."
  fi
}

check_no_existing_instance() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo "ERROR: Agent already running (PID $pid). Run '$0 stop' first."
      exit 1
    else
      echo "Stale PID file found. Cleaning up."
      rm -f "$PID_FILE"
    fi
  fi
}

ensure_worktree() {
  if [[ ! -d "$WORKTREE_PATH" ]]; then
    echo "Creating worktree at $WORKTREE_PATH on branch $BRANCH..."
    # Create branch from main if it doesn't exist
    if ! git -C "$REPO_ROOT" rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
      git -C "$REPO_ROOT" branch "$BRANCH" main
    fi
    git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$BRANCH"
    # Install dependencies in worktree
    (cd "$WORKTREE_PATH" && %%INSTALL_CMD%%)
  fi
}

rebase_onto_main() {
  cd "$WORKTREE_PATH"
  git fetch origin main 2>/dev/null || true
  if ! git rebase origin/main 2>/dev/null; then
    echo "WARN: Rebase conflict — aborting rebase and resetting to origin/main"
    git rebase --abort 2>/dev/null || true
    git reset --hard origin/main
    update_report "## Warning\nRebase conflict at $(date -Iseconds) — reset to origin/main\n"
  fi
}

# ── Coverage & file selection ──────────────────────────────────────────────
get_uncovered_files() {
  cd "$WORKTREE_PATH"
  %%COVERAGE_CMD%% >/dev/null 2>&1 || true

  local summary="$AGENT_DIR/coverage/coverage-summary.json"
  if [[ ! -f "$summary" ]]; then
    echo "ERROR: Coverage summary not generated" >&2
    return 1
  fi

  # Extract uncovered files, sorted by branch count descending (most complex first)
  jq -r '
    to_entries[]
    | select(.key != "total")
    | select(.value.lines.pct < 5)
    | {key: .key, branches: (.value.branches.total // 0), lines: (.value.lines.total // 0)}
  ' "$summary" | jq -rs '
    sort_by(-.branches, -.lines)
    | .[].key
  ' | while IFS= read -r filepath; do
    local rel="${filepath#$WORKTREE_PATH/}"
    if ! is_skipped "$rel"; then
      echo "$rel"
    fi
  done
}

is_skipped() {
  local file="$1"
  if [[ ! -f "$SKIP_LIST" ]]; then
    return 1
  fi
  while IFS= read -r pattern; do
    [[ -z "$pattern" || "$pattern" == \#* ]] && continue
    # shellcheck disable=SC2254
    case "$file" in
      $pattern) return 0 ;;
    esac
  done < "$SKIP_LIST"
  return 1
}

%%CLASSIFY_FUNCTION%%

%%EXEMPLAR_FUNCTION%%

%%TEST_PATH_FUNCTION%%

%%PATTERN_NAME_FUNCTION%%

# ── Claude invocation & quality gates ──────────────────────────────────────
# Global: captures the last gate failure reason for retry feedback
LAST_GATE_FAILURE=""
# Runtime skip list: files that failed all attempts this session
FAILED_FILES=""

generate_test() {
  local source_path="$1"
  local test_path="$2"
  local category="$3"
  local feedback="${4:-}"  # Optional: failure reason from previous attempt

  local exemplar_path
  exemplar_path=$(get_exemplar "$category")
  local pattern_name
  pattern_name=$(get_pattern_name "$category")

  # Build the agent prompt from template
  local prompt
  prompt=$(cat "$PROMPT_TEMPLATE")
  prompt="${prompt//%%PATTERN%%/$pattern_name}"
  prompt="${prompt//%%SOURCE_PATH%%/$source_path}"
  prompt="${prompt//%%SOURCE_CONTENT%%/$(cat "$WORKTREE_PATH/$source_path")}"
  prompt="${prompt//%%TEST_PATH%%/$test_path}"

  # Build exemplar section
  local exemplar_section=""
  if [[ -n "$exemplar_path" && -f "$WORKTREE_PATH/$exemplar_path" ]]; then
    exemplar_section="EXEMPLAR TEST (follow this style exactly):
Path: $exemplar_path

$(cat "$WORKTREE_PATH/$exemplar_path")"
  fi
  prompt="${prompt//%%EXEMPLAR_SECTION%%/$exemplar_section}"

  # Append feedback from previous failed attempt
  if [[ -n "$feedback" ]]; then
    prompt="$prompt

IMPORTANT — YOUR PREVIOUS ATTEMPT WAS REJECTED:
$feedback

Fix these issues in your new attempt. Do not repeat the same mistakes."
  fi

  # Agent instructions: read files, write test, run it, iterate
  prompt="$prompt

YOU ARE AN AGENT with access to Read, Write, and Bash tools.

Your workflow:
1. Read the source file to understand its behavior and dependencies
2. Read the exemplar test (if provided) to match the project's test style
3. Read any imports/types you need to understand (use Read on referenced files)
4. Write the test file to $test_path
5. Run: %%PKG_MANAGER%% vitest run $test_path (or equivalent test command)
6. If the test fails, read the error output, fix the test, and retry
7. Once the test passes, you are done

Do NOT commit anything. Do NOT run git commands. Just write a passing test file."

  cd "$WORKTREE_PATH"
  mkdir -p "$(dirname "$WORKTREE_PATH/$test_path")"

  echo "$prompt" | claude \
    --model sonnet \
    --max-budget-usd 1.00 \
    --no-session-persistence \
    --allowedTools "Read,Write,Bash(%%PKG_MANAGER%%:*)" \
    --permission-mode bypassPermissions \
    -p \
    2>/dev/null || {
    echo "ERROR: Claude agent failed for $source_path"
    return 1
  }

  # Verify the test file was written
  if [[ ! -f "$WORKTREE_PATH/$test_path" ]]; then
    echo "ERROR: Agent did not write test file at $test_path"
    return 1
  fi
}

validate_test() {
  local source_path="$1"
  local test_path="$2"

  cd "$WORKTREE_PATH"

  # Gate 0: Static assertion lint — reject weak tests before running anything
  echo "::status id=phase running Gate 0: assertion quality..."
  local gate0_result
  gate0_result=$(validate_assertions "$WORKTREE_PATH/$test_path" 2>&1)
  if [[ $? -ne 0 ]]; then
    echo "$gate0_result"
    LAST_GATE_FAILURE="$gate0_result"
    return 1
  fi

  # Gate 1: Test passes in isolation
  echo "::status id=phase running Gate 1: test passes..."
  if ! %%TEST_CMD%% "$test_path" 2>&1; then
    LAST_GATE_FAILURE="Gate 1 failed — test does not pass in isolation. Check for import errors, missing mocks, or incorrect test setup."
    echo "::err $LAST_GATE_FAILURE"
    return 1
  fi

  # Gate 2: Adds ≥5% line coverage
  echo "::status id=phase running Gate 2: coverage check..."
  %%COVERAGE_CMD_FILE%% >/dev/null 2>&1 || true

  local new_summary="$AGENT_DIR/coverage-check/coverage-summary.json"
  if [[ -f "$new_summary" ]]; then
    local abs_source="$WORKTREE_PATH/$source_path"
    local line_pct
    line_pct=$(jq -r --arg f "$abs_source" '.[$f].lines.pct // 0' "$new_summary")
    if (( $(echo "$line_pct < 5" | bc -l) )); then
      LAST_GATE_FAILURE="Gate 2 failed — only ${line_pct}% line coverage (need ≥5%). The test must actually import and exercise the source code's functions, not just mock everything."
      echo "::err $LAST_GATE_FAILURE"
      return 1
    fi
  fi

  # Gate 3: Mutation check — does the test catch a real bug?
  echo "::status id=phase running Gate 3: mutation check..."
  local gate3_result
  gate3_result=$(mutation_check "$source_path" "$test_path" 2>&1)
  if [[ $? -ne 0 ]]; then
    echo "$gate3_result"
    LAST_GATE_FAILURE="$gate3_result"
    return 1
  fi

  # Gate 4: Full suite still passes
  echo "::status id=phase running Gate 4: full suite..."
  if ! %%TEST_CMD%% 2>&1; then
    LAST_GATE_FAILURE="Gate 4 failed — full suite broken after adding this test. The test likely pollutes shared state (MSW handlers, global mocks)."
    echo "::err $LAST_GATE_FAILURE"
    return 1
  fi

  return 0
}

# ── Gate helpers ───────────────────────────────────────────────────────────
validate_assertions() {
  local test_file="$1"

  # Count test blocks
  local test_count
  test_count=$(grep -cE '^\s*(it|test)\(' "$test_file" 2>/dev/null || echo 0)
  if [[ "$test_count" -eq 0 ]]; then
    echo "::err Gate 0 failed — no test blocks found"
    return 1
  fi

  # Count specific assertions (not just toBeDefined/toBeTruthy/toBeNull)
  local specific_count
  specific_count=$(grep -cE '\.(toBe\(|toEqual\(|toContain\(|toMatch\(|toHaveBeenCalledWith\(|toHaveLength\(|toThrow\(|toHaveBeenCalled\b|rejects\.|toStrictEqual\(|toMatchObject\(|toHaveProperty\(|status\)\.toBe\()' "$test_file" 2>/dev/null || echo 0)

  if [[ "$specific_count" -lt "$test_count" ]]; then
    echo "::err Gate 0 failed — only $specific_count specific assertions for $test_count tests (need at least 1 per test)"
    return 1
  fi

  # Require at least one error-path test
  if ! grep -qEi '(error|fail|reject|40[0-9]|500|invalid|missing|unauthorized|throw|broken)' "$test_file" 2>/dev/null; then
    echo "::err Gate 0 failed — no error path test found"
    return 1
  fi

  return 0
}

mutation_check() {
  local source_path="$1"
  local test_path="$2"
  local abs_source="$WORKTREE_PATH/$source_path"

  # Find a covered line with a conditional to mutate
  local target_line
  target_line=$(grep -nE '(if \(|return |=== |!== |> |< |\? )' "$abs_source" 2>/dev/null | head -1 | cut -d: -f1)

  if [[ -z "$target_line" ]]; then
    # No conditional found — skip mutation check (don't block on simple files)
    return 0
  fi

  # Read the original line
  local original_line
  original_line=$(sed -n "${target_line}p" "$abs_source")

  # Apply one mutation: negate the first condition/operator we find
  local mutated_line="$original_line"
  if echo "$original_line" | grep -qE '=== '; then
    mutated_line=$(echo "$original_line" | sed -E 's/=== /!== /')
  elif echo "$original_line" | grep -qE '!== '; then
    mutated_line=$(echo "$original_line" | sed -E 's/!== /=== /')
  elif echo "$original_line" | grep -qE 'if \('; then
    mutated_line=$(echo "$original_line" | sed -E 's/if \(/if (!/')
    # Close the extra paren
    mutated_line=$(echo "$mutated_line" | sed -E 's/\) \{/) {/' | sed -E 's/if \(\!/if (!/' )
  elif echo "$original_line" | grep -qE 'return true'; then
    mutated_line=$(echo "$original_line" | sed -E 's/return true/return false/')
  elif echo "$original_line" | grep -qE 'return false'; then
    mutated_line=$(echo "$original_line" | sed -E 's/return false/return true/')
  elif echo "$original_line" | grep -qE 'return '; then
    mutated_line=$(echo "$original_line" | sed -E 's/return .*/return null;/')
  else
    # Can't figure out how to mutate — skip
    return 0
  fi

  # Skip if mutation didn't change anything
  if [[ "$mutated_line" == "$original_line" ]]; then
    return 0
  fi

  # Apply the mutation
  cp "$abs_source" "$abs_source.bak"
  sedi "${target_line}s/.*/$mutated_line/" "$abs_source"

  # Run the test — it SHOULD fail
  local test_passed=false
  if %%TEST_CMD%% "$test_path" >/dev/null 2>&1; then
    test_passed=true
  fi

  # Restore original source
  mv "$abs_source.bak" "$abs_source"

  if [[ "$test_passed" == true ]]; then
    echo "::err Gate 3 failed — test passes even with mutated source (line $target_line)"
    return 1
  fi

  return 0
}

# ── Reporting ──────────────────────────────────────────────────────────────
init_report() {
  cat > "$REPORT_FILE" <<EOF
# Test Agent Report
Last run: $(date -Iseconds) | Iteration: 0/$MAX_ITERATIONS

## Tests written (committed)

## Failed attempts

## Skipped (requires hook extraction)

## Potential issues found

EOF

  # Log skipped files
  if [[ -f "$SKIP_LIST" ]]; then
    while IFS= read -r pattern; do
      [[ -z "$pattern" || "$pattern" == \#* ]] && continue
      cd "$WORKTREE_PATH"
      local matches
      matches=$(find src -path "$pattern" 2>/dev/null | head -5)
      if [[ -n "$matches" ]]; then
        while IFS= read -r match; do
          sedi "/## Skipped/a\\
- $match" "$REPORT_FILE"
        done <<< "$matches"
      fi
    done < "$SKIP_LIST"
  fi
}

update_report() {
  local text="$1"
  echo -e "$text" >> "$REPORT_FILE"
}

update_report_header() {
  local iteration="$1"
  sedi "1,2s/Last run:.*/Last run: $(date -Iseconds) | Iteration: $iteration\/$MAX_ITERATIONS/" "$REPORT_FILE"
}

# ── Main loop ──────────────────────────────────────────────────────────────
run_one_iteration() {
  local iteration="$1"
  cd "$WORKTREE_PATH"

  update_report_header "$iteration"

  echo "::status id=phase running Coverage analysis..."
  local uncovered
  uncovered=$(get_uncovered_files) || { echo "::warn Coverage analysis failed, skipping iteration"; return; }

  if [[ -z "$uncovered" ]]; then
    echo "::ok No uncovered files remaining"
    update_report "\n**No uncovered files remaining as of iteration $iteration.**"
    return
  fi

  # Pick the first uncovered file not already failed this session
  local source_path=""
  while IFS= read -r candidate; do
    if [[ -z "$candidate" ]]; then continue; fi
    if ! echo "$FAILED_FILES" | grep -qF "$candidate"; then
      source_path="$candidate"
      break
    fi
  done <<< "$uncovered"

  if [[ -z "$source_path" ]]; then
    echo "::ok All uncovered files already attempted"
    return
  fi

  local source_name
  source_name=$(basename "$source_path")

  local category
  category=$(classify_file "$source_path")
  local test_path
  test_path=$(get_test_path "$source_path" "$category")

  if [[ -f "$WORKTREE_PATH/$test_path" ]]; then
    echo "::info $source_name already has tests, skipping"
    return
  fi

  echo "::status id=file running $source_name ($category)"

  # Try up to 3 times: initial attempt + 2 retries with feedback
  local max_attempts=3
  local attempt=0
  local feedback=""
  local success=false

  while [[ $attempt -lt $max_attempts ]]; do
    attempt=$((attempt + 1))
    LAST_GATE_FAILURE=""

    if [[ $attempt -gt 1 ]]; then
      echo "::info Retry $((attempt - 1))/2 for $source_name"
    fi

    echo "::status id=phase running Generating test via Claude (attempt $attempt)..."

    if ! generate_test "$source_path" "$test_path" "$category" "$feedback"; then
      echo "::err $source_name — Claude invocation failed (attempt $attempt)"
      feedback="Claude invocation failed. Try a simpler approach."
      continue
    fi

    if validate_test "$source_path" "$test_path"; then
      success=true
      break
    else
      rm -f "$WORKTREE_PATH/$test_path"
      feedback="$LAST_GATE_FAILURE"
      echo "::warn $source_name — attempt $attempt failed, will retry with feedback"
    fi
  done

  if [[ "$success" == true ]]; then
    cd "$WORKTREE_PATH"
    git add "$test_path"
    git commit -m "test: add integration tests for $source_path

Auto-generated by test-agent (iteration $iteration, attempt $attempt)"

    local coverage_pct
    coverage_pct=$(jq -r --arg f "$WORKTREE_PATH/$source_path" '.[$f].lines.pct // "?"' "$AGENT_DIR/coverage-check/coverage-summary.json" 2>/dev/null || echo "?")
    echo "::ok $source_name — ${coverage_pct}% coverage (attempt $attempt)"
    sedi "/## Tests written/a\\
- $source_path → $test_path (+${coverage_pct}% coverage, attempt $attempt)" "$REPORT_FILE"
    echo "::status id=file done $source_name"
  else
    echo "::err $source_name — failed all $max_attempts attempts"
    FAILED_FILES="$FAILED_FILES
$source_path"
    sedi "/## Failed attempts/a\\
- $source_path — failed all $max_attempts attempts (iteration $iteration): $LAST_GATE_FAILURE" "$REPORT_FILE"
    echo "::status id=file error $source_name"
  fi
}

run_dry() {
  echo "DRY RUN — would test these files (in order):"
  echo ""
  ensure_worktree
  local uncovered
  uncovered=$(get_uncovered_files)
  if [[ -z "$uncovered" ]]; then
    echo "  No uncovered files found!"
    return
  fi
  local i=0
  while IFS= read -r file; do
    i=$((i + 1))
    local cat
    cat=$(classify_file "$file")
    local tp
    tp=$(get_test_path "$file" "$cat")
    echo "  $i. $file → $tp ($cat)"
    [[ $i -ge $MAX_ITERATIONS ]] && break
  done <<< "$uncovered"
  local max_cost=$(echo "$MAX_ITERATIONS * 3 * 1.00" | bc)
  echo ""
  echo "  ⚠ Estimated max cost: $MAX_ITERATIONS iterations × 3 attempts × \$1.00 = \$${max_cost}"
}

# ── Subcommands ────────────────────────────────────────────────────────────
cmd_start() {
  check_deps
  check_no_existing_instance
  ensure_worktree
  mkdir -p "$AGENT_DIR"
  if [[ "$DRY_RUN" == true ]]; then
    run_dry
    return
  fi
  local max_cost=$(echo "$MAX_ITERATIONS * 3 * 1.00" | bc)
  echo "⚠ Cost warning: up to $MAX_ITERATIONS iterations × 3 attempts × \$1.00 = \$${max_cost} max Claude API usage"
  echo "Starting test agent (max=$MAX_ITERATIONS, interval=${INTERVAL}s)..."
  # Pipe through gloss watch if available, otherwise raw output
  if command -v gloss >/dev/null 2>&1; then
    tmux new-session -d -s test-agent "$0 _loop --max-iterations $MAX_ITERATIONS --interval $((INTERVAL / 60)) 2>&1 | gloss watch"
  else
    tmux new-session -d -s test-agent "$0 _loop --max-iterations $MAX_ITERATIONS --interval $((INTERVAL / 60))"
  fi
  echo "Agent running in tmux session 'test-agent'. Attach with: tmux attach -t test-agent"
}

cmd_stop() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      echo "Stopping test agent (PID $pid)..."
      kill "$pid"
      rm -f "$PID_FILE"
      echo "Stopped."
    else
      echo "PID $pid not running. Cleaning up stale PID file."
      rm -f "$PID_FILE"
    fi
  else
    echo "No PID file found. Agent may not be running."
  fi
}

cmd_status() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Agent is running (PID $(cat "$PID_FILE"))"
    if [[ -f "$REPORT_FILE" ]]; then
      echo ""
      head -5 "$REPORT_FILE"
    fi
  else
    echo "Agent is not running."
  fi
}

cmd_loop() {
  mkdir -p "$AGENT_DIR"
  echo $$ > "$PID_FILE"
  trap 'echo "::status id=agent done Stopped"; rm -f "$PID_FILE"; exit 0' INT TERM

  echo "⚠ WARNING: This agent makes Claude API calls in a loop. Each iteration can use up to 3 invocations (\$1.00 each). Monitor usage." >&2

  init_report

  echo "::divider test-agent"
  echo "::status id=agent running Test Agent"
  echo "::kv id=stats Written=0 | Failed=0 | Skipped=0"
  echo "::bar id=progress 0 Progress"

  local iteration=0
  local written=0
  local failed=0
  while [[ $iteration -lt $MAX_ITERATIONS ]]; do
    iteration=$((iteration + 1))
    local pct=$(( iteration * 100 / MAX_ITERATIONS ))
    echo "::bar id=progress $pct Iteration $iteration/$MAX_ITERATIONS"
    echo "::status id=phase running Coverage analysis..."

    rebase_onto_main
    run_one_iteration "$iteration"

    # Read back result from last iteration
    if grep -q "iteration $iteration)\$" "$REPORT_FILE" 2>/dev/null; then
      if sed -n '/## Tests written/,/## Failed/p' "$REPORT_FILE" | grep -q "iteration $iteration"; then
        written=$((written + 1))
      else
        failed=$((failed + 1))
      fi
    fi
    echo "::kv id=stats Written=$written | Failed=$failed"

    if [[ $iteration -lt $MAX_ITERATIONS ]]; then
      echo "::status id=phase running Sleeping ${INTERVAL}s..."
      sleep "$INTERVAL"
    fi
  done

  echo "::bar id=progress 100 Complete"
  echo "::status id=agent done Test Agent — $written tests written"
  echo "::status id=phase done All iterations complete"
  rm -f "$PID_FILE"
}

# ── Dispatch ───────────────────────────────────────────────────────────────
case "$CMD" in
  start)   cmd_start ;;
  stop)    cmd_stop ;;
  status)  cmd_status ;;
  _loop)   cmd_loop ;;
  --dry-run) DRY_RUN=true; cmd_start ;;
  "")      echo "Usage: $0 {start|stop|status|--dry-run} [--max-iterations N] [--interval M]"; exit 1 ;;
  *)       echo "Unknown command: $CMD"; exit 1 ;;
esac
