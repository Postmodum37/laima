# Herdr adapter

Version checked: herdr-app 0.1.16, hc 0.1.21

Release notes: none published; the changes are the commits between version tags at https://github.com/herdrdev/herdr-app/tags and https://github.com/herdrdev/herdr-core/tags

Tool guide: `hc --skill` for the terminals, `herdr-app --skill` and `herdr-app commands` for the window

`hc` (herdr-core) runs the terminals; `herdr-app` is the window. A session is an hc terminal: its address (`t7`,
`t2c`) never changes, its name works wherever an address does, and `$HC_TERMINAL_ID` is yours. *(read, not run)*
marks a fact read in code or manuals and not run. `herdr/gotchas.md` beside this file holds the Herdr facts that a
session outside Laima needs as well, and the steps below point to its headings where they apply. `herdr/SKILL.md` is
the companion skill for Herdr work outside these steps.

## Start a task session

A task session is a peer: no parent, its own tab. It outlives you, and Herdr alerts the user about it directly.

```sh
hc run --bg --no-parent --name <name> --cwd <folder> \
  --label laima=1 --label laima.task=<task-id> --label herdr.space=<space-id> -- <harness argv>
```

- `<harness argv>`: harness adapter § Launch with a brief. The brief rides in it (`herdr/gotchas.md` § A send to a
  session still starting can fail). When `hc run` answers `spawn_failed`, put `/usr/bin/env PATH="$PATH"` in front of
  it (`herdr/gotchas.md` § `hc run` finds a program on the server's PATH, not yours).
- `<name>`: 1 to 32 of `a-z 0-9 - _`, unique among live terminals; shorten the slug of `<task-id>-<role>` to fit.
- `<space-id>`: where the tab opens. Yours is `labels."herdr.space"` in `hc get $HC_TERMINAL_ID --json`. This
  label is what gives the session a tab, and the tab the user is looking at stays in front.
- The command prints JSON; its `address` goes into the task record. Then name the tab, which otherwise shows
  only its number to the user: `herdr-app do tab.rename --id <tab-id> --name <name>`. The tab id (`tb…`) is
  printed by the command below; for a few seconds after `hc run` returns it can print nothing, so look again
  before the rename:

  ```sh
  herdr-app ls | jq -r '.. | objects | select(any(.terminals[]?; .terminal == "<address>")) | .id'
  ```
- To adopt a session the user started, find it in plain `hc ls` and tag it:
  `hc label <address> laima=1 laima.task=<task-id> laima.adopted=1`.

## See all sessions

```sh
hc ls --all --json --label laima=1                # all you tagged, finished included; labels match exactly
hc ls --all --json --label laima.task=<task-id>   # one task's sessions
```

| Listing shows | Means |
|-|-|
| `status: working` | A turn is running |
| `status: blocked` | It waits on a person |
| `status: done` or `idle` | Its turn ended, or it waits for input. Neither says the task is finished |
| `status: error` | The harness reported a failure; `status.msg` in `hc get <address> --json` says why |
| live, no `status` | Unknown: a session in its first seconds, a startup prompt that reports nothing, or a shell where the agent was. Read the screen |
| `state: finished` | The program ended (`exit_code`, `reason`) and its tab closed; readable until `hc rm` |
| not listed | Unknown: removed, or lost at a reboot |

## Waiting on the user

The session shows `status: blocked`; `hc get <address> --json` adds `status.kind` (`permission`, `question`,
`auth`) and `status.msg`, and the screen shows the dialog. Herdr has already alerted the user about a task session.

Which dialogs are yours to answer is in the root `AGENTS.md` § Authority. The trust prompt is one: when a harness shows
it, what it reports and which option it starts on are in the harness adapter § Gotchas. Answer a dialog that is yours by
its selection: read the screen for the selected line, move with `hc keys <address> down` or `up`, read again, and send
`hc keys <address> enter` once the option you mean is selected. A typed answer goes in on the dialog's `Type something.`
row: select it, send the text as one key name per character (`hc keys <address> shift+z e t a space t w o` types `Zeta
two`), read it on the row, then `enter`. How Claude Code's question dialog moves from question to question is in its
adapter § Gotchas. `hc send` refuses a blocked session: it exits 9 with an error that names the dialog's kind, and types
nothing. `hc keys` is not refused there, and `hc send --force` types into the dialog, so each answers it: use them only
on a dialog that is yours.

## How you learn a session finished

From the worker's own report. Copy this into the brief's report block as the worker's send, with your address
written out as text (`echo $HC_TERMINAL_ID`), since a variable would expand to its own:

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

The send types the message file, as the worker wrote it, inside `<hc from="t23 <name>">…</hc>` into your input: a new
turn when you are idle, input to the running turn otherwise (Claude Code adapter § Gotchas says when a lead sees it). It
is that session's report, not the user's words. The line it prints is the one of § Message a session, and its wait for a
draft is `hc --skill`'s. The user may take minutes over a dialog of yours, hence the long wait on exit 9: tries a few
seconds apart can all be refused, and the report is then lost.

hc sends you no note about a task session: list your sessions at the start of each turn, and read the screen of one that
stopped without reporting. So end your turn rather than wait for a report: a foreground wait shuts the user, and the
report itself, out of your session until it returns. To wait on a session that will not report, run
`adapters/multiplexers/herdr/scripts/turn-wait <address>` in the background (`herdr/gotchas.md` § Waiting for a turn
to end).

## What you are not told

For a task session, everything but its report: it is blocked or in error (the user was alerted, not you), it
exited or crashed (nobody was), its turn ended unreported, it hangs in `working`, or it sits at a prompt that
reports no status or reads as `done` (harness adapter § Gotchas). A terminal without your label is the user's.

## Read a session

`hc read <address> --lines 0` prints the visible screen; `--lines 200` adds that much history. While the session
is `working`, `blocked` or `error`, a history read returns the screen only and says so.

## Message a session

`hc send <address> '<text>'` pastes the text and presses Enter (single quotes keep your shell off its backticks and `$`;
a `'` in it is written `'\''`); an agent receives it tagged with your address, mid-turn when it is working. It exits 0
and prints `started`, `status` and `turn` as they were at the send, such as `{"started":true,"status":"done","turn":1}`,
or a sentence when its output is a terminal (`--json` forces JSON): the text is submitted, and the answer is still to
come. Send only to a session you have seen at its prompt (`herdr/gotchas.md` § A picker that is not a dialog takes a
send's Enter); a person's draft there goes in front (`herdr/gotchas.md` § A draft left in the input goes in front of a
message). Long content travels as a file path. A worker reports to you with the same command (§ How you learn a session
finished).

## Close a session

`hc kill <address>` ends the program and its tab closes. Its record stays listed as `finished` (`reason: killed`, and
`exit_code: 129` for Claude Code, `exit_code: null` with `signal: 1` for Codex, `exit_code: 0` for agy) with its last
screen readable. Read what you still need from it, then remove it with `hc rm <address>`: a session is closed once the
listing no longer shows it. A session that exited by itself needs the `rm` as well. Close only sessions you launched:
the addresses the task record holds, carrying your label and no `laima.adopted`. A session with your label that no
record names is unknown: tell the user, and leave it. Close an adopted one only when the user asks. The core and the
window are the user's: leave `hc server` alone, and use `herdr-app` only as `ls`, `status` and `do`.

## What the user is notified of without you

Herdr plays a sound and shows a toast for an agent with a tab and no parent (every task session, and you) when
it becomes `blocked` or `error`, and when its turn ends while the user is not looking at it. So your own question
or turn end is the alert. It is silent about exits, crashes and prompts that report no status *(read, not run)*.

## After a reboot

Closing the window ends nothing; the core keeps every terminal. A reboot, logout or core crash ends every agent:
a task session's tab returns as a plain shell at the same address, its command is not run again *(read, not run)*.
First work out from each open task's record which step it is at. Only where that step still needs its session, close
the leftover shell of a session you launched, when one is listed, and start a task session again with the harness
adapter's § Resume from a session id as the argv, in the same folder, with your current address in the first
message. Record the new address. An adopted session is the user's to restart. When an id cannot be resumed, launch a
fresh session of that role with a brief built from the record.

## Gotchas

The Herdr facts a session outside Laima needs as well are in `herdr/gotchas.md`, each under its own heading:
- § A subagent inside your harness acts as you.
- § A draft left in the input goes in front of a message: a draft left in your input goes in front of a report.
- § A send to a session still starting can fail.
- § A picker that is not a dialog takes a send's Enter.
- § Waiting for a turn to end: no one `status` or `turn` value says a turn ended.
- § A preset named like a program starts in its place: a preset named `claude`, `codex` or `agy` takes the
  launch.
- § `hc run` finds a program on the server's PATH, not yours: a harness installed through a version manager needs
  your PATH handed to it.
- § `tab.new` makes a peer without labels, inside a shell: start task sessions with `hc run` as above.
