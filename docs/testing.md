# Testing the core by hand

How to check, after a change to a core file or when something seems off, that Laima still works: the core, the
skills and the adapters. A test is a scenario run by hand: a fresh session in a throwaway copy of the core, on the
real multiplexer, judged by a reader against the goals below.

| Path, under `docs/testing/` | Holds |
|-|-|
| `make-fixture` | Builds the throwaway copy; its usage is in its first lines |
| `fixture/local/` | The canned vault: an invented user, one project, nothing pending (placeholders in `@CAPS@`) |
| `fixture/toy/` | The toy project, `tallyfile`: a word counter with tests |
| `fixture/seeds/` | A scenario's starting state, one file each, given to `make-fixture --seed` |

## When to test

- **A run must be able to change something.** A scenario the change touches always can: a fail sends the change
  back. Any other run (a scenario the change does not touch, a model the user does not run) needs you to say first
  what a fail would change; without that, skip it.
- **After a change to a core file:** run the scenarios that use the changed file (§ Scenarios names each one's
  files), on the changed core, before the change is committed.
- **When something seems off** in real work: run the nearest scenario to see whether it repeats.
- **A doubtful result** is run twice more before it is called a defect.
- **A new scenario** comes only from a miss on record: a log line, a task record or the user's correction. Name
  it in the scenario.

## Goals

What good looks like. A scenario is judged against these, by reading what the session did.

**The core**
- At the start it reads the files the root `AGENTS.md` lists, in order, looks at the sessions and the open tasks,
  and its first reply says what needs the user, what is due, what runs and what finished.
- It takes the workflow whose "Use when" fits the request, and not its neighbour.
- It writes the record and the log line at each write moment, in the turn it happens.
- It hands the work to a worker session where the workflow says so, with a brief that carries what the worker
  needs, and does not do that work itself.
- A task stays open until facts show it finished (the commit on main, the file as it stands), whatever a report
  or the user says.
- It asks the user where the workflow says the decision is theirs, and nowhere else.

**The skills**
- Each starts on the requests its `cases.md` lists, and not on its near misses.
- Once started, it is followed to its end: each step's "Done when" holds before the next.
- It is built to `docs/authoring.md` § Skill.

**The adapters**
- Each action in the adapter document works on the real tool as written, at the first try.
- The tester notes, per action, the commands run, the retries, and whether the multiplexer's `gotchas.md` or
  companion skill (`adapters/multiplexers/<multiplexer>/`) was needed because the document was not enough.

## Which model

The one `local/setup.md` § Roles of the user's own vault names for the role under test, since that is what must
work. A smaller model is a probe: what fails only there is a limit to note in the result, and a core file changes
for it only when the named model fails as well.

## Running a scenario

1. **Build the copy:** `docs/testing/make-fixture <N> [--seed <name>]`. It prints the slot folder, resolved (on
   macOS `/private/var/tmp/<core folder>-testing-<user>/slot-N`, unless `LAIMA_TESTING_HOME` says otherwise). The
   slot holds `laima/` (the core's files as they stand in the working tree, new ones that git does not ignore
   included, without this guide, `docs/testing/` and the skills' `cases.md`, plus the canned vault), `tallyfile/`
   and `work/`. In the copy, the pointers to this guide in `docs/authoring.md` and the README lead nowhere; that is
   expected. Run `cp -R <slot>/laima/local <slot>/local.before`, to compare at the end. Give each test running at
   the same time its own `N`: a build in an existing slot removes it first. The canned `local/setup.md` names Codex for
   the builder and the researcher, and the canned log says no provider is short, so the test session launches on
   Codex without reading the real usage: where Codex is not installed or a provider is really short, change those
   rows in the copy. Its model names are examples too: replace each with a model the tester's account offers. Done
   when the slot exists.
2. **Start the test session** in `<slot>/laima` with the adapter's own action
   (`adapters/multiplexers/<multiplexer>.md` § Start a task session, which also says how to find your space id),
   with three changes: no `laima` labels, a name that starts with `eval-`, and the harness command of § Core alone
   with the model and effort of § Which model. With Herdr, for example:
   `hc run --bg --no-parent --name eval-<N> --cwd <slot>/laima --label herdr.space=<your space id> -- claude --model <model> --effort <effort> --dangerously-skip-permissions --setting-sources project,local --strict-mcp-config --settings '{"autoMemoryEnabled":false}'`.
   A new slot is a folder the harness has not seen, so the session first stops at its trust prompt: answer it as
   the multiplexer adapter's § Waiting on the user says. Claude Code may then ask to accept bypass mode
   (§ Core alone). The adapter's § See all sessions filters on the `laima`
   label, which a test session lacks: look it up by its name (with Herdr, `hc get eval-<N> --json`). On cmux the
   tag to leave out is the description `laima task=…`; the test session renames its own workspace to `laima` at
   its start (adapter's opening), so keep the workspace ref `cmux workspace create` prints and use that, not the
   title. Done when it shows working or idle in that folder.
3. **Give it the scenario's turns,** word for word, one at a time (adapter § Message a session), and wait for
   each turn to end. A test session sends no report, so use the wait the adapter's § How you learn a session
   finished gives for a session that does not report (with Herdr, `adapters/multiplexers/herdr/scripts/turn-wait`).
   With Herdr a turn arrives as `<hc from="<your address>">…</hc>`, which the test session takes as another
   session's message and acts on as the user's: read a scenario that turns on the user's own word with that in
   mind. A question it asks comes as a dialog: the session shows blocked, a send is refused, and you answer with
   keys as the adapter's § Waiting on the user describes. When it launched a worker and ended its turn,
   `turn-wait` without a text returns at once; to wait for the turn the worker's report starts, wait until `turn`
   in `hc get <t> --json` has gone up or the status is blocked.
4. **Read what it did:** its screen, or its transcript (harness adapter § Transcripts says where);
   `diff -r <slot>/local.before <slot>/laima/local`; the toy project's state (`git -C <slot>/tallyfile log
   --oneline --all`, `worktree list`, `status`); the listing, for sessions it started. Done when you can answer
   the scenario's "Good" with evidence.
5. **Judge** against the scenario's "Good" and the goals it serves: pass, fail, or doubtful (then twice more).
6. **Write the result** into the record of the task the test is for: scenario, harness, model and effort, core
   commit (`git rev-parse --short HEAD` in the core, and "with uncommitted changes" when `git status --short`
   lists any), the judgement with its evidence, and for a fail whether it is a defect (the core's files disagree,
   point nowhere or give a step that cannot be done), a wording problem (it fails on the named model too) or a
   limit (only a smaller model fails). A fix goes through `authoring`.
7. **Clean up:** close every session the test started, then remove the slot (`rm -rf <slot>`).

**Telling a test's sessions from real ones.** Sessions the test session launches carry Laima's usual labels, as
real tasks' do, so the label does not tell them apart: the folder does. Every session a test starts runs under the
test home, the folder above the slot that `make-fixture` printed; a real task's never does. Check the folder
(with Herdr, `cwd` in `hc get <t> --json`) against that printed path before you close anything. A test session
sees the real sessions too: if it starts acting on one whose folder is outside the test home, interrupt it. The
real Laima, in turn, sees a test's workers as sessions of tasks she has no record of; tell her they are a test's
when she asks.

## Core alone

A test session should load the copy's files and the harness's own, not the user's global instructions, skills,
agents or memory, which can hide a gap in the core.
- **Claude Code:** the copy outside any home folder (Claude Code reads a `CLAUDE.md` from each folder above the
  session, and the home folder has the user's), and `--setting-sources project,local --strict-mcp-config
  --settings '{"autoMemoryEnabled":false}'`. Check once per Claude Code version: `claude -p "/context"` with those
  flags, in the copy, lists only the copy's `AGENTS.md` under Memory Files, and only Project and Built-in skills.
  Without the user's settings, Claude Code asks once at the start to accept bypass mode, a dialog Herdr shows
  with no status and `claude -p` never shows. Where the user's own settings carry
  `"skipDangerousModePermissionPrompt":true`, add that key to `--settings`; where they do not, the dialog is the
  user's to answer.
- **Codex** cannot: it reads the user's `AGENTS.md` from `CODEX_HOME`, the folder that also holds the login, and no
  setting skips it (checked on Codex 0.171.0). The rest can be switched off: `--disable memories --disable apps
  --disable hooks`, each MCP server in the user's `config.toml` with `-c mcp_servers.<name>.enabled=false`, and
  the user's skills with one `-c 'skills.config=[{path="<a SKILL.md>",enabled=false}, …]'` listing each. Check
  once per Codex version: `codex debug prompt-input` with those flags, in the copy, prints the model's input
  without a model turn and refuses a flag it does not take; its skill roots are only Codex's own `.system` and
  the copy's `.agents/skills`, and no tool of the user's MCP servers appears. The rest of the user's
  `config.toml`, such as its model and approval settings, still applies. Say in the result that the user's
  `AGENTS.md` and `config.toml` were loaded.
- **agy** cannot: it reads the user's rules and skills under `~/.gemini/` (agy adapter § Instruction files it loads),
  and `agy --help` offers no flag that leaves them out (checked on agy 1.5.14). Say in the result that the user's
  files were loaded.
- **Workers** the test session launches use the copy's `local/setup.md` and the `launch` skill, which pass none of
  these flags: they load the user's files. Judge a worker's own work with that in mind.
- **A companion skill the user links globally** (`herdr`, `cmux`) does not shadow the copy: the companion skills sit
  beside their adapters, outside `.agents/skills/`, so the copy has no project skill of that name. A session loading
  the skill by name gets the user's linked checkout, not the copy: test an edit to a companion skill by reading it
  from the copy's path, `adapters/multiplexers/<multiplexer>/SKILL.md`.

## Scenarios

Each starts from the base copy unless it names a seed. "Good" is what the reader checks.

### The core

**Start of a session** (root `AGENTS.md` § At the start of a session). Turn: "Good morning." Good: it reads
`persona.md`, `local/persona.md`, `local/user.md`, `local/setup.md` and `local/index.md` in that order, looks at
the sessions, runs `.agents/skills/wrap-up/scripts/open-tasks`, and replies in the root's order: here, nothing
needs the user and nothing is due. It sees the real sessions as well, so what it says runs depends on them; it
leaves them alone.

**The right workflow** (root § A task, start to finish; each workflow's "Use when"). One turn each. Good: a new
record in `local/work/` with that `workflow:`, an `opened` line in today's log, and no work of the task done in the
session itself; for Answer, a reply and no record.

| Turn | Right workflow | Its neighbour |
|-|-|-|
| "Which command-line flags does tallyfile take right now?" | answer | investigate |
| "Someone says tallyfile miscounts words with accents, like café and naïve. Dig into what it actually does with non-ASCII text, and why." | investigate | answer |
| "What do the Unicode text segmentation rules (UAX #29) say a word boundary is, and which Python libraries implement them? I want sources." | research | answer |
| "Add a --min-length N flag to tallyfile that skips words shorter than N letters." | build | planned-build |
| "I want tallyfile to support pluggable tokenizers: a simple regex one, Unicode word boundaries, maybe a language-aware one later. Let's plan that together before anything is built." | planned-build | build |
| "Review the README change that went into tallyfile's main yesterday, before I show the project to anyone." | review | build |

**Said merged** (root § Look before you speak; `finish` steps 1 and 2; from the log, 2026-11-21 02:25). Seed
`said-merged`: a build on branch `cli-top` waits on the user's merge, and main does not contain it. Turns: "Good
morning.", then "I merged it." Good: the first reply names the merge waiting on the user; after the second, it
checks main, says the commit is not there, and the task stays open (no `finished` line, `closed:` empty). Not
shown able to fail: on haiku, with the core alone and with the user's files, it still passed with those lines taken
out, since the record's "Done when" and the root's "What you observe beats what a file says" carry the rule as
well. It stays, as a miss on record.

**One task, request to finish** (the build workflow, `launch`, `finish`). Turn: "Add a --min-length N flag to
tallyfile that skips words shorter than N letters." Then answer as the user would, merge the branch yourself when
asked (`git -C <slot>/tallyfile merge <branch>`), and say "Merged." Good: a record and an `opened` line; a builder
launched with a brief, on the role's row of `local/setup.md`; its report checked against the files before
`handed-off`; the merge asked of the user; after "Merged.", main checked, the record closed and `finished` logged;
the builder's session closed and its workspace removed.

### The skills

Each skill's `cases.md`, beside its `SKILL.md`, lists requests that should start it and near misses that should
not. Try one case in a base copy: give the request as the first turn. Good: on a start case the skill is loaded
before the first reply (the transcript shows the skill started or its `SKILL.md` read), and on a near miss it is
not. Then follow it: each step's "Done when" holds before the next, to its last step. To check how a skill is
built, go through `docs/authoring.md` § Skill item by item.

### The adapters

For the multiplexer in use, go through the fixed questions of `docs/authoring.md` § Adapter document on the real tool,
in a base copy so that what it starts is a test's: under each heading of `adapters/multiplexers/<multiplexer>.md`, run
the commands as written. Good: each works at the first try. Note per heading the commands run, the retries, and whether
its `gotchas.md` or companion skill was needed. A harness adapter is walked the same way for its own questions.

## Who writes here

Changes to this guide, `make-fixture`, the fixture and the seeds go through `authoring`, as any core file. A new
scenario takes the form of those above: a bold name, the core files it uses in brackets, the miss it comes from, its
turns and its "Good". A seed is added with the scenario that needs it, as
`docs/testing/fixture/seeds/<scenario-name>.sh`.
Results go into the record of the task the test is for (§ Running a scenario, step 6), not into the core.
