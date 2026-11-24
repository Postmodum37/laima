---
updated: YYYY-MM-DD
---
# Setup

## Multiplexer
- <name>, version <found>; adapter `adapters/multiplexers/<name>.md`

## Harnesses
| Harness | Version found | Adapter |
|-|-|-|

## Roles
Which harness, model and effort each role's session runs on; the `launch` skill reads this section at every
launch. Each cell is `harness, model, effort`. A project note may pin a row for that project.

| Role | Usual | Raised | When the usual provider is running short |
|-|-|-|-|
| Laima | | | |
| planner | | | |
| builder | | | |
| investigator | | | |
| researcher | | | |
| reviewer | | | |

- **Mode:** <the permission mode every row runs in, or the rows that differ>
- **Raise when:** <the condition for the Raised column, in a sentence the launch can be checked against>
- **Running short:** <how to tell from a usage reading that a provider will run out before it resets>
- **Today's rule:** none. <A rule the user gives for one day goes here with its date, and is removed after.>

## Own workflows
One line per file in `local/Laima/workflows/`: its name and when to use it.

## Workspaces
- Task folders: `<folder>/<task-id>/`, one per task, for its briefs, reports and plans only. Where a task
  makes its change is the project's to say: its own instructions, or its note's § Workspaces.

## Tools found
Search tools, issue trackers and command-line tools a brief can rely on.

## Set-up runs
- YYYY-MM-DD: <the latest run and what it changed, in a line; earlier runs are in the log>

## Not asked yet
Questions set-up could not put to the user. The next run asks them.
