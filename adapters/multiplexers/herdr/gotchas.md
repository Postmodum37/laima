# Herdr gotchas

Shared pitfalls for Laima's adapter and the companion skill. For general use see `hc --skill` and `herdr-app --skill`.

## A subagent inside your harness acts as you

A subagent or teammate inside your own harness inherits `$HC_TERMINAL_ID`: its `hc` commands act as you, and what
it starts becomes your child.

## A draft left in the input goes in front of a message

A draft the user left unsent in a terminal's input is submitted in front of a message sent there, as
`draft<hc from=…>`. Text before the tag is theirs: give it back to them, and take the message from the tag.

## A send to a session still starting can fail

`hc send` to a session still starting waits for it and delivers when it is ready within moments; otherwise it fails
with exit 5 and types nothing. Retry a refused send once the session has settled.

## A picker that is not a dialog takes a send's Enter

hc refuses to send to a `blocked` terminal, but a picker or menu that is not a dialog (Claude Code's `/model`, a
list of slash commands) reports no block, and the send's Enter chooses in it: a send into an open `/model` picker
saves a new default model in the user's settings. Send only to a terminal you have seen at its prompt.

## Waiting for a turn to end

A turn counter can advance at a dialog or on Codex startup. Work can also be about to start when a wait says
`ended: true`. Even an old message to the caller can wake a new wait while the target still works. Claude Code
and agy can stay `working` until a background command ends, so a turn wait also waits for that command.

If the agent will report with `hc send`, end your turn and let the report start the next one. If you need to read
the result yourself, use [turn-wait](scripts/turn-wait) beside this file. With text it sends and waits for the
resulting turn. Without text it waits for current work, including work about to start after a dialog. Run a long
wait as a background command so the user and incoming reports can reach you. For JSON fields, timing and
harness-specific transitions, see [Waiting and wakeups](reference.md#waiting-and-wakeups).

## A preset named like a program starts in its place

hc matches the first word of a launch's argv against the preset names (`hc templates`) before programs, so a preset
named `claude`, `codex` or `agy` starts instead of the harness and sends the flags after it as message text. The
launch output's `template` field shows a match. Whether a launch with `--` before the argv is matched as well is
*(read, not run)*. Give presets names no program uses.

## `hc run` finds a program on the server's PATH, not yours

`hc run -- <program>` looks the program up on the PATH of the hc server, which started with the app, and not on the
PATH of the shell that runs `hc run`. A program your shell finds only through a version manager's shims or a PATH set
in a shell profile fails with `spawn_failed`, `cannot start "<program>": No such file or directory`, and nothing
starts. Hand your PATH to it: `hc run ... -- /usr/bin/env PATH="$PATH" <program> <args>`. A program in a folder the
server's PATH holds starts as given.

## A space closes with its last tab, and one without a name renames itself

Closing a space's last tab closes the space, so a space made for some sessions is gone, id and all, once they end.
`herdr-app do space.new` without `--argv` opens the space with a shell tab in it. A space made without `--name` is
called after the folder of its first terminal and takes a new name when another terminal comes first, while its
`folder` stays: a space shown as one project's can hold another's tabs. Give every space you make a name.

## A tab moves to another space only by parking its terminal

`tab.move` reorders tabs within their space (its arguments are `id`, `index` and `by`), and `hc label <t>
herdr.space=<sp>` on a terminal that has a pane changes the label but leaves the tab where it is. To move a running
terminal, take its pane away, relabel it, and give it a pane again:

```sh
herdr-app do terminal.park --terminal <t>
hc label <t> herdr.space=<target-space-id>
herdr-app do terminal.keep --terminal <t> --place tab
```

It keeps its address and stays live. `terminal.keep` shows the target space in the window and takes no focus
argument, so tell the user before you move one; `terminal.park` also turns off the terminal's `--keep`. How a
harness's screen comes through the move is not known.

## `tab.new` makes a peer inside a shell

Pass an explicit `--space <sp>` from `herdr-app ls` when targeting your own space. By default the tab goes in the
space selected in the window. Use `--focus false` to keep the view where it is.

The terminal can have app placement labels (`herdr.space`, `herdr.tab`; see L2 in [evals](evals/cases.md)). The tab
name is separate from the hc terminal name, and Laima's tags need explicit handling. The agent runs inside a shell:
its exit can leave a live prompt (`agent: zsh`). The task is an argv argument, so `hc wait` can return `idle` while
the agent is still starting or working.
