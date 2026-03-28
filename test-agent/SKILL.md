---
name: test-agent
description: Use when setting up a background test agent, improving test coverage automatically, or user asks to "find untested files" or "write missing tests". Scaffolds a tmux-based agent that continuously generates vitest/jest tests via Claude.
---

# Test Agent

Scaffold a background test agent that continuously finds untested files, generates integration tests via Claude, validates them through quality gates, and commits passing tests to a dedicated branch.

## When Invoked: Run This Workflow

### Step 1: Detect project

Read `package.json` in the working directory.

**Test framework:** Check `devDependencies` for `vitest` or `jest`.
- If neither found: tell the user "No vitest or jest detected in package.json. This skill supports JS/TS projects with vitest or jest." and stop.
- If both found: prefer vitest.

**Package manager:** Check for lockfiles in this order:
1. `pnpm-lock.yaml` → `pnpm`
2. `yarn.lock` → `yarn`
3. `package-lock.json` → `npm`

**Test command:**
- Check `package.json` scripts for `test:unit` or `test`. Use that with the package manager prefix (e.g. `pnpm test:unit`).
- Fallback: vitest → `npx vitest run`, jest → `npx jest`

**Coverage command (full suite):**
- Vitest: `<test-cmd> --coverage.enabled true --coverage.reporter=json-summary --coverage.reportsDirectory="$AGENT_DIR/coverage"`
- Jest: `<test-cmd> --coverage --coverageReporters=json-summary --coverageDirectory="$AGENT_DIR/coverage"`

**Coverage command (single file, for Gate 2):**
- Vitest: `<test-cmd> "$test_path" --coverage.enabled true --coverage.reporter=json-summary --coverage.reportsDirectory="$AGENT_DIR/coverage-check"`
- Jest: `<test-cmd> -- "$test_path" --coverage --coverageReporters=json-summary --coverageDirectory="$AGENT_DIR/coverage-check"`

**Install command:**
- pnpm → `pnpm install --frozen-lockfile`
- yarn → `yarn install --frozen-lockfile`
- npm → `npm ci`

**Project type:** Check dependencies for:
- `next` → "Next.js"
- `react` (no next) → "React"
- Neither → "Node.js"

**MSW:** Check devDependencies for `msw`. If present, enable MSW rules in the prompt template.

### Step 2: Classify source directories

Glob for source files. Map directory patterns to test categories by scanning what actually exists:

```
**/api/**/*.ts(x)      → "api"
**/components/**/*.tsx  → "component"
**/hooks/**/*.ts(x)    → "hook"
**/db/**/*.ts           → "db"
**/lib/**/*.ts          → "lib"
**/utils/**/*.ts        → "lib"
```

Only include categories that have matching source files. Generate a `classify_file()` bash function with case statements matching the project's actual paths. Example output:

```bash
classify_file() {
  local file="$1"
  case "$file" in
    src/app/api/*)           echo "api" ;;
    src/app/_components/*)   echo "component" ;;
    src/hooks/*)             echo "hook" ;;
    src/lib/db/*)            echo "db" ;;
    *)                       echo "lib" ;;
  esac
}
```

Generate matching `get_test_path()` and `get_pattern_name()` functions.

For `get_test_path()`: map source paths to test paths following the project's existing test directory convention. Look at where existing tests live (e.g., `tests/unit/api/`, `__tests__/`, colocated `*.test.ts`). If no tests exist, use `tests/unit/<category>/` as default. Example:

```bash
get_test_path() {
  local source="$1"
  local category="$2"
  local basename
  basename=$(basename "$source" | sed -E 's/\.(ts|tsx)$/.test.\1/')
  case "$category" in
    api)        echo "tests/unit/api/$basename" ;;
    component)  echo "tests/unit/components/$basename" ;;
    hook)       echo "tests/unit/hooks/$basename" ;;
    db)         echo "tests/unit/db/$basename" ;;
    lib)        echo "tests/unit/lib/$basename" ;;
  esac
}
```

For `get_pattern_name()`:

```bash
get_pattern_name() {
  local category="$1"
  case "$category" in
    api)        echo "API route test (import handler, construct Request, assert on Response)" ;;
    component)  echo "Component integration test (render, fireEvent/userEvent, waitFor)" ;;
    hook)       echo "Hook integration test (renderHook, act, fake timers)" ;;
    db)         echo "Database query test (mock DB boundary, test query functions)" ;;
    lib)        echo "Unit/integration test (mock only external boundaries)" ;;
  esac
}
```

### Step 3: Find exemplar tests

For each category, search existing test files:
1. Glob test directories for files matching the category (e.g., `tests/**/api/**/*.test.ts` for "api")
2. Count `it(` or `test(` occurrences in each file
3. Pick the file with the highest count as the exemplar
4. If no tests exist for a category, leave the exemplar as empty string `""`

**For the `lib` category:** If no tests match `tests/**/lib/**`, widen the search to ALL test files not already claimed by another category (api, component, hook, db). The `lib` category is a catch-all — its exemplar should come from whatever remaining test files exist.

Generate a `get_exemplar()` bash function. Example:

```bash
get_exemplar() {
  local category="$1"
  case "$category" in
    api)        echo "tests/unit/api/feedback.test.ts" ;;
    component)  echo "tests/unit/components/Button.test.tsx" ;;
    *)          echo "" ;;
  esac
}
```

### Step 4: Generate files

Read the template files from this skill's `resources/` directory:
- `resources/test-agent.sh`
- `resources/prompt-template.md`

**For test-agent.sh:** Replace all `%%PLACEHOLDER%%` tokens with detected values:

| Placeholder | Value |
|---|---|
| `%%PKG_MANAGER%%` | detected package manager |
| `%%COVERAGE_CMD%%` | full suite coverage command |
| `%%COVERAGE_CMD_FILE%%` | single file coverage command |
| `%%TEST_CMD%%` | test runner command |
| `%%INSTALL_CMD%%` | dependency install command |
| `%%CLASSIFY_FUNCTION%%` | generated classify_file() function |
| `%%EXEMPLAR_FUNCTION%%` | generated get_exemplar() function |
| `%%TEST_PATH_FUNCTION%%` | generated get_test_path() function |
| `%%PATTERN_NAME_FUNCTION%%` | generated get_pattern_name() function |

Write to `scripts/test-agent.sh`. Make executable with `chmod +x`.

**For prompt-template.md:** Replace all `%%PLACEHOLDER%%` tokens:

| Placeholder | Value |
|---|---|
| `%%FRAMEWORK%%` | `vitest` or `jest` |
| `%%PROJECT_TYPE%%` | `Next.js`, `React`, or `Node.js` |
| `%%MSW_RULE%%` | If msw detected: `- MSW for all network. Never mock fetch directly.` else empty |
| `%%MOCK_RULE%%` | `- Only mock external boundaries (auth, DB, third-party APIs).` |
| `%%EXTRA_RULES%%` | If CLAUDE-TESTING.md or similar exists in project, extract key rules. Else empty. |
| `%%MSW_SETUP%%` | If msw detected: `MSW SETUP (already configured globally via test setupFiles):\nThe MSW server starts automatically. To override handlers in a test, import { server } from the relative msw path and use server.use(...).` else empty |
| `%%EXEMPLAR_SECTION%%` | If exemplar exists for the current category: `EXEMPLAR TEST (follow this style exactly):\nPath: %%EXEMPLAR_PATH%%\n\n%%EXEMPLAR_CONTENT%%` else empty |

Note: `%%PATTERN%%`, `%%SOURCE_PATH%%`, `%%SOURCE_CONTENT%%`, and `%%TEST_PATH%%` are NOT replaced by the skill — they are filled at runtime by the bash script for each file it processes. `%%EXEMPLAR_SECTION%%` is also runtime — the script builds the full exemplar block (or empty string if no exemplar exists) and substitutes it.

Write to `scripts/test-agent-prompt.md`.

**For skip-list:** Write `scripts/test-agent-skip.txt`:
```
# Files to skip (one glob pattern per line)
# Add files that can't be tested in jsdom — heavy native deps,
# browser-only APIs, etc. The agent will waste Claude invocations
# on these without this list, but quality gates will catch failures.
#
# Examples:
#   src/components/Editor.tsx
#   src/components/canvas/**
```

### Step 5: Update .gitignore

Check if `.agent/` is already in `.gitignore`. If not, append:
```
# Test agent runtime artifacts
.agent/
```

### Step 6: Print usage

```
Test agent scaffolded. To run:
  ./scripts/test-agent.sh --dry-run          # see what it would test
  ./scripts/test-agent.sh start              # run in tmux
  tmux attach -t test-agent                  # watch it work
  cat .agent/report.md                       # check results

Customize scripts/test-agent-skip.txt to skip untestable files.
```

## How the Agent Works (for user reference)

### Quality Gates

Every generated test must pass all 5 gates before being committed:

| Gate | What it checks | Cost |
|---|---|---|
| **0: Assertion lint** | Every test block has a specific assertion (`.toBe()`, `.toEqual()`, etc. — not `.toBeDefined()`). At least one error-path test. | 0 sec (grep) |
| **1: Passes** | Test runs without errors | ~5 sec |
| **2: Coverage** | ≥5% line coverage on target file | ~5 sec |
| **3: Mutation** | Flip one condition in source → test must fail. Proves the test catches real bugs. | ~5 sec |
| **4: Full suite** | Existing tests still pass | ~5 sec |

### Retry with Feedback

When a gate fails, the failure reason is fed back into the next Claude invocation. Each file gets up to 3 attempts (initial + 2 retries). Example feedback: "Gate 0 failed — only 4 specific assertions for 10 tests. Every test block needs a concrete assertion."

### File Prioritization

Uncovered files are sorted by branch count (from coverage JSON), so files with more conditional logic are tested first. Simple pass-through wrappers are deprioritized.

### Move-on Logic

When a file fails all 3 attempts, the agent skips it for the rest of the session and moves to the next file.

## Common Mistakes

- **Don't auto-generate the skip-list.** Import scanning is fragile. Quality gates handle untestable files.
- **Don't ask the user questions.** Auto-detect everything. If detection fails, abort with a clear message.
- **Don't modify source code.** The skill only generates test infrastructure files.
