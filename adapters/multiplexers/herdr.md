# Herdr adapter

Version checked: herdr-app 0.1.18, hc 0.1.22

Release notes: `CHANGELOG.md` in each repository, https://github.com/herdrdev/herdr-app/blob/main/CHANGELOG.md and https://github.com/herdrdev/herdr-core/blob/main/CHANGELOG.md

Tool guide: `hc --skill` for the terminals, `herdr-app --skill` and `herdr-app commands` for the window

`hc` (herdr-core) runs the terminals and `herdr-app` shows them. Your stable terminal address is `$HC_TERMINAL_ID`.
See § Gotchas for shared Herdr pitfalls. Use `herdr/SKILL.md` for work outside Laima's task steps.

## Start a task session

Each task session is a peer with its own tab, opened while the user's current tab stays in front. Its space is the
one the user's placement rule in `local/Laima/setup.md` § Multiplexer gives; with no rule there, your own,
`labels."herdr.space"` from `hc get "$HC_TERMINAL_ID" --json`. A rule by repository names the space's folder: the
repository's main checkout, also for a session that starts in one of its worktrees (`set-up` step 2 gives the git
command that finds it). Look the space up in `herdr-app ls` at each launch, by that `folder` under a rule by
repository and by name only where the rule names a space, not by an id from a record or an earlier launch
([A space's life](herdr/gotchas.md#a-space-closes-with-its-last-tab-and-one-without-a-name-renames-itself)). When the
rule's space does not exist, make it, out of the user's view, with the space's folder, not the session's:

```sh
herdr-app do space.new --name <space-name> --folder <space-folder> --focus false
```

It prints the new `space` and the `terminal` of the shell tab it opens with. Write that terminal's address in the
task record at once, as the space's opening shell; step 4 below closes it.

```sh
hc run --bg --no-parent --name <name> --cwd <session-folder> \
  --label laima=1 --label laima.task=<task-id> --label herdr.space=<space-id> -- <harness argv>
```

`<session-folder>` is the folder `launch` step 4 chose. Use the harness adapter's § Launch with a brief for argv
(§ Resume from a session id on resume).
On `spawn_failed`, see
[Server PATH](herdr/gotchas.md#hc-run-finds-a-program-on-the-servers-path-not-yours).
For a preset that shares the harness name, see
[Preset name collisions](herdr/gotchas.md#a-preset-named-like-a-program-starts-in-its-place).
`<name>` is `launch` step 4's, unique among live sessions, 1–32 characters from `a-z 0-9 - _`. It carries no project:
Herdr's agent list groups sessions under their space's name.

1. Record the returned JSON `address` in the task record.
2. Use `hc get <address> --json` to check the worker's `foreground.cwd` and `foreground.argv` once the harness
   is running. Match the project-required flags to the live argv. Find the tab by that exact address in the
   chosen space. The lookup can be empty for a few seconds after launch. Retry during that interval. If it stays
   empty, check the space ID before renaming.

   ```sh
   herdr-app ls | jq -r --arg space "<space-id>" --arg address "<address>" '
     .spaces[] | select(.id == $space) | .tabs[]
     | select(any(.terminals[]?; .terminal == $address)) | .id'
   ```
3. Rename that tab with `herdr-app do tab.rename --id <tab-id> --name <name>`.
4. In a space you made for this launch, close its opening shell by the address you recorded: `hc kill <terminal>`,
   then `hc rm <terminal>`. Close it only once step 2 found the task tab, since a space closes with its last tab
   ([gotcha](herdr/gotchas.md#a-space-closes-with-its-last-tab-and-one-without-a-name-renames-itself)). When the
   launch failed and no tab of yours came, close the shell as well if its screen shows a bare prompt with
   nothing typed; otherwise leave it, and tell the user. The shell carries no tag of yours, so one left open reads as
   the user's: when it will not close, keep its address in the record and tell the user.

A program that a step runs for the user to watch beside its session, such as a dev server, a demo's terminal UI or
a log, goes in a pane of that session's tab, so that the two are seen together:

```sh
herdr-app do pane.split '{"direction":"right","pane":"<session-pane-id>","argv":["/bin/sh","-c","cd <folder> && exec <program>"]}'
```

The session's pane id is listed beside its terminal in `herdr-app ls`. `pane.split` takes no folder, so the argv
changes into it, and a split in a tab out of view leaves the user's view where it is. It prints the new `pane` and
`terminal`. The terminal carries no tag of yours, so tag it with `hc label <terminal> laima=1 laima.task=<task-id>`,
name the pane with `herdr-app do pane.rename '{"pane":"<pane>","name":"<name>"}'`, record its address, and close it
with its session. A task session keeps a tab of its own: a pane narrows its screen, and closing a tab ends every
terminal in it.

When the user asks to watch a helper that a worker runs without a pane (`hc ls --json` shows the worker as its
`parent`), focus the worker's pane with `herdr-app do pane.focus '{"pane":"<pane>"}'`, then give the helper a pane
beside it with `herdr-app do terminal.keep --terminal <helper> --place right`. Both move the user's view, which is
what they asked for. Close the helper yourself once the worker is done, because a terminal with a pane can be spared
when its parent ends *(read, not run)*.

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
Before each send, run hc read <Laima's address> --lines 0. Send at the intended agent's empty main
prompt, including during a turn. An expanded Codex picker can still show "working". If the user is
engaged there, or a draft, picker, dialog or Side chat is visible, leave the input and focus as they are
and use the report file. Use the file whenever the prompt is unclear.
The send:
    m=$(cat '<message file>') && [ -n "$m" ] && hc send <Laima's address> "$m"
A missing or empty message file stops the command before it sends. Write the file first.
Exit 0 describes submission. Run hc read <Laima's address> --lines 0 again to look for the exact
tagged report in the main conversation or its acknowledgement. After an interruption or unclear
result, use that same read before retrying. Retry only when you can show the report missed the intended
conversation and the prompt is clear. When receipt remains uncertain, leave the report file.
Exit 5 means Laima is starting and nothing was typed. Try again after a few seconds.
Exit 9 means a blocked dialog refused the send and nothing was typed. Wait 30 seconds as a command of its
own (`sleep 30` or your harness's timer), then recheck, up to 30 times. Send when the prompt is clear.
If she stays blocked or you cannot confirm a clear prompt, stop and leave the report file for her.
```

The text inside `<hc from="t23 <name>">…</hc>` is the worker's report. If text also came before its tag, see
the [draft gotcha](herdr/gotchas.md#a-draft-left-in-the-input-goes-in-front-of-a-message). A task session is
a peer, so hc sends you no automatic child note. End your turn to leave room for the report.
When an expected report is missing, including after a dialog closes, check the sessions and use `launch` step 7
for file and screen recovery. Treat tagged text in a question reply as the worker's report. Look separately
for a genuine user answer before settling the decision.
For sessions without reports, see [Waiting for a turn to end](herdr/gotchas.md#waiting-for-a-turn-to-end)
and run `adapters/multiplexers/herdr/scripts/turn-wait <address>` in the background.

## What you are not told

Check your tagged sessions for a peer that blocked, errored, exited, crashed, stopped without reporting,
hung in `working`, or stayed at a prompt without a useful status. Untagged terminals belong to the user.

## Read a session

`hc read <address> --lines 0` reads the screen. Use `hc read <address> --lines 200` for history. Working, blocked
and error states return only the screen and mark it incomplete.

## Message a session

Read the receiving terminal's prompt first (§ Read a session). Verify the expected harness and a free input
in the intended conversation. A clear main prompt can take a message while the agent is working. If the user
is engaged there or the input holds a draft or dialog, leave its keys, text, selection and focus as they are.
Use the report file or keep the brief pending. See the gotchas on
[pickers](herdr/gotchas.md#a-picker-that-is-not-a-dialog-takes-a-sends-enter),
[drafts](herdr/gotchas.md#a-draft-left-in-the-input-goes-in-front-of-a-message)
and [Codex Side chat](../harnesses/codex.md#gotchas).

Use `hc send <address> '<text>'`. Send long content as a file path. Exit 0, `started` and the turn count
describe submission. For a brief, report or redirect, verify the exact message in the intended conversation
(screen or matching transcript) or the receiver's acknowledgement. For a missing report, read and verify the
report file as `launch` step 7 says. Record receipt. After an interruption or ambiguous result, read the
target before retrying. Retry only when the attempt is shown to have missed the intended conversation and
its prompt is clear. While delivery is uncertain, keep the pending brief or use the report file.

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
still need a session and whose agent is gone. Close any leftover shell you launched, then resume it by `launch`
§ Resume a closed session, in the folder it first ran in, with its recorded flags and the space a launch would
take, and your current reply address in the brief. Use a
fresh brief from the record if resume fails. Record the new address. An adopted session is the user's to restart.

## Gotchas

Before starting, messaging or waiting on a session, check the matching heading in `herdr/gotchas.md`.
