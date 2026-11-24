# Herdr reference: orchestration API and window behaviour

For the advanced cases linked from [the skill](SKILL.md). Source pins are herdr-core v0.1.21 (`1b0393f`) and
herdr-app v0.1.16 (`034f8b8`) unless stated otherwise. *Source* means read in that code and *live* means reproduced
on a Mac running those versions. The skill's `Verified:` line covers newer installed versions.

## Watching many terminals: `hc events`

- Use the stream for a multi-terminal consumer, in the background. See `hc events --help` for filters.
- The first JSON line is a snapshot `{channel, seq, terminals:[full records]}` (live). Later lines are
  `{method:"event", params:{seq, type, terminal, data}}`, with `heartbeat` (about every 15 s) and `missed` (source).
  Keep a map by address. Replace it from the snapshot on reconnect or from the terminals supplied with `missed`.
- Event types are `created`, `restarted`, `lost`, `finished`, `removed`, `keep`, `status`, `turn`, `title`, `size`,
  `foreground`, `labels` and `doc` (source). Working agents emit many `title` events. Drop them when tracking status.
- There is no message, output text or launch-delivery receipt in the stream. Collect results from reports.
- `hc ls --json` has compact records. Use `hc get` or the snapshot for fields such as pid, labels and foreground (live).

## Waiting and wakeups

For choosing when to wait, see [Gotchas](gotchas.md) § Waiting for a turn to end.

- `hc send --wait --json` puts pre-send `started`, `status` and `turn` at the top level and the wait result under
  `wait`. For a plain shell `started` is null and status is absent. A send to a working agent joins its current turn.
- `hc send --if idle` refuses a Claude Code session at `done` with exit 10 (`status_mismatch`).
- Work can take half a second to show after a dialog. `turn-wait` without text allows 3 s for it to show.
- Claude Code rests at `done`. Codex starts with its own turn (`turn: 1`) and settles at `idle`. After a message
  it settles at `done`, then input or a history read moves it to `idle` with the same turn count. A screen-only read
  leaves it at `done`.
- Sending to a working agent registers a wakeup regardless of the sender's state. Several wakeups coalesce. A
  `--children` wait can return child results and a sender in `from` together. Read both (source).
- An unreachable machine's children can drop out of the result (source). `hc get` or `hc read` of your own child
  marks its news seen. An events subscription leaves it unseen (source).

## Notes and delivery settings

hc types automatic notes into a parent when a child blocks, errors or exits with unseen news. The parent must
report status. There is no note for `done`, while the parent waits on the child, or once the parent has seen the news
(source). `--no-notify` suppresses the child's notes and keeps explicit send tags.

In `~/.config/herdr-core/config.toml`, `notes_quiet` defaults to 3 s of keyboard quiet before an automatic note.
`notes = false` suppresses automatic notes and strips `<hc>` tags from sends and preset messages, losing sender
provenance. See `hc --skill` for other delivery settings.

## Presets (templates)

- Use `hc --skill` for launch, readiness timing and `first_message.sent`. In frontmatter, `command` runs with
  `sh -c` and the filename supplies the name. `ready`, `submit`, `stop`, `paste_gap_ms` and `description` are honoured.
  `name`, `model`, `cwd`, `env` and `labels` are ignored. Pass model and env in `command`, cwd and labels on
  `hc run` (source, `templates.rs:60`).
- `ready: quiet` waits for output then silence and can type into a startup dialog without a status (source).
  `hc run --bg` with a preset returns after the first-message attempt. The preset message gets a `reach=` tag when
  both ends report status (source and live).
- After a failed first send, resolve the prompt and wait for readiness. Send the trimmed preset body, a blank line
  and the original task arguments joined by spaces. `hc get` only stores the failure reason (source and live).

## Status

`status` can carry `app` and `progress` (0–100). Programs report by writing OSC 7501 to their own TTY (source and
isolated live test). The core has no status-setting RPC.

## Lifetime and recovery

A child that outlives its parent retains its `parent` field. With a pane it gains a top-level row. Without a pane
it disappears from the window and stays reachable through hc (isolated live test). Closing a pane, tab or space
ends the terminals inside it; a child with `--outlive-parent` outside it survives. `herdr-app do terminal.kill`
also ends the terminal's hidden descendants that have no pane and no `herdr.space` label, outliving ones included
(live test, herdr-app 0.1.18). See § Window: attention and navigation (herdr-app) for alerts and `hc --skill` for
kept terminals and saved screens.

## Identity and environment

- A send from outside Herdr without `HC_*` variables arrives without an `<hc from=…>` tag. Have that sender
  identify itself in the text (live).
- For launch environment variables, prefix the program argv in `hc run` with `env K=V`. The API's
  `terminal.run` accepts `env` directly.
- `doc.get` and `doc.set` are API methods for versioned JSON documents.

## Window: attention and navigation (herdr-app)

- An agent with a pane and no parent sounds when it blocks or reports an error, even on screen. A turn ending
  sounds only off screen. Toasts for those events appear only off screen. A child gets no toast, even with a
  pane or after its parent ends. Silence for the child's sound is inferred and awaits a live check.
- A blocked child gets a "Needs you" badge and raises its parent's rank in the sidebar. With a tab it adds to
  the status bar's "needs you" count and marks its tab pill with a red dot.
- Looking at a `done` agent can make it `idle` in `herdr-app ls` while `hc get` still reports `done`.
- Keep whole-window screenshots local. They include every visible terminal. Change the user's scroll position,
  selection or clipboard only when asked.

## Window: mods

Use the installed app guide and adjacent declarations for APIs and settings. Read each collection
(`terminals()`, `agents()`) once per render. Renders follow data changes, so polling adds work. Guard process
and file side effects with `checking()` as the guide describes. Cloned layouts stop following upstream `main`.

## Worktrees

For a different base ref, create the checkout with git first, then open that folder with `herdr-app do space.new`
if the user wants it visible. New worktree branches from the current checkout's HEAD.

Remove worktree refuses the main checkout and a locked worktree, and forces a dirty one after a warning. It then
closes the worktree's space, waits up to 10 seconds for its terminals to stop, and runs git, so a late git refusal
leaves the space closed and the checkout in place. *Source*, herdr-app v0.1.18.

## From cmux

- `agent inbox` queues a message for reading. Here `hc send` pastes into the live input. Reply to the `reach=` address.
- `rpc terminal.replay` returns cursor and style data. Here `hc read` returns text.
- For `notify`, see [the skill](SKILL.md) § Reaching the user. The app exposes notification calls only to mods.
