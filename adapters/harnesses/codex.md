# Codex adapter

Version checked: Codex CLI 0.171.0

Release notes: https://github.com/openai/codex/releases

Tool guide: `codex --help` and `codex <command> --help`, and the built-in system skill `openai-docs` for questions about Codex itself

How a session runs on Codex: its argv, what it loads, where its history lives. The multiplexer adapter covers
the terminal it runs in. *(read, not run)* marks a fact read in documentation, `codex --help` or source and not
run.

## Launch with a brief

```sh
codex --no-daemon --dangerously-bypass-approvals-and-sandbox -m <model> -c model_reasoning_effort=<level> \
  "Read <brief-file> and carry it out."
```

- `--no-daemon` on every launch and resume, because Herdr's manual asks for it: a session served by Codex's shared
  daemon would run its commands under another terminal's identity. With a daemon already running, a launch
  without the flag behaves the same as one with it: its command runs as its own child, with its own terminal's
  `HC_TERMINAL_ID`. What a launch that starts the daemon itself does is not verified.
- Bypass mode is the default, so that a worker does not stop for an approval on every command; when the role's
  row in `local/Laima/setup.md` names another mode, pass `-s <sandbox> -a <approval>` instead. Under bypass the brief's
  limits are instructions that nothing enforces. Model and effort come from the same row, each optional.
- The brief travels as a file: give its absolute path in a one-line prompt, as above. `@file` is not expanded.
- Keep it interactive. `codex exec` ends after one answer: nothing to watch, message or ask again.

## Instruction files it loads

At start, and only then, a worker loads the user's `~/.codex/AGENTS.md` and each `AGENTS.md` from the project
root (the nearest folder above it holding `.git`) down to its own folder. Project files share 32 KiB and the
rest is cut silently; a project the user's config marks untrusted loads none. Skills come from the project's
`.agents/skills/` *(read, not run)* and the user's `~/.agents/skills/`. Its memories, where the user keeps them, sit
in `~/.codex/memories/`, one store for every folder. Under Herdr a Codex worker can load the user's
`herdr` skill, when they linked it globally (README § Making her yours), and read its lead's screen without being
asked. It loads nothing of yours and no `CLAUDE.md`, so the
brief carries all the role and the task need, and names a project's `CLAUDE.md` to read when its rules live
there.

## Session id

Codex chooses it; no launch flag sets it. Note the time just before the launch, in UTC:
`date -u +%Y-%m-%dT%H:%M:%S`. Once the first turn has started (a session writes its file then), read the first line
of each session file written since the brief: it holds the session's folder (resolved, as `pwd -P` prints it), its
start time in UTC and its source, an object for a subagent's session.

```sh
find ~/.codex/sessions -name 'rollout-*.jsonl' -newer <brief-file> -exec sh -c 'for f; do head -n1 "$f"; done' sh {} + \
  | jq -rR --arg d "<folder, as pwd -P prints it>" --arg t "<launch time>" 'fromjson?
      | select(.payload.cwd == $d and .payload.timestamp >= $t and (.payload.source | type) != "object") | .payload.id'
```

One id: record `codex:<id>`. None: a startup prompt is still up, or the first turn has not started; look again
after it. More than one, as when the user started Codex in the same folder since: leave the id pending in the
record and take it from the running session, as for a session the user started: the Codex process keeps its
session file open, so `lsof -p <pid> | grep -o 'rollout-.*\.jsonl'` names it, the id being the UUID at the end of
the name, with `<pid>` from the multiplexer (Rex: its adapter § Start a task session says where; Herdr:
`foreground.pid` in `hc get <address> --json`).

## Resume from a session id

```sh
codex resume --no-daemon --dangerously-bypass-approvals-and-sandbox -m <model> -c model_reasoning_effort=<level> \
  <session-id> "<what is wanted now>"
```

Give the mode, model and effort the task's Timeline recorded at launch, or the session falls back to the user's
defaults; the bypass flag above is the default mode. Start it in the folder the session first ran in, since it works in
the folder it is started in (not verified), recreated first when it went with the workspace (Claude Code adapter §
Resume from a session id says how). When two sessions ran in one folder, pick the id from the task record and never
`--last`.

## Transcripts

`~/.codex/sessions/<year>/<month>/<day>/rollout-<start time>-<session-id>.jsonl`. Nothing deletes them on a
schedule: no retention setting is documented, and sessions months old stay. Copy what a task needs later into
its record all the same: the user can delete sessions, and a file can be renamed *(read, not run)*.

**Folders worked in**, for `set-up`: the first line of each session file is its `session_meta`, with the folder
in `payload.cwd`; the lines after it hold the conversation and stay unread. A session a subagent started has
an object with a `subagent` key in `payload.source` and is left out (its `thread_source` is `subagent` or
`guardian_review`). Sessions per folder over the last 30 days:

```
[ -d ~/.codex/sessions ] && find ~/.codex/sessions -name '*.jsonl' -mtime -30 -exec sh -c 'for f; do head -n1 "$f"; done' sh {} + \
  | jq -rR 'fromjson? | select((.payload.source|type) != "object" or .payload.source.subagent == null)
      | .payload.cwd // empty' | sort | uniq -c | sort -rn
```

## How a worker reports back

It runs the send its brief gives, in its shell (multiplexer adapter § How you learn a session finished). Under bypass
mode it runs unasked. Under a sandboxed mode it reaches outside the workspace and is expected to stop for approval (not
verified).

## Remaining usage

```sh
{ printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"clientInfo":{"name":"usage","version":"0"}}}' \
    '{"jsonrpc":"2.0","method":"initialized"}' '{"jsonrpc":"2.0","id":2,"method":"account/rateLimits/read"}'
  sleep 5; } | codex app-server 2>/dev/null | jq -c 'select(.id==2).result.rateLimits'
```

It prints one JSON line in about five seconds. On an account billed by use, `individualLimit` holds the spending
cap, the amount used, `remainingPercent` and `resetsAt` (Unix seconds). `primary` and `secondary` are for an
account with usage windows, and can be empty, as on an account billed by use. `codex app-server` is marked experimental:
when the line comes back empty, ask the user for the figure.

## Gotchas

Codex reports status only from inside a turn, so some of its screens never show in a listing. Read the screen
once after every launch, and whenever a Codex session is `done` or `idle` without a report.

- **Trust this folder?** opens at start in a folder inside a git repository Codex has not trusted, in bypass mode too,
  and reports no status; the brief runs once it is answered. A plain folder outside git shows none, so a launch there
  runs at once. `1. Trust and continue` is selected first; the selected line is marked `›`, and the answer is kept in
  `~/.codex/config.toml`. A worktree goes by its main repository. The root `AGENTS.md` § Authority says when it is
  yours; the multiplexer adapter § Waiting on the user, how to answer it.
- **Told to wait for messages,** a Codex can stay in its turn: its status reads `working` and its screen shows an
  unbroken `Working` timer for minutes, with no command running, while messages still come in. Under the same
  brief wording a Codex can also end its turn, so the wording alone does not cause it. A wait for its turn to
  end then does not end; take its report.
- **As Laima's own session, it does a step's work beside its worker.** It launches the worker and then runs its own
  reads and tests of the same question, waiting in its turn until the report comes, and the core's wording does not
  stop it. Run Laima's own session on another harness.
- **A text typed and submitted at once can stay in the input.** Under Rex, `rex send` with `send-key enter` right after
  it leaves a text over about 80 characters in a Codex lead's input, unsent, at its prompt and in a turn; a short one
  goes in. Each line of the text shows as typed, or, from about 1,000 characters, as `[Pasted Content <n> chars]` with
  that line's length; typed text taller than the input box shows its last lines under a `↑`. One more Enter, five
  seconds or more later, sends it, once and with no added line break; a one-second pause before the first Enter can send
  it too. Rex's report block carries that Enter (Rex adapter § How you learn a session finished). To a working Codex
  worker, a send can stay above `tab to queue message`, and one more Enter sends it.
- **Hooks need review** opens at start after the user's hooks file changed and reports no status. It is theirs.
- **Implement this plan?** and a question asked in plain prose both show as `done` *(read, not run)*.
  Plan mode is not used.
