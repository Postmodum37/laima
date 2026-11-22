# Herdr gotchas

Facts about Herdr that both Laima's task steps and a session working with Herdr on its own have to know. Each has
its own heading, so that the Herdr adapter and `SKILL.md` can point to it where it applies. `hc --skill` and
`herdr-app --skill` hold the general use, and this file only what they leave out. *(read, not run)* marks a fact
read in code or help and not run.

## A subagent inside your harness acts as you

A subagent or teammate inside your own harness inherits `$HC_TERMINAL_ID`: its `hc` commands act as you, and what
it starts becomes your child.

## A draft left in the input goes in front of a message

A draft the user left unsent in a terminal's input is submitted in front of a message sent there, as
`draft<hc from=…>`. Text before the tag is theirs: give it back to them, and take the message from the tag.

## A send to a session still starting can fail

`hc send` to a session still starting waits for it and delivers when it is ready within moments; otherwise it fails
with exit 5 and types nothing. Put the first task in the launch itself, and send again once the session has
settled.

## A picker that is not a dialog takes a send's Enter

hc refuses to send to a `blocked` terminal, but a picker or menu that is not a dialog (Claude Code's `/model`, a
list of slash commands) reports no block, and the send's Enter chooses in it: a send into an open `/model` picker
saves a new default model in the user's settings. Send only to a terminal you have seen at its prompt.

## Waiting for a turn to end

No single `hc get` or `hc wait` result says that the turn you started has ended:
- `turn` counts up each time the agent stops working: at a turn's end, and also when it stops on a dialog
  (`blocked`). Codex's startup is a turn of its own, so it starts at `turn: 1`.
- The status a turn ends on differs by harness: Claude Code `done`; Codex `done` after a message and `idle` after its
  startup. A Codex at `done` turns `idle`, with `turn` unchanged, on any input, a history read (`hc read --lines
  40`) included; `--lines 0` leaves it `done`.
- `hc wait <t>` returns at once, with `ended: true` and the last status, when the target is not working: right
  after a send, before work shows, and right after you answer a dialog. `ended` does not mean a new turn ended.
- `hc wait` and `hc send --wait` also return on any message to you and at their check-in, as `hc --skill` says.
- A message typed into you while you worked leaves a wakeup, and the next wait you run returns on it at once, however
  long ago it came.
- `hc send --wait --json` prints the target's status and turn from before the send at the top level; the wait's
  result is under `wait`.

So wait with `scripts/turn-wait` beside this file, the one tested way to tell that a turn ended: with text it sends
the text and waits for the turn that text starts; without text it waits for the turn running now. Its header gives
the arguments and what each exit means. Run it as a background command when the turn can take more than a minute,
since a foreground wait holds your turn and every message to you waits behind it. A session that will report to you
with `hc send` needs no wait: end your turn, and its report starts your next one.

## A preset named like a program starts in its place

hc matches the first word of a launch's argv against the preset names (`hc templates`) before programs, so a preset
named `claude`, `codex` or `agy` starts instead of the harness and sends the flags after it as message text. The
launch output's `template` field shows a match. Whether a launch with `--` before the argv is matched as well is
*(read, not run)*. Give presets names no program uses.

## `tab.new` makes a peer without labels, inside a shell

`herdr-app do tab.new` also starts a peer in a tab of its own, but it sets no label or name, wraps the program in a
shell (an exit then leaves the tab at a prompt, shown as `agent: zsh`, not `finished`), and moves the user's view
unless given `--focus false`. Its task is a command-line argument, not an hc launch task, so `hc wait` can return
`idle` while the agent is still starting or working.
