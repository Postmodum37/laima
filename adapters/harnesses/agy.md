# Antigravity CLI adapter

Version checked: Antigravity CLI (agy) 1.5.16

Release notes: `agy changelog`, which runs ahead of the online page (https://antigravity.google/docs/changelog)

Tool guide: `agy --help`, and the built-in skills `antigravity-guide` for the product and `agy-customizations` for its configuration

How a session runs on Google's Antigravity CLI, the command `agy`: its argv, what it loads, where its history
lives. The multiplexer adapter covers the terminal it runs in. Everything below holds under Rex; launch, the trust
prompt, the session id and the report back hold under Herdr and cmux as well. *(read, not run)* marks a fact read in
Google's documentation or `agy --help` and not run.

## Launch with a brief

```sh
agy --dangerously-skip-permissions --model <model> --effort <level> -i "Read <brief-file> and carry it out."
```

- `-i` starts an interactive session with that prompt as its first turn. Print mode (`-p`) ends after one answer:
  nothing to watch, message or ask again.
- In a folder agy has not trusted (§ Gotchas), leave out `-i` and its prompt: that first turn would run behind the
  trust prompt, before anyone has answered it. The session then stops at the trust prompt; once it is answered
  (`AGENTS.md` § Authority says by whom), the session shows `idle` at its prompt, and you send it `Read
  <brief-file> and carry it out.` with the multiplexer adapter's § Message a session. A folder is trusted when it
  is in `trustedWorkspaces` in `~/.gemini/antigravity-cli/settings.json`.
- Bypass mode is the default for a worker. Without the flag the session runs in the user's default mode, which
  may stop for permissions: `auto` where the account and the terminal sandbox allow it, which approves edits and
  commands it judges safe *(read, not run)*. `--mode plan` is not used: an open issue reports that it executes as
  well *(read, not run)*.
- `--model` and `--effort` come from the role's row in `local/Laima/setup.md`, each optional. `agy models` lists the
  model ids, most with an effort in the name (`gemini-4-neon-high`). Write the id without the effort in the row
  and pass the effort as `--effort`: `--model gemini-4-neon --effort xhigh` selects that model at xhigh, and the
  footer shows both (`Gemini 4 Neon · xhigh`). What an id with an effort in it does with another `--effort` is not
  verified.
  Without `--model` the session takes the user's default from `~/.gemini/antigravity-cli/settings.json`.
- The brief travels as a file: give its absolute path in the prompt. `@file` is not expanded; the agent gets the
  path as text *(read, not run)*.
- Before the launch, read the folder's id (§ Session id): agy sets the id itself, and only that read tells the new
  session's from an earlier one's. Launch no second agy session in the same folder until this one's id is in the
  record.

## Instruction files it loads

A worker loads `AGENTS.md` and `GEMINI.md` from its folder, and not a `CLAUDE.md` beside them. It also loads
them, with `.agents/AGENTS.md`, `.agents/GEMINI.md` and `.agents/rules/`, in each folder above up to the
repository root, never from subfolders; the user's own in `~/.gemini/` and `~/.gemini/config/`, with
`~/.gemini/config/rules/`; and it reads them all again before each turn, so an edit reaches a running session
*(read, not run)*. A file is cut at 24,000 bytes, and past 20,000 tokens for all of them the largest are replaced by
a pointer to their path *(read, not run)*. How far it looks up from a folder outside git is not known, so keep the
folder holding the workspaces, and the folders above it, free of `AGENTS.md` and `GEMINI.md`. Skills come from
`.agents/skills/` in the same folders and from the user's `~/.gemini/skills/`, `~/.gemini/config/skills/` and
`~/.gemini/antigravity-cli/skills/` *(read, not run)*, and since 1.5.16 from the user's `~/.agents/skills/`, the
folder Codex reads too: a print-mode session in a plain folder listed skills that exist only there. On a name
found in both, the `~/.gemini/` skill wins *(read, not run)*. Where it keeps a memory of its own per folder, if it
keeps one, is not known.

It loads nothing of yours while the workspace sits outside your folder, so the brief carries all the role and the
task need, and names a project's `CLAUDE.md` to read when its rules live there.

## Session id

agy chooses it, a UUID; no flag sets it. A session files its conversation at its first turn (at start with `-i`,
at the first message without it) under the session's folder, written as the session's working directory had it:
as you passed it to the multiplexer, which on macOS can differ from what `pwd -P` prints (`/tmp/x` against
`/private/tmp/x`). Look it up in that form, and in the `pwd -P` form when that finds nothing:

```sh
jq -r --arg d "<folder>" '.[$d] // empty' ~/.gemini/antigravity-cli/cache/last_conversations.json
```

The file keeps one id per folder, the latest: any later agy session in that folder replaces it, and a folder where agy
has run before already holds an older one. So run the command before the launch too, in both forms, and after the first
turn take the id once it differs from the value in its form (empty before agy's first session there); record `agy:<id>`.
Two agy sessions started in one folder before the first id is read leave only the second's, which is why launches there
go one at a time. The same id names `~/.gemini/antigravity-cli/conversations/<id>.db`.

For a session the user started, the folder's entry is its id while no other agy session has started in that
folder since; otherwise leave it pending in the record and ask the user.

## Resume from a session id

```sh
agy --dangerously-skip-permissions --conversation <session-id> --model <model> --effort <level> \
  -i "<what changed and what is wanted now>"
```

Run it in the folder the session first ran in: it comes back with its earlier turns and takes the new prompt as
the next one, under the same id. Give the mode, model and effort flags again. Never `-c`: it resumes whatever the
folder's entry in `last_conversations.json` names at that moment, which another session may have replaced.

## Transcripts

`~/.gemini/antigravity-cli/brain/<session-id>/.system_generated/logs/transcript.jsonl`, one JSON line per step,
with its kind in `type` (`USER_INPUT`, `PLANNER_RESPONSE` and others), and `transcript_full.jsonl` beside it.
No retention setting is documented, and conversations over a month old stay. Copy what a task needs later into
its record.

**Folders worked in**, for `set-up`: `~/.gemini/antigravity-cli/history.jsonl` has one line per prompt typed at
the session's prompt, with its folder in `workspace` and the time in `timestamp` (milliseconds); a first turn
given with `-i` or `-p` makes no line, and a slash command has `"type": "slash_command"`. Its `display` field
holds the prompt's text, so select only the folder. The keys of `cache/last_conversations.json` add every folder
a session ran in, without a count. Prompts per folder over the last 30 days:

```
jq -rR 'fromjson? | select(.timestamp > (now-30*86400)*1000 and .type != "slash_command") | .workspace // empty' ~/.gemini/antigravity-cli/history.jsonl | sort | uniq -c | sort -rn
```

## How a worker reports back

It runs the send its brief gives, in its shell (multiplexer adapter § How you learn a session finished). Under bypass
mode it runs unasked, and its report reaches the lead's prompt while the lead is inside a tool call. Under `auto` mode
such a command may wait for a person (not verified).

## Remaining usage

```sh
agy -p "/usage" --output-format json | jq -c '.command.data.groups[]
  | {name, buckets: [.buckets[] | {window, remaining_fraction, reset_time}]}'
```

It answers in about four seconds, starts no turn and spends no quota. Models share limits by group; on a Google AI
Pro plan, one group holds the Gemini models, the Orchestrator's included, one the other providers' models agy offers,
each with a weekly and a five-hour window, and one model has a weekly group of its own. Quota is spent in proportion
to the list-price cost of the tokens, so a higher effort uses it faster. Read the JSON: the text form
rounds 99.5% to 100%. When it prints no groups (an account billed by API key, for one), ask the user for the figure.
Under cmux, the multiplexer adapter § Start a task session says when the command takes a prefix.

- A reading covers the whole account, the user's own agy use included, and can be minutes old: for some minutes
  after use, readings a few seconds apart alternate between an older and a newer value. Take two or three and
  keep the lowest `remaining_fraction` of each bucket.
- `reset_time` (UTC) is the first use in the window plus the window; on a bucket not used yet it is only now plus
  the window, so it says nothing there.
- What one session spent is in its transcript (§ Transcripts), where each `PLANNER_RESPONSE` line is one model
  call; this sums them per model:

  ```sh
  jq -s -c 'map(select(.type == "PLANNER_RESPONSE")) | group_by(.model)[] | {model: .[0].model, calls: length,
    input: (map(.input_tokens) | add), cache_read: (map(.cache_read_tokens) | add),
    output: (map(.output_tokens) | add)}' \
    ~/.gemini/antigravity-cli/brain/<session-id>/.system_generated/logs/transcript.jsonl
  ```

## Gotchas

- **Do you trust the contents of this project?** opens at start in a folder missing from `trustedWorkspaces` in
  `~/.gemini/antigravity-cli/settings.json`, in bypass mode too, and a trusted folder above it does not count.
  Rex and Herdr show `blocked`, kind `permission`, message `Trust this folder?`; cmux, its adapter § See all sessions.
  `Yes, I trust this folder` is selected first, then `No, exit`, and a yes adds the folder to the list. A first
  turn given with `-i` does not wait for it: a turn of seconds can end, its files written, while the prompt is
  still on screen, and a longer turn runs its commands behind it. That is why a launch in such a folder carries
  no first turn (§ Launch with a brief); started without one, agy runs nothing before the answer. The entry stays in
  the list after the folder is gone. The root `AGENTS.md` § Authority says when it is yours; the multiplexer
  adapter § Waiting on the user, how to answer it.
- Its start screen shows the signed-in account's address and plan. Leave them out of what you copy into records.
- Under Rex and Herdr its status comes from agy itself (app `antigravity`): `working` in a turn, `done` at its end
  (Rex with the last reply as the message). agy also reports state to terminals by OSC 7501 *(read, not run)*. What
  its question dialog and permission prompts look like is not known: read the screen when it shows `blocked`.
- Under `--dangerously-skip-permissions` the footer and the prompt still read `auto`, and nothing stops for a
  permission, the multiplexer's send command included, under Rex, Herdr and cmux alike.
- **As Laima's own session, it follows its own instructions before hers.** The root `AGENTS.md` reaches it as a
  workspace file and `persona.md` as a file it reads, below agy's own system prompt. Start with
  [`bin/laima agy`](../../bin/laima). It writes the git-ignored `.agents/agents/laima.md` from `persona.md` on each
  start and selects it as a custom primary agent so her text goes into the system-prompt slot.
  Without `tools` the agent gets none and without `commandExecutionPolicy` its commands run sandboxed
  (https://antigravity.google/docs/subagents); a tool name agy does not know may hang it *(read, not run)*.
  The launcher uses agy's tool names as its transcripts show them. What the agent does without `manage_task`,
  `schedule` and `invoke_subagent` is unknown. With bypass enabled, it runs the startup order from the vault,
  speaks in the persona's voice and opens its question dialog for a decision with named answers, the recommendation
  first and a cost on each option. Its behavior with the default permission policy and its use of the `launch` and
  `finish` skills are unverified.
- On a consumer Google AI plan, Google's FAQ says that wrapping `agy`, headless mode included, inside a
  third-party coding agent is not supported, and its terms allow suspension for third-party access
  (https://antigravity.google/docs/faq). Laima runs agy as its own interactive session in a terminal, as she runs
  the other harnesses, and the one headless call she makes is `/usage`, which starts no model turn; whether to use
  agy on such a plan is the user's decision.
- `/exit` ends a session *(read, not run)*; closing its block ends it too.
- Its shell tool waits at most 10 s for a command (`WaitMsBeforeAsync`, 500 to 10000 ms), then makes it a background
  task and ends the call; the task's result comes later as a message. Esc during the call, and `manage_task kill` on a
  task, end the command with SIGKILL, so its traps do not run. Esc of a turn leaves a background task running, and a
  task that finishes after an interrupted turn starts no turn: its message waits for the next input. Seen under
  Herdr; the Herdr companion skill's `scripts/child-run` stops its child after such a SIGKILL.
