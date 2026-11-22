# Claude Code adapter

Version checked: Claude Code 2.1.330

Release notes: https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md

Tool guide: `claude --help`, and the built-in `claude-code-guide` agent for questions about Claude Code itself

How a session runs on Claude Code: its argv, what it loads, where its history lives. The multiplexer adapter
covers the terminal it runs in. *(read, not run)* marks a fact read in the documentation or `claude --help` and
not run.

## Launch with a brief

```sh
claude --dangerously-skip-permissions --session-id <uuid> --model <model> --effort <level> \
  "Read <brief-file> and carry it out."
```

- Bypass mode is the default for a worker, so that it does not stop for a permission on every command. When the
  role's row in `local/setup.md` names another mode, pass `--permission-mode <mode>` in its place. Under bypass
  the limits in the brief are instructions, and nothing enforces them.
- `--model` and `--effort` come from the same row, each optional. `<uuid>` is the id you choose (§ Session id).
- The brief travels as a file: give its absolute path in a one-line prompt, as above.
- Keep it interactive. Print mode (`-p`) ends after one answer: nothing to watch, message or ask again.

## Instruction files it loads

A worker loads the user's own files (`~/.claude/CLAUDE.md`, `~/.claude/rules/`, their settings, hooks and skills)
and the project's: `CLAUDE.md`, `.claude/CLAUDE.md`, `CLAUDE.local.md` and `.claude/rules/` in its folder and in
every folder above it up to the filesystem root, with the project's skills, settings and auto memory. It reads
`AGENTS.md` in those folders too, by default only when none of them holds one of the three `CLAUDE.md` files. A
subfolder's files load once it reads a file there. A git worktree shares its main checkout's memory
*(read, not run)*.

It loads nothing of yours while the workspace sits outside your folder, so the brief carries all the role and
the task need. Keep the folder holding the workspaces free of instruction files: they would load into every worker.

## Session id

You choose it. Generate one with `uuidgen | tr 'A-Z' 'a-z'`, pass it as `--session-id`, and write
`claude:<uuid>` into the task record at launch. To check it, or to learn the id of a session the user
started: `~/.claude/sessions/<pid>.json` holds `sessionId` and `cwd` for the running Claude Code process `<pid>`,
which the multiplexer gives (Herdr: `foreground.pid` in `hc get <address> --json`).

## Resume from a session id

```sh
claude --dangerously-skip-permissions --resume <session-id> --model <model> --effort <level> \
  "<what changed and what is wanted now>"
```

Give the mode the task's Timeline recorded at launch; the bypass flag above is the default. Start it in the folder the
session first ran in, because transcripts are filed by working directory. When that folder went with the workspace,
recreate it at the same path first (`launch` § Resume a closed session records it): a worktree of a task with a branch
checks that branch out (`git -C <repo> worktree add <path> <branch>`), so that the session commits where it did before.
A copy made at a commit, or a branch already deleted (`finish` removes a merged one), is detached at the last commit the
record's Timeline names (`git -C <repo> worktree add --detach <path> <commit>`). Resume while the transcript still
exists. The id stays the same; give the mode, model and effort flags again *(read, not run)*.

## Transcripts

`~/.claude/projects/<folder>/<session-id>.jsonl`, where `<folder>` is the session's working directory with every
character that is not a letter or digit replaced by `-`. Claude Code deletes a transcript after
`cleanupPeriodDays`, 30 by default *(read, not run)*, and the format changes between versions. So copy what a task
needs later into its record; the id is a pointer that expires.

**Folders worked in**, for `set-up`: `~/.claude/history.jsonl` has one line per prompt the user typed, with its
folder in `project` and the time in `timestamp` (milliseconds); it outlives the transcripts. Its `display` field
holds the prompt's text, so select only the folder. `fromjson?` skips a line cut short while the file is being
written, which would otherwise end the count there. Prompts per folder over the last 30 days:

```
jq -rR 'fromjson? | select(.timestamp > (now-30*86400)*1000) | .project // empty' ~/.claude/history.jsonl | sort | uniq -c | sort -rn
```

## How a worker reports back

It runs the send its brief gives, in its shell (multiplexer adapter § How you learn a session finished). Under bypass
mode it runs unasked. Under `auto` or `manual` mode it can be stopped: auto mode can refuse `hc send` as unsanctioned
communication until the user's settings allow `Bash(hc send:*)`. Those settings are the user's, so ask them.

## Remaining usage

```sh
claude -p "/usage"
```

On a subscription account it prints the share used of the current five-hour session, of the week across all
models and of the week for the top model, each with its reset time. A section on what contributes to the usage
follows the three readings. It takes about six seconds and can run from any folder. An account billed by API key
has no such windows, and what it prints then is not verified: ask the user for the figure.

## Gotchas

- An untrusted folder stops the session at a trust prompt before the brief runs, in bypass mode too (Herdr and Rex show
  `blocked`, message `trust this folder`). The options are `No, exit`, selected first, and `Yes, I trust this folder`;
  the selected line is marked `❯`, and the answer is kept in `~/.claude.json`. The dialog also warns where the
  folder's hooks are declared *(read, not run)*. Trust goes by a worktree's main repository, so the prompt shows once
  per repository; a plain folder under a trusted folder shows none. The root `AGENTS.md` § Authority says when it is
  yours; the multiplexer adapter § Waiting on the user, how to answer it.
- Its question dialog lists the options, then `Type something.` for an answer of one's own, then `Chat about
  this`. With several questions, `enter` on an answer moves to the next question, and a last screen, `Review
  your answers`, takes one more `enter` on `Submit answers`. The status message the multiplexer shows stays on
  the first question throughout: read the screen.
- A message typed into a session or handed to its hooks during one of its tool calls is shown when that call
  returns, under a note that the user sent a new message while it worked, under Herdr, Rex and cmux alike: a
  report sent during a `sleep` shows when the sleep ends. Its tag, not that note, says whose it is. Its own
  question dialog is the exception: what each multiplexer does with a message then is in its adapter § How you
  learn a session finished.
- Without a mode flag the session runs in the user's default mode, which may stop for permissions.
- The first bypass launch on a machine shows a one-time warning that the user has to accept (not verified).
- Plan mode ends at an approval dialog that waits on a person; a planner is launched like any other worker.
