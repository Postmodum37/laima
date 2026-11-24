# Herdr reference: orchestration API and window behaviour

Reached from `SKILL.md` when you watch many terminals, tune delivery, write a preset or a mod, reason about
attention, recovery or worktrees, or translate a cmux command. Versions as in `SKILL.md`'s `Verified:` line.
Sources: herdrdev/herdr-core v0.1.21 (`1b0393f`) and herdrdev/herdr-app v0.1.16 (`034f8b8`) on GitHub. *Source*
means read in that code; *live* means reproduced on a Mac running those versions.

## Watching many terminals: `hc events`

- `hc events --json [--children-of <t>] [--terminal <t>] [--label k=v]…` streams one JSON object per line. The
  first is a snapshot `{channel, seq, terminals:[full records]}` (live). Later lines are
  `{method:"event", params:{seq, type, terminal, data}}`, plus `heartbeat` (about every 15 s) and `missed`
  (rebuild from its `terminals`) (source).
- Event types: `created`, `restarted`, `lost`, `finished`, `removed`, `keep`, `status`, `turn`, `title`, `size`,
  `foreground`, `labels`, `doc` (source). Keep a map by address; replace it on `missed` or reconnect.
- Working agents emit many `title` events; drop them.
- The stream carries no messages, no output text and no launch-delivery receipt: collect results from reports.
- `hc ls --json` has only address, agent, cwd, state, status, turn and where; full records (pid, labels,
  foreground) come from `hc get` or the events snapshot (live).
- Run a long-lived `hc events` reader in a background process, never in your foreground shell.

## Waiting and wakeups

What a wait sees across one turn, beyond [`gotchas.md`](gotchas.md) § Waiting for a turn to end, which says what to
run instead.

- After a dialog is answered, work shows within half a second, and an `hc wait` in that gap returns at once with
  `ended: true`. `turn-wait` without text waits 3 s for work to show before it reports that none is running.
- `hc send --json` without `--wait` prints `started`, `status` and `turn` as they were at the send: `started:
  null` and no status for a terminal that reports none (a shell), `status: working` with exit 0 for an agent in
  the middle of a turn. `turn-wait` takes its starting count from it.
- `hc send --if idle` refuses a Claude resting at `done` (exit 10, `status_mismatch`).
- A send to an agent that is working joins the turn it is in: Claude Code takes a mid-turn message as input to that
  turn, and that turn's end is what `send --wait` returns on.
- Any `hc send` to a terminal whose agent is `working` registers a wakeup for it, whoever sent it and whatever the
  sender's state (source; seen live as `reason: message` from finished children). Wakeups from several senders
  coalesce. A `--children` wait can return child results and a `from` together: read both.
- `--children all` treats a silent live program, or one whose launch task is still pending, as working; an
  unreachable machine's children can drop out of the result (source).
- Your own `hc get`/`hc read` of a child marks its news seen; an events subscription does not (source).

## Notes and delivery settings

hc types automatic notes into a parent when a child is blocked, errored or finished and has unseen news, unless
the parent is waiting on it (source). `--no-notify` on a child silences these but keeps tags on its explicit sends.
`~/.config/herdr-core/config.toml` (when absent, defaults apply):

| Key | Default | Effect |
|---|---|---|
| `notes` | true | `false` stops automatic notes **and strips `<hc>` tags** from sends and preset messages. |
| `notes_quiet` | 3 s | Keyboard quiet before an automatic note is typed. |
| `draft_wait` | 60 s | Holds sends and notes while a person's draft is unsent; `0` keeps only the quiet pause. |
| `wait_timeout` | 180 s | Default check-in for `wait`, waited `run` and `send --wait`. |

## Presets (templates)

- Header lines `key: value`; honoured keys: `command` (required, run with `sh -c`), `description`, `ready`,
  `submit`, `stop`, `paste_gap_ms`. `name` is ignored (the filename is the name); `model`, `cwd`, `env`, `labels`
  are ignored: put model and `env K=V` in `command`, cwd and labels on `hc run` (source, `templates.rs:60`).
- First message: trimmed body, a blank line, then the task args joined by spaces, wrapped in
  `<hc from="tN name" reach="hc send tN when done or stuck">` when both ends report status (source and live).
- Readiness waits up to 60 s for the agent's first status report; a reported `blocked` stops delivery. `ready: quiet`
  instead waits for output then about 800 ms of silence, and can type into a silent startup dialog (source).
- `hc run --bg` with a preset returns only after the first-message attempt (source).

## Status

- `hc get <t>` `status`: `state` (`idle|working|done|blocked|error`), `msg`, `app`, and for `blocked` a `kind`:
  `permission`, `question` or `auth`; optional `progress` 0–100 (live: `kind: permission` on trust prompts).
- Claude Code reports natively. Codex reports from its chat loop only, so its startup trust prompt reports nothing,
  and its *Implement this plan?* picker opens after the turn ends as `done` (source, openai/codex rust-v0.170.0).
- A program can report for itself by writing OSC 7501 to its own TTY; there is no status-setting RPC (source and
  isolated live test). Agents report with `hc send` instead.

## Lifetime and recovery

- Killing a parent kills its children, even ones started with `--keep`; `--outlive-parent` children survive with
  their `parent` field intact (isolated live test). Once the parent has gone, one without a pane shows nowhere in the
  window; one with a pane gets a top-level row. Either way it still gets no toast or sound.
- `--keep`: a lost program (crash, reboot, signal) comes back as a shell at the same address, never re-running
  the command; `restore_screen = true` shows its last screen above it, and `hc read` then sees that old text.
- Quitting the app leaves the core and its terminals running (live).

## Identity and environment

- A terminal's address is permanent on its core ("`t7`: this terminal forever"), unlike cmux refs.
- Claude session id: `hc get <t> --json` → `foreground.pid` → `~/.claude/sessions/<pid>.json` `.sessionId` (live).
- Inside a Herdr terminal the agent's environment has `HC_TERMINAL_ID`, `HC_TERMINAL_SOCKET`, `HC_SCOPE` and no
  `CMUX_*` (live).
- `hc send` from a shell outside Herdr (no `HC_*` variables) reaches the terminal, and arrives with no
  `<hc from=…>` tag, so it reads like typed input: have such a sender name itself in its text (live).
- `hc run` has no `--env`: prefix argv with `env K=V` (the API's `terminal.run` takes `env`).
- Labels are exact AND filters on `ls` and `events`; `hc label <t> k=` removes one. Tag a batch with a job label.
- Also available: `hc exec` (no PTY, exact output and exit code, 60 s default), `hc file read|write|edit`
  (remote-capable, all-or-nothing edits), `hc connect` (JSON-RPC over stdio), `doc.get`/`doc.set` (versioned JSON
  documents on the core, API only).

## Window: attention and navigation (herdr-app)

- Sounds and toasts come only from **pane-backed agents with no parent**: entering `blocked`/`error` rings even on
  screen; finishing rings only when off screen; toasts only when the user isn't looking. **A child gets no toast or
  sound**, with a pane or without, and after its parent ended too (toast seen live; sound inferred from the same
  rule, not observed). A blocked child still shows a "Needs you" badge on its row and raises its parent's rank in
  the sidebar; with a tab it also counts in the status bar's "needs you" and puts a red dot on its tab pill. The
  parent agent must notice (hc's note) and tell the user.
- Looking at a `done` agent turns it `idle` in the app (`herdr-app ls`) while `hc get` may still say `done`.
- Agents list order: pinned, then Needs you, Done, Working, Idle; descendants' states raise a parent.
  `terminal.pin --terminal <t> --pinned true` pins a pane-backed agent (label `herdr.pinned`).
- `terminal.peek --terminal <t>` (or click a child row, or Cmd-click an address in terminal text) shows a
  pane-less child over the tab with focus; close with its ×, since Esc reaches the program.
- `tab.settle` in `main` only removes a tab from keyboard tab cycling; its pill and agents stay visible.
- Mac keys: Cmd+P picker, Cmd+] / Cmd+[ next/previous agent, Cmd+Shift+] / [ tabs, Ctrl+1…9 spaces, Cmd+1…9 tabs,
  Cmd+B sidebar, Cmd+Shift+P palette, Cmd+/ key list, Cmd+F search terminal history. Shift+Tab stays with the
  agent TUIs (mode cycling).
- `herdr-app shot` captures the whole window, every visible terminal included: keep the PNG local.
  `terminal.scroll/select/copy` change the user's view or clipboard: only when asked.

## Window: mods

- `terminals()` gives every core terminal with `parent`, raw status report and labels; `agents()` gives pane-backed
  agents with pin/space/tab. Read each once per render; renders follow data changes, so add no polling timer.
- A mod can `run("terminal.peek", …)` and `await hc(["send", …])` from a click; guard side effects with
  `checking()`. A mod runs in `main` only as a kept overlay or a popup (`mod.open`), or in a cloned layout.
- A cloned layout stops following upstream `main`: keep its diff small and port it after each update.

## Worktrees

- New worktree (space menu or tab-bar +) runs `git worktree add -b <branch>` from the current checkout's `HEAD`,
  or opens an existing local branch, under `worktrees.directory` (default `~/.herdr/worktrees/<repo>/<slug>`;
  `feature/x` and `feature-x` share a slug). It opens and focuses a space.
- For another base ref, create the checkout with git first, then `herdr-app do space.new --name <task>
  --folder <checkout> --argv '[…]' --task '<brief>' --focus false` (when the user wants to see it).
- Remove worktree refuses the main checkout and a locked worktree, and forces a dirty one after a warning. On macOS
  and Linux git removes the checkout first and the space's terminals close only once it has, so they stay when git
  refuses; on Windows they close first. *Source*, herdr-app v0.1.17.

## From cmux

| cmux | Herdr |
|---|---|
| `workspace create --command` | `herdr-app do space.new` / `tab.new --argv --task` |
| `tree --all` | `herdr-app ls` (window), `hc ls` (terminals) |
| `read-screen --surface s --lines N` | `hc read <t> --lines N` |
| `send` / `send-key` | `hc send` / `hc keys` |
| `agent message` | `hc send <t>` |
| `notify` | none; see `SKILL.md` § Reaching the user |
| `workspace close --force` | `hc kill` + `hc rm`, or `tab.close --confirmed true` |
| `sessions` | `hc events --json` snapshot, or `hc get` + `~/.claude/sessions/<pid>.json` |
| `agent inbox` (queued, read, `--reply-to`) | none: `hc send` pastes now; reply to the `reach=` address |
| `rpc terminal.replay` (cursor, styles) | none; `hc read` is text |
| selected workspace (`tree`) | `herdr-app status` (`space`, `tab`, `agent`) |
