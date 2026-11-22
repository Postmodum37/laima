# herdr eval cases

A re-verify session runs these after `scripts/drift` exits 1, from inside a Herdr terminal, on terminals and tabs
it creates and closes itself. Addresses and ids below are examples; a run gets its own. Probe folders: a fresh
`mkdir` under `/tmp`, or a folder Claude already trusts.

## Trigger

| Case | Run | Pass when |
| :- | :- | :- |
| T1 "open a new tab next to me running another claude session to look at the flaky test, and tell it to report back to me" | With this skill installed for the user, from an empty directory inside a Herdr terminal: `claude -p "<prompt>" --tools Skill Read --strict-mcp-config --no-session-persistence --max-turns 3 --output-format stream-json --verbose < /dev/null` | The first tool call is `Skill` with `herdr` |

## L1 Child round trip and the trust dialog

1. `mkdir -p /tmp/hc-probe; hc run --bg --name hc-probe --cwd /tmp/hc-probe claude "Run exactly: hc send $HC_TERMINAL_ID 'pong' — then stop."`
   (double quotes: the parent's address is expanded before launch).
2. `hc wait --children any`. Pass: `status: blocked`; `hc get hc-probe` shows msg `trust this folder`.
3. `hc read hc-probe --lines 0` shows the trust prompt; `hc keys hc-probe down enter`.
4. `hc wait --children any`. Pass: `reason: message`, and `<hc from="tN hc-probe">pong</hc>` arrives as input.
5. `hc kill hc-probe; hc rm hc-probe; rm -rf /tmp/hc-probe`.

## L2 Peer tab, sends both ways

1. `herdr-app do tab.new --name probe --folder <trusted dir> --argv '["claude"]' --task "Run exactly: hc send <your tN> 'pong' — then stop." --focus false`.
   Pass: `{space, tab, terminal}`; `herdr-app status` still shows the old tab. Without `--space` the tab goes to the
   space selected in the window, not the caller's.
2. `hc get <t>`. Pass: `parent: null`, labels `herdr.space`/`herdr.tab`, argv wrapped in `zsh -lic … exec zsh -li`.
3. `hc wait <t>`. Pass: `reason: message`, the pong arrives as input. While the peer boots, `hc wait` can return
   `idle` first; wait again.
4. Needs the peer to run `hc send` unprompted: not in auto mode, or `Bash(hc send:*)` allowed in
   `~/.claude/settings.json`; otherwise auto mode blocks the reply (L5).
   `hc send --wait <t> "Run exactly: hc send <your tN> 'pong2' — then stop."`. Pass: `status: done`, pong2 arrives.
5. Read the peer's screen, then `herdr-app do tab.close --id <tb> --confirmed true`. Pass: `ok`; `hc ls --all` keeps
   `<t>` as finished (`reason: killed`); `hc rm <t>`.

## L3 Promote a child; adopt by labels

1. `hc run --bg --name promo --cwd /tmp zsh`, then at once `herdr-app do terminal.keep --terminal <t> --place tab`.
   Observed: `no running terminal "<t>"` when sent before the app saw the child; a retry after `herdr-app ls`
   lists it under `sub_agents` returns `{pending: true, pane, tab}`.
2. Pass: `herdr-app ls` shows a tab named after the terminal; `hc get` shows `keep: true`, `parent` still you,
   `die_with_parent: true`; `herdr-app status` shows the new tab focused.
3. `hc run --bg --no-parent --name adopt --cwd /tmp --label herdr.space=<sp> zsh` (no `herdr.tab`, the documented
   form). Pass: a new tab (named by its number) holds it; `herdr-app status` keeps the previous tab.
4. `hc kill` both. Pass: both tabs close; `hc rm` both.

## L4 No notify command

`herdr-app do notify '{"title":"x"}'` and `herdr-app do toast.show '{"title":"x"}'`. Pass: both answer
`unknown command … a mod's are <mod>.<command> and need the mod loaded`.

## L5 Auto mode blocks replies requested over hc

Needs `defaultMode: "auto"` in `~/.claude/settings.json` and no allow rule for `hc send`. The target is a peer, as
L2 makes it; a child of the sender is not blocked.

1. Run L2 steps 1–3 (the launch-task reply arrives).
2. `hc send <t> "Run exactly hc send <your tN> 'pong2' and stop."`, then `hc wait <t>` and `hc read <t> --lines 0`.
   Pass (the fact holds): the screen shows `Blocked by auto mode` / `Unsanctioned Communication`, and no pong2 arrives.

## L6 Launch modes (Claude and Codex, bypass and plan)

One fresh git repo per probe in a scratch folder. Launch as children:

- `cl-bypass`: `claude --dangerously-skip-permissions "Create bypass.txt containing ok, then run: hc send $HC_TERMINAL_ID '…done'"`.
- `cl-plan`: `claude --permission-mode plan --allow-dangerously-skip-permissions "Plan adding hello.py …; three lines."`.
- `cx-normal`: `codex --no-daemon --dangerously-bypass-approvals-and-sandbox "<same as cl-bypass>"`.
- `cx-plan`: the same Codex launch without a brief.

1. Trust prompts: Claude shows `blocked`/`trust this folder`, Codex shows no status. Pass: the default selection is
   read before `enter` (it can be *Yes* or *No, exit*).
2. Bypass probes report via hc; then `hc send` each a follow-up asking for a second `hc send`. Pass: both replies
   arrive (no auto-mode block); footers show `bypass permissions on` and `YOLO mode`.
3. `hc send cx-plan "/plan"`. Pass (the fact holds): the screen shows `<hc from="tN">/plan</hc>` as a prompt and
   no mode change. Interrupt it, then `hc keys cx-plan / p l a n` and `enter`. Pass: footer `Plan mode`. Then
   `hc send` the brief.
4. cl-plan: status `blocked`, plan and its `~/.claude/plans/…` path on screen. Select *Tell Claude what to
   change*, `hc send --force` feedback. Pass: a revised plan with the feedback appears. Select *Yes, and switch to
   BYPASS PERMISSIONS*, `enter`. Pass: `hello.py` exists and runs; the first `hc wait` right after the
   answer may return the old `blocked`.
5. cx-plan: Pass: *Implement this plan?* with status `done`; `enter` on *Yes, implement this plan* builds
   `hello.py`, and the footer returns to Default.
6. `hc keys cl-bypass shift+tab` five times. Pass: bypass → auto → manual → accept edits → plan → bypass.
7. Kill and `hc rm` the four, delete the repos, remove their `[projects."…"]` entries from `~/.codex/config.toml`.

## L7 Presets

Needs presets in `hc templates` for a read-only review and a bounded change on Claude in bypass, a Claude planner,
and a bounded task on Codex in bypass, named so no program shares the name (`gotchas.md` § A preset named like a
program starts in its place). The steps call them `reviewer`, `implementer`, `planner` and `codex-task`.

1. `reviewer` and `codex-task` in a folder both agents already trust, with a read-only review task. Pass:
   `first_message.sent: true`, each reports via `hc send` to the launcher's address.
2. `implementer` and `planner` in fresh scratch repos. Pass (the fact holds): `first_message.sent: false`, reason
   `blocked (permission)`, `hc get` keeps only the reason. Answer the trust prompt, send body + task by hand
   (SKILL.md § Presets). Pass: the implementer reports a verified change; the planner shows a plan dialog whose
   plan follows the preset's shape; approving *Yes, clear context … bypass* builds it.

## L9 Nesting

`hc run --bg --name nest1 --cwd /tmp zsh`; `hc send nest1 "hc run --bg --name nest2 --cwd /tmp zsh"`. Pass:
`hc get nest2` has parent `nest1`'s address; `hc kill nest1` leaves both `finished`/`killed`.

## L10 Codex hook trust after editing hooks.json

1. Remove or add a hook before an existing one in `~/.codex/hooks.json`.
2. Start `codex --no-daemon …`. Pass (the fact holds): *Hooks need review — 1 hook is new or changed*, status null.
3. Move the shifted hook's `[hooks.state."…:<event>:<old>:0"]` key to its new index in `~/.codex/config.toml`
   (hash unchanged). Pass: the next start reaches `Ready` with no prompt.

## L11 What a wait sees across a turn; `scripts/turn-wait`

Probes started with `--no-parent --label wp=1` in a scratch folder under a folder both harnesses trust: a Claude
on a small model (`--model <model> --effort low`, bypass) as caller, a second as target, one in default mode for a
dialog, a Codex (`-m <model> -c model_reasoning_effort=low`), and a `cat` terminal as a test lead whose `HC_*`
values a shell sources to act as it. In the background, `hc events --json --label wp=1` with a timestamp on each line.

1. `hc send --wait --json` to each target. Pass (the facts hold): Claude goes `working` → `done` with a `turn`
   event; Codex goes `idle` (input) → `working` → `done`; the top level holds the status and turn from before the
   send, `wait.turn` the new one.
2. Plant a wakeup: send the caller a task (a 12 s `perl` pause), message it mid-turn, let it finish. Then, as the
   caller, `hc send --wait --json` to a target. Pass (the fact holds): it returns within 0.3 s with
   `wait.reason: message`, `ended: false`, while the target works.
3. As in 2, then `scripts/turn-wait <target> "<text>"` as the caller. Pass: exit 0 at the target's `turn`
   event, on Claude and on Codex.
4. `scripts/turn-wait` with a text whose turn stops on a dialog (a command that needs permission in default
   mode, or a question the agent asks). Pass: exit 9 with the dialog's `status.kind`, though `turn` has counted
   up; without text on the blocked terminal, exit 9 after the 3 s it gives work to show; with text, hc refuses
   the send and its message is printed, exit 9.
5. Without text on a target that is working: exit 0 at its turn's end; on one at rest (`done`, or a Codex at
   `idle`): exit 0 after 3 s; on a plain shell: exit 1. `TURN_WAIT_MAX=3` on a 14 s turn: exit 124 after about 3 s.
6. On a Codex at `done`: `hc read --lines 0`, then `--lines 40`. Pass (the fact holds): the first leaves `done`,
   the second makes it `idle` with `turn` unchanged; a Claude stays `done`.

7. With text to a target that is working, and to a plain shell. Pass: exit 1 with the reason on stderr, and the
   text does not appear on the target's screen.
8. Without text right after a dialog is answered (a question dialog; the trust prompt of a new folder), and
   right after an `hc send` of your own. Pass: exit 0 at the end of the work that follows, not before.
9. With a stand-in `hc` first on `PATH` (a script that answers `get`, `send` and `wait`): a text that starts no
   turn, exit 1 after 30 s; a target that always reads `working` while `wait` returns at once, with
   `TURN_WAIT_MAX=3`, exit 124 after fewer than a dozen `get` calls; `get` failing, exit 1; `send` refused with
   exit 10, exit 10 with hc's message; a target in `error`, exit 1 with nothing sent. With no `jq` on `PATH`:
   exit 2. Every exit but 0 gives its reason on stderr.

## L12 A fresh lead waits the way `gotchas.md` § Waiting for a turn to end says

A Claude lead (`--model <model> --effort low`, bypass) in the scratch folder, with a wakeup planted as in L11 step 2.

1. Send it: "There is a Codex session in hc named <codex>. Ask it: 'What is 17 times 3? Reply with only the
   number.' Then tell me the number it gave." Pass: it loads `herdr`, runs `scripts/turn-wait`, reads the reply
   and answers within seconds of the Codex turn's end; no loop of its own.
2. Send it: "Start a helper Claude session … run a 20 s pause and then `date`, and report the time to you with hc
   send. When its report comes, tell me the time it gave, then close the helper." Pass: its turn ends right
   after the launch, and the report starts its next turn, in which it answers and closes the helper.

A Codex lead (`-m <model>`, low effort) with Claude helpers runs the same steps.
