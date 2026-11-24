---
name: herdr
description: Use when $HC_TERMINAL_ID is set or herdr, hc, a space, tab or pane comes up; before starting an agent or program in another terminal, messaging or waiting on one, reading its screen, closing it, or changing Herdr's window, keys or layout. Not for Laima's own task sessions, which follow her Herdr adapter and her launch and finish skills, nor for a report whose command a brief gives.
---

# Herdr

For Laima's task steps, follow her root instructions and Herdr adapter. For other Herdr work, use the installed
guides and the exceptions below:

- `hc --skill` for terminals, `hc <command> --help` for flags.
- `herdr-app --skill` and `herdr-app commands` for the window.
- `~/.config/herdr-app/AGENTS.md` and the adjacent declarations for settings, layouts, keys and mods.
- [Gotchas](gotchas.md) before starting, messaging or waiting on an agent. [Reference](reference.md) for event
  streams, delivery settings, presets, recovery, attention, mods and worktrees.

When `hc --version` or `herdr-app --version` differs from the `Verified:` line, check the changed tool's
`CHANGELOG.md` (herdrdev/herdr-core or herdrdev/herdr-app) and installed help. Run the affected
[eval cases](evals/cases.md) before relying on changed behavior.

## Addresses

`$HC_TERMINAL_ID` is your core address. Use `herdr-app ls` to map core addresses to app space, tab and pane IDs.
See `hc --skill` for address syntax. For a Claude session ID, get `foreground.pid` from `hc get <t> --json`,
then read `.sessionId` in `~/.claude/sessions/<pid>.json`. Touch only terminals you started or were asked to drive.

## Pick where the work runs

| Want | Use | Lifetime and reach |
|---|---|---|
| Helper whose results you collect | `hc run --bg` or a preset | Child under your row, ends with you. `hc wait --children any` sees it. |
| Unwatched work that outlives you | `hc run --bg --no-parent` | Peer without a tab. |
| Peer the user can watch or take over | `herdr-app do tab.new` with an explicit space, or `space.new` for a new project | Peer with its own tab. See `gotchas.md` § `tab.new` makes a peer inside a shell. |
| Peer in a new tab without switching the view | `hc run --bg --no-parent --label herdr.space=<sp>` | Peer with a numbered tab. Rename by tab ID after mapping the address. |
| Child the user should see now | `herdr-app do terminal.keep --terminal <t> --place tab` | Shows its tab and keeps its parent and lifetime. |
| Child in a new tab without switching the view | `hc label <t> herdr.space=<sp>`, or set the label on launch | Shows it as your child, with its lifetime unchanged. |
| Long command with visible parentage and a shell result | `scripts/child-run <name> [--env VAR]... -- <command>` | Child with merged stdout/stderr and the command's exit code when it ends. |

If `terminal.keep` initially cannot see the address, retry once `herdr-app ls` lists it under its parent's
`sub_agents`, which lists direct children only. For a child that can outlive its parent, see [Lifetime and
recovery](reference.md#lifetime-and-recovery). For a failed program lookup, see [Gotchas](gotchas.md) for PATH recovery.

Run `child-run` in your harness's background. It passes PATH and the named environment variables. Give the command
noninteractive auth since it can still open its TTY despite empty stdin. Stopping the waiting call stops its child.
agy backgrounds shell calls after at most 10 s. See the [script header](scripts/child-run) for cancellation,
signals, spool recovery and PID edge cases.

## Agent launch: permissions and plan

Choose the permission mode the task authorizes. Use the harness's help and adapter for flags and mode cues.
Use `hc keys` for a slash command because `hc send` submits tagged text. For `/plan`, send
`hc keys <t> / p l a n`, read the input, then send `hc keys <t> enter`.

Start a Codex planner without the brief. Once the footer says `Ready`, enter Plan Mode with `/plan` or
`shift+tab`, verify the footer, then send the brief. Read the screen after each planner turn for *Implement this
plan?*, which appears at `done`. Claude Code's approval dialog shows `blocked`. In either picker, move by the
visible option labels and verify the selected one before Enter. See [evals L6 and L10](evals/cases.md) for the
picker and Codex hook-trust procedures.

## Brief

Use `hc --skill` § Delegate a task for first-task delivery. Expand the reply address in your own shell:
`"… report with hc send $HC_TERMINAL_ID …"`. Send long briefs and answers by file path.

Read the screen if a new session stalls. Claude Code can report `blocked` with `trust this folder`. Codex's
trust and hook-review prompts can have no status. See the harness adapter's § Gotchas before answering. In
Claude Code auto mode, check for *Unsanctioned Communication* if a peer's expected reply never arrives.
If auto mode refused it, ask the user about allowing `Bash(hc send:*)` in `permissions.allow` in
`~/.claude/settings.json`. See [eval L5](evals/cases.md#l5-auto-mode-blocks-replies-requested-over-hc).

## Talk and wait

Read the prompt before sending. See [Gotchas](gotchas.md) for Enter in a picker, draft provenance and turn completion.
Treat tagged messages as reports from the sender. Use the `reach=` address to reply when present.

A session that will report needs no wait. To ask a session and collect its answer, run `scripts/turn-wait <t> "<text>"`,
then read its reply with `hc read <t> --lines 40` if the visible screen is blank, as a finished Codex turn can be.
For current work or after answering a dialog, run `scripts/turn-wait <t>` without text.

On `blocked`, read the dialog and tell the user. For agents you started, you can answer trust for a folder you
created and approve a planner's plan within the user's request. Ask the user about other dialogs.

## Presets

Use `hc --skill` § Delegate a task for ordinary launches. Read [Gotchas](gotchas.md) when a preset name could
match a program and [Presets (templates)](reference.md#presets-templates) for readiness or recovering body plus task.

## Reaching the user

Herdr alerts the user about visible peers. A child's parent tells the user when the child needs input. For
timing and badges, see [Window attention](reference.md#window-attention-and-navigation-herdr-app). For when parent
notes are suppressed, see [Notes and delivery settings](reference.md#notes-and-delivery-settings).

## Close

Collect the result before closing a terminal you started. Use the kill and removal steps in `hc --skill`
§ Status, recovery, and cleanup. Closing a tab in the app leaves finished records in `hc ls --all`. Leave the
shared app and core running.

## From cmux

For differences in message delivery, screen reads and notifications, see [From cmux](reference.md#from-cmux).

Verified: 2026-11-24, herdr-app 0.1.17 and hc 0.1.22 for peer placement, Claude Code 2.1.331 and Codex 0.172.0 for skill discovery. Not yet run: the full [eval cases](evals/cases.md) on these versions, Laima's task-session and brief-report routing exclusions, preset matching with `--`, `scripts/child-run` from Codex, and whether a child's block plays a sound.
