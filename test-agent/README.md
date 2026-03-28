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
2. Invokes Claude to generate a test
3. Validates through 5 quality gates:
   - **Gate 0:** Static assertion lint — rejects weak assertions (`toBeDefined`, `toBeTruthy`)
   - **Gate 1:** Test passes in isolation
   - **Gate 2:** Adds >=5% line coverage to the target file
   - **Gate 3:** Mutation check — flips a condition in the source, verifies test fails
   - **Gate 4:** Full test suite still passes
4. Commits passing tests to `chore/auto-tests` branch
5. If a gate fails, retries up to 3 times with the failure reason fed back to Claude
6. Sleeps, moves to next file

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

Each Claude invocation is capped at $0.50. With up to 3 attempts per file, expect ~$1.50/file worst case. The `--dry-run` flag shows what would be tested without invoking Claude.

## Customization

- **Skip files:** Add glob patterns to `scripts/test-agent-skip.txt` for files that can't be tested (heavy native deps, browser-only APIs). Quality gates will catch failures regardless, but the skip-list saves Claude invocations.
- **Prompt template:** Edit `scripts/test-agent-prompt.md` to add project-specific testing rules or change the assertion style.
- **Exemplars:** The generated `get_exemplar()` function in the script maps categories to your best existing test files. Edit it to point to tests your team has approved.
