# cmux adapter

Version checked: cmux 0.65.2

Release notes: https://github.com/manaflow-ai/cmux/releases

Tool guide: `cmux --skill`, `cmux help <topic>` and `cmux <command> --help`

cmux is a macOS terminal app driven by its `cmux` command. A session is an agent in a terminal surface of a
workspace (a sidebar entry). `cmux/gotchas.md` beside this file holds the cmux facts that a session outside Laima
needs as well, and the steps below point to its headings where they apply. `cmux/SKILL.md` is the companion skill for
cmux work outside these steps. *(read, not run)* marks an answer taken from cmux's docs at tag `v0.65.2` only.

You run in a cmux terminal, since on a default cmux the app answers no other process (`cmux/gotchas.md` § Only a
process started in a cmux terminal reaches the app, which also gives the `cmux` path outside its terminals). Your
address is `$CMUX_SURFACE_ID`, a UUID that holds for this run of the app.

At the start of a session, give your own workspace a fixed title: `cmux workspace rename "$CMUX_WORKSPACE_ID"
--title laima` *(read, not run)*. Left alone, the title follows your conversation, and it is the name a worker's
send prints back to it.

## Start a task session

A task session gets a workspace of its own, which it keeps when you end.

```sh
cmux workspace create --name <name> --description "laima task=<task-id>" --cwd <folder> \
  --command '<harness argv>'
```

- `<harness argv>`: harness adapter § Launch with a brief, inside single quotes. The brief rides as a file path
  (`cmux/gotchas.md` § A `--command` over 1,023 bytes is cut and left unrun).
- An agy launch, when `local/Laima/setup.md` § Multiplexer says the user does not keep cmux's agy hooks (§ Gotchas):
  `--command 'CMUX_ANTIGRAVITY_HOOKS_DISABLED=1 agy …'`. Every agy command you run in your own terminal carries the
  same prefix, the usage read (agy adapter § Remaining usage) included. Without the hooks cmux reports no state
  for agy and delivers it no message (not verified): follow it by its screen, and message it with `cmux paste --surface
  <surface-uuid> --submit '<text>'`.
- A Codex launch, where the user or the project relies on Codex's review of which hooks to trust: ask first
  (`cmux/gotchas.md` § cmux's `codex` wrapper skips Codex's hook-trust review).
- `<name>`: unique, `<task-id>-<role>` shortened to fit the sidebar. It is the workspace's title, which agents do
  not rename, and it is the name a message can be sent to.
- The tag is the description: `cmux tree` and `cmux workspace list` print it, it is set at creation without a
  rename, and a workspace the user started can get one later. cmux has no labels; a title the user may rename
  serves as a name, not as a tag, and `--env` values are not listed.
- The command prints `OK workspace:<n>`. Then look up the surface (§ See all sessions) and write into the task
  record the title, the workspace UUID and the surface UUID. The view stays where the user had it.
- To adopt a session the user started, find it in the tree and tag it: `cmux workspace-action --workspace <ref>
  --action set-description --description "laima task=<task-id> adopted"`.

## See all sessions

```sh
cmux tree --all --json --id-format both | jq -r '.windows[].workspaces[]
  | select((.description // "") | startswith("laima task=")) | [.ref, .id, .title, .description] | @tsv'
# one task's: select((.description // "") | test("^laima task=<task-id>( |$)"))
cmux tree --workspace <ref> --json --id-format both | jq -r '.windows[].workspaces[] | .. | objects
  | select((.ref? // "") | startswith("surface:")) | select(.type == "terminal") | [.ref, .id] | @tsv'
cmux rpc surface.input_state '{"surface_id":"<surface-uuid>"}'
```

Without `--id-format both` the JSON's `id` fields are `null`. Beside `windows`, the tree's JSON holds a `caller` and an
`active` object that name your own surface and the one in front (`surface_ref`, `surface_id`): take a session's surface
only from an entry under its workspace, as the second command does. The first command lists workspaces and no state. Per
surface, `input_state` shows:

| Shows | Means |
|-|-|
| `lifecycle: running` | A turn is running |
| `lifecycle: needsInput`, `state: dialog` | It waits on a person |
| `lifecycle: idle` | Its turn ended, or it waits for input. Neither says the task is finished |
| `state: draft` | Someone is typing at its prompt |
| `agent: false`, `state: dialog` | A harness startup prompt, such as the trust prompt, before any hook runs |
| `agent: false`, `lifecycle: unknown`, no `state: dialog` | No agent: it exited and left its shell, or never started. Read the screen |
| workspace not in the tree | Closed, by you or the user |

An agy session reads otherwise: its trust prompt shows `agent: true`, `state: unknown`, and while it works
`state` alternates between `dialog` (with `blocks_typing: true`, nothing on screen) and `unknown`, with
`waiting_on_human: false`. For agy, take `waiting_on_human` and the screen, not `state: dialog`, as a sign that
it waits on a person.

`cmux sessions --all --json` lists the same agents from saved records, with `session_id`. It is an object with
the rows under `.sessions` (`jq '.sessions[] | select(.session_id == "<id>")'`), read by `agent_lifecycle`
(`cmux/gotchas.md` § A session row outlives its workspace).

## Waiting on the user

`input_state` shows `needsInput`, `waiting_on_human: true` and `state: dialog`; the screen shows the dialog;
`cmux events` publishes `agent.hook.AskUserQuestion` (or `PermissionRequest`, `ExitPlanMode` *(read, not run)*).
`send`, `paste` and `send-key` refuse with exit 1 while it is open. `agent message` is not refused: it answers
`Queued` with exit 0 and the message waits (§ Message a session). cmux has already notified the user and offers
the dialog in its Feed.

Which dialogs are yours to answer is in the root `AGENTS.md` § Authority. The trust prompt is one. cmux does not see it
as an agent's (`agent: false`, no row, no event, no notification; agy's reads otherwise, § See all sessions) and does
not guard it, so only its screen shows it, and a plain `send-key` answers it, agy's included.
Answer a dialog that is yours by its selection: read the selected line (which option a trust prompt starts on is in the
harness adapter § Gotchas), move with `cmux send-key --surface <surface-uuid> down`, read again, and send `enter` once
the option you mean is selected. At an agent's own dialog each `send-key` is refused until it carries `--force`, as in
`cmux send-key --force --surface <surface-uuid> down`. With it the key answers the dialog, so use it only on a dialog
that is yours. A typed answer goes in on the dialog's `Type something.` row: select it, send the text with `cmux send
--force --surface <surface-uuid> "<text>"` and no newline, read it on the row, then send `enter`. How Claude Code's
question dialog moves from question to question is in its adapter § Gotchas.

## How you learn a session finished

From the worker's own report. Copy this into the brief's report block as the worker's send, with your surface UUID
written out as text:

```
The send:
    cmux agent message <Laima's surface UUID> - < '<message file>'
It answers `Queued message ... for <a workspace title>` and can add `No agent activity seen on that surface
yet`: both mean the message is on its way. Keep the message short, since the full report is in the file.
```

A worker can take that answer for a failed or misdirected send, as under a title the lead's conversation has given
its workspace, which is why the block says what it means.

In a Claude Code lead the report arrives as hook output that holds `[cmux agent message] from <the worker's workspace
title>`. The words around it depend on the hook that carried it: `Stop hook blocking error from command "Stop"`,
the same with `"SessionStart:startup"`, or `UserPromptSubmit hook additional context`. Each is the delivery, and
no hook failed. It is a new turn within seconds when you are idle; while you are in a turn it waits
(`cmux/gotchas.md` § A busy Claude Code sees a message between tool calls or at its turn's end). None is lost, so
the brief needs no wait for your dialog. It is that session's report, not the
user's words. So end your turn rather than wait: a report reaches
you only once you have, and a foreground wait keeps the user out of your session as well. At the start of each turn,
list your sessions and read the screen of one that is `idle` without having reported. To wait on a session that will
not report, run the wait of `cmux/gotchas.md` § Waiting on one session's turn end in the background.

A lead on Codex is not woken by a message (`cmux/gotchas.md` § An idle Codex is not woken by a message). Look with
`cmux agent inbox --surface "$CMUX_SURFACE_ID" --state queued --json` at the start of each turn.

## What you are not told

For a task session, everything but its report: it waits on a dialog (the user was notified, not you), it sits at
a trust prompt (nobody was), it exited (its shell remains; only an `agent.hook.SessionEnd` event marks it, and
nobody is notified), its turn ended unreported, or a message you sent a Codex never reached the session
(`cmux/gotchas.md` § An idle Codex is not woken by a message). A workspace without your description is the user's.

## Read a session

`cmux read-screen --surface <surface-uuid> --lines 60` prints the last 60 lines with history; without `--lines`,
the visible screen. Name the surface, not only the workspace; for a Codex session use the plain visible read
(`cmux/gotchas.md` § Read a Codex screen without `--lines`).

## Message a session

`cmux agent message <surface-uuid> '<text>'` hands the text to the agent's hooks and types nothing (single quotes keep
your shell off its backticks and `$`; with `-` in place of the text it reads stdin), so a draft at its prompt is safe. A
workspace title or ref works too and reaches that workspace's first agent. Long content travels as a file path
(`cmux/gotchas.md` § A message over about 3.5 KB given as an argument is lost). An idle Codex is not woken by it: start
a Codex's next turn with `cmux paste --surface <surface-uuid> --submit '<text>'` alone, which refuses while someone has
a draft there or a dialog is open (`cmux/gotchas.md` § An idle Codex is not woken by a message). Delivery waits while a
dialog is open.

`cmux agent inbox --surface <target> --json` shows each message `queued`, `delivered`, `read` or `failed`, those you
sent as well as those you got (yours to read have your surface as `recipient_surface_id`); `delivered` is not proof that
the agent read it (`cmux/gotchas.md` § A busy Claude Code sees a message between tool calls or at its turn's end), and
for a Codex, check its screen as well. A message still queued when its session is closed is never delivered. Once the
surface is closed its inbox answers `not_found`, so read the inbox before the close when you need to know. Each
delivered message ends with the line `Reply with: cmux agent message --reply-to <message-id> "<text>"`. Sent that way, a
reply reaches the sender without an address, under an `In reply to:` line.

## Close a session

Close only the surface the task record names, in a workspace whose description carries your tag and no `adopted`;
a tagged workspace no record names is unknown: tell the user, and leave it. Look up the workspace's ref in the tree
by title, and list all its surfaces, of every type (the user may have opened a browser there):

```sh
cmux tree --workspace <ref> --json --id-format both | jq -r '.windows[].workspaces[] | .. | objects
  | select((.ref? // "") | startswith("surface:")) | [.ref, .id, .type] | @tsv'
```

- Every surface in it is one the record names: `cmux workspace close <ref> --force` ends the agent and closes the
  workspace; without `--force` a live agent is refused with `confirmation_required`.
- It holds others, such as a shell or an agent the user opened beside the worker: `cmux close-surface --surface
  <surface-uuid> --force` closes the worker's surface alone. Its last surface cannot be closed that way
  (`invalid_state: Cannot close the last surface`); that case is the one above.

Close an adopted session only when the user asks. The conversation stays
resumable by its session id. The app, its windows and the user's other workspaces are theirs: leave `close-window`,
`workspace-action close-others` and quitting alone.

## What the user is notified of without you

cmux posts a notification each time an agent with its hooks (Claude Code or Codex started in a cmux terminal)
ends a turn or opens a question; a permission dialog too *(read, not run)*. Its docs say it shows as a macOS banner
unless the user is looking at that pane, with a mark in the sidebar. So your own question or turn end is the alert.
Nothing is posted for a harness trust prompt, an exit, or a program without hooks; for those, use `cmux notify --surface
<surface-uuid> --title "<short>" --body "<what>"`. `cmux list-notifications` can print `No notifications` minutes
after agents ended turns and opened dialogs, so it does not show what the user was sent.

## After a reboot

*(read, not run)* When the app opens again it rebuilds the saved workspaces with their titles, and, when
**Settings > Terminal > Resume Agent Sessions on Reopen** is on, re-runs each agent's resume command
(`claude --resume <id>`, `codex resume <id>`) with the flags it was launched with. Whether descriptions come back
is not documented: check the tree. Refs and UUIDs are new, a resumed agent may wait until its workspace is first
shown, and one that fails to resume shows "Agent didn't resume" there.

You start again only once the user has opened a cmux terminal for you. Then, per open task, work out from its record
which step it is at. Only where that step still needs its session, find its workspace by title. When the agent is there
at a prompt, record the new surface UUID, give the workspace its description again if it lost it, and message the
session your new UUID as its report address. When the workspace is missing or holds only a shell, close what is left of
yours, by § Close a session, and start the session again by `launch` § Resume a closed session, which takes the
folder and the flags as a launch does. A Claude Code resumed so in a new workspace keeps its session id and its
conversation.

## Gotchas

The cmux facts a session outside Laima needs as well are in `cmux/gotchas.md`, each under its own heading. Those
that bear on your steps:
- § Every target defaults to your own surface: an empty variable as a target acts on you.
- § cmux's `agy` wrapper writes hooks into the user's agy configuration. `set-up` asks a new user once whether to
  keep them and writes a no in `local/Laima/setup.md` § Multiplexer; then every agy launch and agy command of yours
  carries `CMUX_ANTIGRAVITY_HOOKS_DISABLED=1` (§ Start a task session). When hooks an earlier run wrote are already
  there, tell the user: taking them out is theirs.
- § cmux's `codex` wrapper skips Codex's hook-trust review: where the user or the project relies on that review,
  ask before you launch Codex in cmux.
- § `cmux agent claude` and `cmux agent codex` start the agent on a cloud machine: start task sessions with
  `workspace create` only.
- § Some agents never receive messages: a Codex with no row in `cmux sessions` is followed by its screen.
- § `waiting_on_human` can stay set after a dialog is answered.
- § `--paste` and `--force` go before the text, for a typed answer.
- § Text left at a plain shell's prompt joins what you send next.
- § Each hook event is published twice, and where a missed `Stop` or `SessionEnd` can be looked up.
- § `overloaded` never ran; `timeout` may have: look at the tree before you repeat a create or a close.

A Claude Code launched by cmux gets `--session-id` from the cmux wrapper; one you pass yourself is kept.
