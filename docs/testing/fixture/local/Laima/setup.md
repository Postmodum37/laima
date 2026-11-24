---
updated: @YDAY@
---
# Setup

## Multiplexer
@MULTIPLEXER_LINE@

## Harnesses
| Harness | Version found | Adapter |
|-|-|-|
@HARNESS_ROWS@

## Roles
Which harness, model and effort each role's session runs on; the `launch` skill reads this section at every
launch. Each cell is `harness, model, effort`. A project note may pin a row for that project.

| Role | Usual | Raised | When the usual provider is running short |
|-|-|-|-|
| Laima | Claude Code, opus, high | | |
| planner | Claude Code, opus, high | Claude Code, fable, high | Codex, gpt-6.2-sol, high |
| builder | Codex, gpt-6.2-sol, high | Claude Code, opus, high | Claude Code, opus, high |
| investigator | Claude Code, opus, high | | Codex, gpt-6.2-sol, high |
| researcher | Codex, gpt-6.2-sol, medium | | Claude Code, opus, high |
| reviewer | The provider the builder did not use: opus or gpt-6.2-sol, high | | A new session on the builder's provider |

- **Mode:** bypass for every row.
- **Raise when:** the design is still open, or the work touches authentication, stored data, payments or concurrency.
- **The costliest models** are `fable` and `gpt-6.2-astra`. Outside the cells above they need the user's word.
- **Running short:** a provider is running short when, at the pace so far, it would run out before it resets, or
  when little is left.
- **Today's rule:** none.

## Own workflows
One line per file in `local/Laima/workflows/`: its name and when to use it.

## Workspaces
- Task folders: `@SLOT@/work/<task-id>/`, one per task, for its briefs, reports and plans only. Where a task
  makes its change is the project's to say: its own instructions, or its note's § Workspaces.

## Tools found
Search tools, issue trackers and command-line tools a brief can rely on.

- git, jq, python3

## Set-up runs
- @DAY2@: first run; @TOY@ tracked.

## Not asked yet
Questions set-up could not put to the user. The next run asks them.
