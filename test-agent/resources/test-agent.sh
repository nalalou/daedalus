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
generate_test() {
  local source_path="$1"
  local test_path="$2"
  local category="$3"

  local exemplar_path
  exemplar_path=$(get_exemplar "$category")
  local pattern_name
  pattern_name=$(get_pattern_name "$category")

  # Build prompt from template
  local prompt
  prompt=$(cat "$PROMPT_TEMPLATE")
  prompt="${prompt//%%PATTERN%%/$pattern_name}"
  prompt="${prompt//%%SOURCE_PATH%%/$source_path}"
  prompt="${prompt//%%SOURCE_CONTENT%%/$(cat "$WORKTREE_PATH/$source_path")}"
  prompt="${prompt//%%TEST_PATH%%/$test_path}"

  # Build exemplar section — full block or empty if no exemplar exists
  local exemplar_section=""
  if [[ -n "$exemplar_path" && -f "$WORKTREE_PATH/$exemplar_path" ]]; then
    exemplar_section="EXEMPLAR TEST (follow this style exactly):
Path: $exemplar_path

$(cat "$WORKTREE_PATH/$exemplar_path")"
  fi
  prompt="${prompt//%%EXEMPLAR_SECTION%%/$exemplar_section}"

  cd "$WORKTREE_PATH"
  local output
  output=$(echo "$prompt" | claude -p \
    --model sonnet \
    --max-budget-usd 0.50 \
    --no-session-persistence \
    2>/dev/null) || {
    echo "ERROR: Claude invocation failed for $source_path"
    return 1
  }

  # Strip markdown fences if Claude wrapped the output
  output=$(printf '%s\n' "$output" | sed -E '/^```(typescript|ts|tsx)?$/d')

  mkdir -p "$(dirname "$WORKTREE_PATH/$test_path")"
  printf '%s\n' "$output" > "$WORKTREE_PATH/$test_path"
}

validate_test() {
  local source_path="$1"
  local test_path="$2"

  cd "$WORKTREE_PATH"

  # Gate 0: Static assertion lint — reject weak tests before running anything
  echo "::status id=phase running Gate 0: assertion quality..."
  if ! validate_assertions "$WORKTREE_PATH/$test_path"; then
    return 1
  fi

  # Gate 1: Test passes in isolation
  echo "::status id=phase running Gate 1: test passes..."
  if ! %%TEST_CMD%% "$test_path" 2>&1; then
    echo "::err Gate 1 failed — test does not pass"
    return 1
  fi

  # Gate 2: Adds ≥5% branch coverage
  echo "::status id=phase running Gate 2: coverage check..."
  %%COVERAGE_CMD_FILE%% >/dev/null 2>&1 || true

  local new_summary="$AGENT_DIR/coverage-check/coverage-summary.json"
  if [[ -f "$new_summary" ]]; then
    local abs_source="$WORKTREE_PATH/$source_path"
    local line_pct
    line_pct=$(jq -r --arg f "$abs_source" '.[$f].lines.pct // 0' "$new_summary")
    if (( $(echo "$line_pct < 5" | bc -l) )); then
      echo "::err Gate 2 failed — only ${line_pct}% line coverage (need ≥5%)"
      return 1
    fi
  fi

  # Gate 3: Mutation check — does the test catch a real bug?
  echo "::status id=phase running Gate 3: mutation check..."
  if ! mutation_check "$source_path" "$test_path"; then
    return 1
  fi

  # Gate 4: Full suite still passes
  echo "::status id=phase running Gate 4: full suite..."
  if ! %%TEST_CMD%% 2>&1; then
    echo "::err Gate 4 failed — full suite broken"
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

  local source_path
  source_path=$(echo "$uncovered" | head -1)
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
  echo "::status id=phase running Generating test via Claude..."

  if ! generate_test "$source_path" "$test_path" "$category"; then
    echo "::err $source_name — Claude invocation failed"
    sedi "/## Failed attempts/a\\
- $source_path — Claude invocation failed (iteration $iteration)" "$REPORT_FILE"
    echo "::status id=file error $source_name"
    return
  fi

  echo "::status id=phase running Gate 1: test isolation..."
  if validate_test "$source_path" "$test_path"; then
    cd "$WORKTREE_PATH"
    git add "$test_path"
    git commit -m "test: add integration tests for $source_path

Auto-generated by test-agent (iteration $iteration)"

    local coverage_pct
    coverage_pct=$(jq -r --arg f "$WORKTREE_PATH/$source_path" '.[$f].lines.pct // "?"' "$AGENT_DIR/coverage-check/coverage-summary.json" 2>/dev/null || echo "?")
    echo "::ok $source_name — ${coverage_pct}% coverage"
    sedi "/## Tests written/a\\
- $source_path → $test_path (+${coverage_pct}% coverage)" "$REPORT_FILE"
    echo "::status id=file done $source_name"
  else
    rm -f "$WORKTREE_PATH/$test_path"
    echo "::err $source_name — validation failed"
    sedi "/## Failed attempts/a\\
- $source_path — validation failed (iteration $iteration)" "$REPORT_FILE"
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
