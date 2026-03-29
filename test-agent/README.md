# test-agent

A Claude Code skill that scaffolds a background test agent for your project.

## Install

```bash
cp -r test-agent ~/.claude/skills/test-agent
```

## Usage

In any vitest/jest project, tell Claude: **"set up a test agent"**

The skill auto-detects your project and generates:

- `scripts/test-agent.sh` — background agent (start/stop/status/dry-run)
- `scripts/test-agent-skip.txt` — files to skip (you customize)
- `scripts/test-agent-prompt.md` — prompt template for Claude

## How it works

The agent runs in a tmux session and loops:

1. Runs coverage to find untested files (sorted by complexity — most branches first)
2. Spawns a Claude agent (not a one-shot call) that can read source files, understand imports, write the test, run vitest, and fix failures on its own
3. Validates through 5 quality gates:
   - **Gate 0:** Static assertion lint — rejects weak assertions (`toBeDefined`, `toBeTruthy`). Every test block must have a specific assertion. At least one error-path test required.
   - **Gate 1:** Test passes in isolation
   - **Gate 2:** Adds >=5% line coverage to the target file
   - **Gate 3:** Mutation check — flips a condition in the source, verifies the test catches it
   - **Gate 4:** Full test suite still passes
4. Commits passing tests to `chore/auto-tests` branch
5. If a gate fails, retries up to 3 times with the failure reason fed back to Claude ("your previous attempt was rejected because...")
6. If all 3 attempts fail, skips the file and moves to the next target
7. Sleeps, repeats

The agent has scoped tool access: `Read`, `Write`, and `Bash(pnpm vitest:*)` only. It cannot run git, access the network, or execute arbitrary commands.

## Commands

```bash
./scripts/test-agent.sh --dry-run                    # see what it would test
./scripts/test-agent.sh start                         # run in tmux
./scripts/test-agent.sh start --max-iterations 5      # limit iterations
./scripts/test-agent.sh start --interval 3            # 3 min between iterations
./scripts/test-agent.sh status                        # check if running
./scripts/test-agent.sh stop                          # stop gracefully
tmux attach -t test-agent                             # watch it work
cat .agent/report.md                                  # check results
git log chore/auto-tests                              # review generated tests
```

## Requirements

- `jq`, `bc`, `claude` CLI
- `tmux` (for detached mode)
- Optional: [`gloss`](https://github.com/nalalou/gloss) (for pretty TUI output)

## Cost

Each Claude agent invocation is capped at $1.00 (agent mode uses more tokens than one-shot since it reads files, runs tests, and iterates). With up to 3 attempts per file, expect ~$3.00/file worst case. The `--dry-run` flag shows what would be tested without invoking Claude, including an estimated max cost.

## Customization

- **Skip files:** Add glob patterns to `scripts/test-agent-skip.txt` for files that can't be tested (heavy native deps, browser-only APIs). Quality gates will catch failures regardless, but the skip-list saves Claude invocations.
- **Prompt template:** Edit `scripts/test-agent-prompt.md` to add project-specific testing rules or change the assertion style.
- **Exemplars:** The generated `get_exemplar()` function in the script maps categories to your best existing test files. Edit it to point to tests your team has approved.
