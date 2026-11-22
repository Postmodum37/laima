# cmux gotchas

Facts about cmux that both Laima's task steps and a session working with cmux on its own have to know. Each has its
own heading, so that the cmux adapter and `SKILL.md` can point to it where it applies. `cmux --skill`, `cmux help
<topic>` and `cmux <command> --help` hold the general use, and this file only what they leave out. *(read, not run)*
marks a fact taken from cmux's help or its docs only.

## Only a process started in a cmux terminal reaches the app

On a default cmux (`automation.socketControlMode: cmuxOnly`) the app answers only processes started inside one of
its terminals; from anywhere else every command that needs the app fails with `Access denied - only processes
started inside cmux can connect`. `--help`, `help`, `--skill`, `--version`, `docs`, `sessions` and `socket-status`
answer from anywhere, the app closed included. Outside its terminals `cmux` is not on the PATH; it is
`/Applications/cmux.app/Contents/Resources/bin/cmux`. `cmux socket-status --json` shows the mode; changing it is the
user's decision.

## Every target defaults to your own surface

A command that takes `--workspace` or `--surface` falls back to `$CMUX_WORKSPACE_ID` and `$CMUX_SURFACE_ID`, so
`cmux send "x"` types into your own prompt and `cmux close-surface` closes you. An empty or `null` value falls back
too: `input_state` with an empty id reports your own state. Name the target on every command aimed at another
session, and check that a variable holding it is set. A subagent or teammate inside your harness inherits both
variables, so its cmux commands act as you.

## A `--command` over 1,023 bytes is cut and left unrun

`--command` is typed into the new terminal's interactive shell and followed by Enter. A typed line holds at most
1,023 bytes: a longer one is cut there, loses its Enter and sits unrun at the prompt. Keep a brief in a file and the
command short.

## `cmux agent claude` and `cmux agent codex` start the agent on a cloud machine

`cmux agent <claude|codex> -- "<prompt>"` runs the agent on a cloud machine (`cmux agent --help`). Only `cmux agent
message`, `inbox`, `messages`, `hibernate` and `wake` act locally. Start a local agent with `cmux workspace create
… --command`.

## cmux's `agy` wrapper writes hooks into the user's agy configuration

In a cmux terminal `agy` is cmux's wrapper: it runs `cmux hooks agy install --yes`, then the real agy, print mode
included. The install writes cmux's hooks into the user's own `~/.gemini/config/hooks.json`, where they stay, unlike
the Claude Code wrapper's settings, which hold for that one session. The hooks give agy its state and messages under
cmux. `CMUX_ANTIGRAVITY_HOOKS_DISABLED=1` before `agy` skips the install; hooks an earlier run already wrote stay,
and `cmux hooks agy uninstall` takes them out, a change to the user's configuration that is theirs to make.

## cmux's `codex` wrapper skips Codex's hook-trust review

In its terminals cmux wraps `claude` and `codex` to add the hooks that report state and deliver messages. The
`codex` wrapper also skips Codex's review of which hooks to trust, so the user's and the project's hooks run
unreviewed *(read, not run)*. Where the user or the project relies on that review, ask before you start Codex in
cmux.

## Read a Codex screen without `--lines`

For a Codex session, `cmux read-screen --surface <surface> --lines N` returns only its prompt and status lines, while
the plain visible read shows the conversation. Name the surface: `--workspace` alone reads the surface cmux picks,
which in a workspace of several can be a blank one.

## Some agents never receive messages

A message never arrives at a headless run (`claude -p`, `codex exec`), at a Codex whose hooks come from `cmux hooks
codex install` in place of the wrapper, or on a cloud machine *(read, not run)*. `cmux agent messages status
<target>` says whether messaging is on there; when it is off, the send fails and stores nothing *(read, not run)*. A
Codex launch can come up without a row in `cmux sessions`: it then reports no state and takes no messages, so follow
it by its screen and start its turns with `cmux paste --surface <surface> --submit '<text>'`.

## An idle Codex is not woken by a message

An idle Codex gets a message only when its turn ends or with the next prompt submitted. To put an idle Codex to
work, run `cmux paste --surface <surface> --submit '<text>'`; the queued messages ride along with that prompt, so
to an idle Codex paste only, or it gets the request twice. After a turn, Codex can run a background memory pass
under the same surface that claims a message: it shows `delivered` and never reaches the visible session, while
`input_state` reads `running` and the screen sits at the prompt. For a Codex, `delivered` does not prove the session
saw it: read the screen, and repeat by `paste --submit` when it did not.

## A busy Claude Code sees a message between tool calls or at its turn's end

An idle Claude Code wakes for a message within a second or two, as a new turn. A busy one sees a message sent
during one of its tool calls when that call returns; one sent while its own question dialog is open, only when its
turn ends; several sent during a long turn arrive together at its end. `delivered` in the inbox means cmux handed
the message to the agent's hooks, not that the agent read it.

## A message over about 3.5 KB given as an argument is lost

A 4,000-byte body given to `cmux agent message` as an argument ends with `Socket closed before reply`, exit 1 and
nothing queued. The same body on stdin (`-` in place of the text) is queued. Keep an argument under 3.5 KB, and send
longer text as a file path or on stdin.

## `waiting_on_human` can stay set after a dialog is answered

`cmux rpc surface.input_state` can show `waiting_on_human` for a few seconds after a dialog was answered: confirm on
the screen.

## `--paste` and `--force` go before the text

On `cmux send`, flags after the text are typed as text.

## Text left at a plain shell's prompt joins what you send next

A plain shell is never guarded: text left at its prompt is joined to whatever you send there next. Clear it with
`cmux send-key --surface <surface> ctrl+u`.

## Each hook event is published twice

Each `cmux events` hook event comes twice: match on `surface_id` and take the first. cmux appends the same events to
`~/.cmuxterm/events.jsonl`, where a missed `Stop` or `SessionEnd` can be looked up.

## Waiting on one session's turn end

`cmux events --limit 1` returns on the first turn end of any session, and run again after another session's it can
miss the one you wait for. To wait on one surface, read one stream until its line. This returns at the first Stop
from that surface, with exit 0; after `<seconds>` without one it returns with exit 4, also when other agents ended
turns in that time, and a cmux error gives exit 4 at once:

```sh
jq -n -e --arg s <surface-uuid> 'first(inputs | select(any(.. | objects; .surface_id? == $s))) | .name' \
  < <(cmux events --name agent.hook.Stop --no-ack --no-heartbeat --timeout <seconds>)
```

The `< <(...)` matters: in a plain pipe the command returns only when `cmux events` reaches its timeout. Start it
before you send the key or message that leads to the turn end, since a turn can end within seconds of it, and run it
as a background command.

## A session row outlives its workspace

`cmux sessions --all --json` rows are saved records read from disk: a closed workspace's row stays, with
`stored_pid_exists: false`, so trust a row only when the tree lists its surface. Read `agent_lifecycle` there, since
`runtime_status` stays `idle` through running turns and open dialogs.

## `overloaded` never ran; `timeout` may have

A command answered with `overloaded` never ran, and the CLI retries it. One answered with `timeout` and
`retryable: false` may have run *(read, not run)*: look at the tree before you repeat a create or a close.
