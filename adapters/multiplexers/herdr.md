# Herdr adapter

Version checked: herdr-app 0.1.18, hc 0.1.22

Release notes: `CHANGELOG.md` in each repository, https://github.com/herdrdev/herdr-app/blob/main/CHANGELOG.md and https://github.com/herdrdev/herdr-core/blob/main/CHANGELOG.md

Tool guide: `hc --skill` for the terminals, `herdr-app --skill` and `herdr-app commands` for the window

`hc` (herdr-core) runs the terminals and `herdr-app` shows them. Your stable terminal address is `$HC_TERMINAL_ID`.
See § Gotchas for shared Herdr pitfalls. Use `herdr/SKILL.md` for work outside Laima's task steps.

## Start a task session

Each task session is a peer with its own tab. First find your space in `labels."herdr.space"` from
`hc get "$HC_TERMINAL_ID" --json`. Use that space to open the tab while keeping the user's current tab in front.

```sh
hc run --bg --no-parent --name <name> --cwd <folder> \
  --label laima=1 --label laima.task=<task-id> --label herdr.space=<space-id> -- <harness argv>
```

Use the harness adapter's § Launch with a brief for argv. On `spawn_failed`, see
[Server PATH](herdr/gotchas.md#hc-run-finds-a-program-on-the-servers-path-not-yours).
For a preset that shares the harness name, see
[Preset name collisions](herdr/gotchas.md#a-preset-named-like-a-program-starts-in-its-place).
Shorten `<task-id>-<role>` to a unique live name of 1–32 characters from `a-z 0-9 - _`.

1. Record the returned JSON `address` in the task record.
2. Find the tab by that exact address in the chosen space. The lookup can be empty for a few seconds after
   launch. Retry during that interval. If it stays empty, check the space ID before renaming.

   ```sh
   herdr-app ls | jq -r --arg space "<space-id>" --arg address "<address>" '
     .spaces[] | select(.id == $space) | .tabs[]
     | select(any(.terminals[]?; .terminal == $address)) | .id'
   ```
3. Rename that tab with `herdr-app do tab.rename --id <tab-id> --name <name>`.

To adopt a session the user started, find it in plain `hc ls` and tag it with
`hc label <address> laima=1 laima.task=<task-id> laima.adopted=1`.

## See all sessions

```sh
hc ls --all --json --label laima=1                # all you tagged, finished included; labels match exactly
hc ls --all --json --label laima.task=<task-id>   # one task's sessions
```

Use plain `hc ls` to see all live sessions, including untagged ones.

| Listing shows | Means |
|-|-|
| `status: working` / `blocked` | A turn is running / a person is needed |
| `status: done` / `idle` | The turn ended / the session waits for input. Check the outcome separately. |
| `status: error` | Read `status.msg` in `hc get <address> --json` |
| Live without `status` | Read the screen for startup, an unreported prompt or a shell |
| `state: finished` | The program ended (`exit_code`, `reason`). The record is readable until `hc rm`. |
| No record | Unknown, including removal or loss at reboot |

## Waiting on the user

For `status: blocked`, check `status.kind` (`permission`, `question`, `auth`) and `status.msg` in
`hc get <address> --json`, then read the dialog. Use root `AGENTS.md` § Authority to decide who answers.

To answer a dialog in your authority, read the selection, move with `hc keys <address> up` or `down`, read
again, then send `hc keys <address> enter` when the intended choice is selected. For a free-text answer, select
`Type something.` and send one key name per character. `hc keys <address> shift+z e t a space t w o` types
`Zeta two`. Read the text, then press Enter. For Claude Code's multi-question flow, see its adapter § Gotchas.
While blocked, `hc send` exits 9 without typing. Both `hc keys` and `hc send --force` can answer the dialog,
so use them only within your authority.

## How you learn a session finished

Copy this block into the worker brief with your literal address from `echo "$HC_TERMINAL_ID"`. A variable in the
worker's command expands to the worker's address.

```
The send:
    m=$(cat '<message file>') && [ -n "$m" ] && hc send <Laima's address> "$m"
It exits 0 and prints a line once the text is typed in (JSON, or a sentence where the shell is a terminal,
as agy's is; go by the exit code); it waits first while someone has a draft there. A missing or empty
message file stops it before anything is sent: write the file, then send. Exit 5: Laima is
starting, and nothing was typed; send again after a few seconds. Exit 9: she is at
a dialog of her own, and nothing was typed; wait 30 seconds as a command of its own (`sleep 30`, or your
harness's own timer where it bars a shell sleep) and send again, up to 30 times; then stop, and she reads
the report file.
```

The text inside `<hc from="t23 <name>">…</hc>` is the worker's report. See § Message a session for any draft
text before the tag. A task session is a peer, so hc sends you no automatic child note. End your turn to leave
room for the report. For a session that stopped silently, see `launch` step 7 for the report-file and screen
fallback. While your own question dialog is open, every send to you is refused with exit 9, and a worker
that used up its retries has stopped trying. So when a dialog closes, look at the sessions before your next step
(§ See all sessions), and read the report file of each one that is `done` with no report in your conversation.
For sessions without reports, see [Waiting for a turn to end](herdr/gotchas.md#waiting-for-a-turn-to-end)
and run `adapters/multiplexers/herdr/scripts/turn-wait <address>` in the background.

## What you are not told

Check your tagged sessions for a peer that blocked, errored, exited, crashed, stopped without reporting,
hung in `working`, or stayed at a prompt without a useful status. Untagged terminals belong to the user.

## Read a session

`hc read <address> --lines 0` reads the screen. Use `hc read <address> --lines 200` for history. Working, blocked
and error states return only the screen and mark it incomplete.

## Message a session

Read the prompt first, then use `hc send <address> '<text>'`. Exit 0 confirms submission. Look for the result
in the worker's report or screen. Send long content as a file path. See the gotchas on
[pickers](herdr/gotchas.md#a-picker-that-is-not-a-dialog-takes-a-sends-enter) and
[drafts](herdr/gotchas.md#a-draft-left-in-the-input-goes-in-front-of-a-message).

## Close a session

Close an address only when the task record and your label establish that you launched it. If a labelled address
has no record, tell the user and leave it. Close a session labelled `laima.adopted` only at the user's request.
First end the program as its harness adapter's § End a session says, where it has one. Use `hc kill
<address>` to end a program still live after that, and to close its tab. Read any output you still need, then run
`hc rm <address>` on the finished record and confirm it is absent from `hc ls --all`. Leave the shared core and
window running. Use `herdr-app` through `ls`, `status` and `do`.

## What the user is notified of without you

Herdr alerts the user when a task peer, or you, blocks, reports an error or ends a turn off screen. Your own
question or turn end is the alert. See
[sound and toast timing](herdr/reference.md#window-attention-and-navigation-herdr-app).
Check the listing and screen for exits, crashes and prompts without a status, which are silent *(read, not run)*,
and tell the user when their input is needed.

## After a reboot

A closed window leaves the core running. Kept terminals can return as replacement shells at the same address
after loss. The details are in `hc --skill` § Status, recovery, and cleanup *(read, not run)*.

After a reboot, logout or core crash, check the listing and each open task's record. Restart only steps that
still need a session and whose agent is gone. Close any leftover shell you launched, then follow the harness
adapter's § Resume from a session id in the same folder, with your current reply address in the brief. Use a
fresh brief from the record if resume fails. Record the new address. An adopted session is the user's to restart.

## Gotchas

Before starting, messaging or waiting on a session, check the matching heading in `herdr/gotchas.md`.
