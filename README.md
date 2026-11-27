# Laima

An assistant for the work you do with agents: a lean, plain-file framework for the harnesses, multiplexer and
tools you already use, and one you shape to your own needs.

Laima brings no harness and no tools of her own. She is a folder of Markdown files: roles, workflows, skills, and
an adapter for each supported tool. Open your harness in this folder, inside your terminal multiplexer, and that
session becomes Laima. You tell her what you want; she hands it to worker sessions in your projects, follows each
task until it is delivered, comes back to you only for decisions, and keeps what she learns about you and your
projects in a private vault on your machine. Most of that work is code; research and a knowledge base run the
same way. The harnesses she works with are Claude Code, Codex CLI and Antigravity CLI, and the multiplexers
Herdr, Rex and cmux; Requirements, below, says what each has run as.

The name is the Baltic goddess of fate and good fortune; in Lithuanian it is kin to *laimė*: luck, happiness.

**Status:** early, with a workweek of daily use on Herdr. Claude Code led most of the work, and Codex CLI ran
workers and led some live tasks. That week exercised investigations with evidence read back, planned changes
through review and deployment, pull request reviews with selected comments, and follow-ups carried between
sessions in the same vault. See [Requirements](#requirements) for the scope of the tool checks.

## Why

With agent sessions open in several projects at once, the code stops being the hard part. The hard part is
knowing what each session is doing and which one waits on you, and carrying what each project taught into the
next task.

Laima is an assistant for that:

- **She keeps the context.** Each task gets a record and each day a log. Your preferences, what she learns about
  a project that its own files do not hold, and lessons that cross projects go into a vault: she reads your
  rules and its index at the start of a session, a project's note before each brief, and a lesson when it
  applies. She knows where each project's instructions, skills and memory are, and points her workers to them.
- **She runs the work.** You talk to her; she briefs worker sessions, checks their reports against the facts,
  follows each task past "done" (review, pull request, merge) and brings you only the decisions, each with a
  recommendation. One place answers what needs you, what is running and what finished.
- **She is yours to shape.** Add a workflow, role or skill of your own, or ask her to make one; the core itself
  changes through her `authoring` skill.

She is built on four goals:

- **Lean.** Plain Markdown in a fixed folder structure, and nothing to keep running.
- **Portable by design.** The core describes the work in general terms. An adapter explains how each
  supported tool handles the steps, and a new tool can be added with its own adapter.
- **Structure for everyone, the rest yours.** The core is the same for every user. Everything about you, your
  projects and your additions lives in `local/`, which never leaves your machine.
- **Fits what you already have.** She works under your global instructions and skills and each project's rules,
  issue tracker and definition of done. How a change is made and shipped is theirs to say; she asks once where
  they are silent.

## What Laima is not

- **Not an application or a service.** Nothing runs when no session is open. She looks at your sessions when you
  talk to her, and a dated task comes up when a session starts on or after its day.
- **Not a sandbox or a guard.** By default she launches workers in the harness's bypass mode, so that they do not
  stop for a permission on every command; `local/Laima/setup.md` can name another mode for any role. Her limits are
  written instructions, and nothing enforces them.
- **Not a notification system.** Your multiplexer can alert you when an agent waits on you, and she relies on
  that; each adapter's § What the user is notified of without you says what it covers.
- **Not an inbox.** She takes work from you. She does not read your mail, chat or tickets to find it.
- **Not a voice of yours.** She never posts to a chat service. She drafts the message and hands it to you.
- **Not an installer.** She adds nothing to your global configuration (beyond the harness's own record of a folder
  she trusted) or to your projects' files. One exception is cmux's own: in a cmux terminal its `agy` wrapper adds
  cmux's hooks to your Antigravity CLI configuration. Set-up asks you once whether to keep them.

## Requirements

- macOS. It is the only system she has run on. Linux is untried.
- A harness and a terminal multiplexer. One of each is enough. With multiple harnesses, a reviewer can use a
  different provider from the builder. Give Laima's own session a top-tier model. In a fixture, a small model
  skipped the task record and took over the worker's work.
- `jq` and git to clone and update Laima herself. Your projects use their existing tools.

| Tool | What has run | Limits to check |
|---|---|---|
| [Claude Code](adapters/harnesses/claude-code.md) | The main lead during the week on Herdr, with Claude Code and Codex workers. Earlier request-to-finish fixtures on all three multiplexers. | Project-specific skills and permission choices follow your setup. |
| [Codex CLI](adapters/harnesses/codex.md) | Workers and scoped live lead use on Herdr, including receipt of a Claude Code worker's report after a lead switch. Earlier lead fixtures exercised a full task. | One early lead fixture duplicated worker steps. Vault-first startup was checked with memories off. Chooser and delivery behavior vary with the prompt and multiplexer. |
| [Antigravity CLI](adapters/harnesses/agy.md) (`agy`) | Worker launches and reports, and earlier lead smoke tests. | The current launcher-based lead has an observed startup and question dialog in bypass mode. Its default-permission path and use of the Launch and Finish skills remain unverified. Read the adapter's consumer-plan note. |
| [Herdr](adapters/multiplexers/herdr.md) | The suggested starting point and the host for the workweek. Earlier request-to-finish and dialog fixtures. | A clear prompt can receive a report during work. Check actual receipt, especially with Codex Side chat or a picker. |
| [Rex](adapters/multiplexers/rex.md) | Earlier task and adapter smoke tests, including a request-to-finish fixture with a Claude Code lead. | Sends type into the prompt. A picker can take the submit key. Codex can leave sent text in its input, so check the screen before another Enter. |
| [cmux](adapters/multiplexers/cmux.md) | Earlier task and adapter smoke tests, including a request-to-finish fixture with a Claude Code lead. | Start inside a cmux terminal under its default policy. A message can queue at a dialog or leave an idle Codex waiting. |

Those checks cover the named paths. Combined harness and multiplexer behavior, lead recovery and prompt handling
have narrower coverage. Each adapter gives its `Version checked:` pin and the actions that still need a run.
Other harnesses and multiplexers can be added with an adapter. [Authoring guide](docs/authoring.md#adapter-document)

## Start

1. Clone the repository (`git clone <repository-url> laima`) where no folder above it holds a `CLAUDE.md`,
   `.claude/CLAUDE.md` or `CLAUDE.local.md`. A default Claude Code reads such a file in place of Laima's `AGENTS.md`
   files, which switches her off without a message; your own `~/.claude/CLAUDE.md` does not count. Run in the
   clone, this prints any it finds:

   ```sh
   d=$(pwd -P); while :; do for f in CLAUDE.md .claude/CLAUDE.md CLAUDE.local.md; do
     [ -f "$d/$f" ] && [ "$d/$f" != "$HOME/.claude/CLAUDE.md" ] && echo "$d/$f"; done
     [ "$d" = / ] && break; d=$(dirname "$d"); done
   ```
2. Open a tab in your multiplexer and run [`bin/laima`](bin/laima) from the clone. The launcher uses
   Claude Code by default on a fresh clone. For a shell alias, use the script's absolute path.
   When changing harnesses, pass a model and effort for that harness. For example, if your Codex account
   offers this model, `bin/laima codex -m gpt-6.2-sol -e high`. Use `bin/laima -h` for options and `-n`
   to preview the exact arguments. Some harnesses ask you to trust the folder on first launch.
3. Say hello. She answers as Laima, and on the first run she runs set-up: she finds your harnesses and tools, and
   the folders you work in from your harnesses' session history (folders and times only, never what you typed),
   asks a few questions, and writes `local/`. A plain answer means the root `AGENTS.md` did not load: in Claude
   Code, `/context` lists it under Memory files; in Codex, `/status` names it on its `Agents.md` line.

- **Update:** `git pull`. Git ignores what you keep in `local/`, so your vault is untouched.
- **Another machine:** clone and run set-up there. `local/` belongs to one machine; copy it yourself if you want
  the same vault on both.
- **Remove:** have her finish or drop the open tasks first, so that worker sessions are closed and nothing made
  for a task is left behind. Then delete the folder, and the folder for task workspaces you chose at set-up.

## How she works

- **A task** is one thing you asked for. She picks its workflow (answer, investigate, research, build, planned
  build or review), launches a worker session for each step that needs one, checks each report against the
  facts, and closes the task only when they show it is done: a commit, a pull request, a test result, the file
  as it stands.
- **Workers** are ordinary sessions of your harness in the project's folder, each in a role: planner, builder,
  investigator, researcher or reviewer. A worker loads the project's instructions and your global ones, and
  nothing of Laima's; its brief carries the rest.
- **Everything is written down** when it happens: a record for each task beyond a quick answer and one log
  file per day, in `local/`.
- **She learns.** At the end of a day, `wrap-up` checks that nothing was dropped, and `consolidate` files what
  the day taught: your preferences into `user.md`, facts about a project into its note, and lessons that cross
  projects into `local/Laima/knowledge/`.
- **Without asking** she launches sessions, creates workspaces and, where a project works that way, commits,
  pushes a branch and opens a pull request. **Only on your word** does she merge or deploy. Your rules or a
  project note can widen or narrow this: `AGENTS.md` § Authority.

### Walk through a pull request review

You ask, “Review the retry change in the file importer before it merges.” This example uses an invented
project and the review steps exercised during the week.

1. Laima opens a task record and pins the reviewer to the pull request head. The reviewer checks that
   revision in its own tab and drafts findings there. One shows how a retry can upload a file twice.
2. You discuss that finding in the reviewer's tab and approve only its inline comment. The reviewer posts
   the approved text on the pinned head and reports the link to Laima.
3. Laima checks the posted comment and reviewed head, tells you the outcome, and records it. She keeps the
   reviewer available if you are still using the tab and closes it when that hold ends. Any code change
   or merge follows its own project rules.

[Review workflow](workflows/review.md)

## What is where

- `AGENTS.md`: how Laima works, written for her. The entry point; start here to understand or change her.
- `persona.md`, `roles/`, `workflows/`, `.agents/skills/`, `adapters/`, `docs/`, `templates/`: the core, generic and
  tracked in git.
- `adapters/harnesses/`, `adapters/multiplexers/`: how Laima does each session action with one harness or
  multiplexer, one file per tool. Beside a multiplexer's file, a folder holds its `gotchas.md`, which sessions outside
  Laima need as well, and for Herdr and cmux a companion skill.
- `docs/testing.md`: how to test the core by hand after a change, in a throwaway copy. Each scenario costs a model
  session.
- `CONTRIBUTING.md`: what a contribution needs before its pull request.
- `local/`: your private vault: who you are, your projects, task records, the log, notes. Git ignores everything
  in it except the `AGENTS.md` guidance files, so it is never pushed. It is a git repository of its own, never
  pushed either, which she commits at each wrap-up, so a bad write can be undone.
- In the vault, `local/work/` holds task records and their archive. `local/Laima/` holds operating context,
  curated knowledge, projects and the coordination log. `local/Laima/AGENTS.md` governs the whole vault.
  If upgrading from the previous layout, move the existing private context and its pointers before starting
  a session on the updated core. Keep the task paths at the vault root.

## Making her yours

- Who she is to you: `local/Laima/persona.md`. Your rules: `local/Laima/user.md`. The harness and model for each role:
  `local/Laima/setup.md`. Rules for one project: a note in `local/Laima/projects/`.
- A workflow, role or skill of your own: `local/Laima/workflows/`, `local/Laima/roles/`, `local/Laima/skills/`.
  These live in your private vault and survive core updates. For example, you can add a recipe to oversee a
  group of workers, teach in a separate tab, or scout for information on demand. A fresh clone ships the six
  workflows listed above. Set up any such recipe locally. [Vault guide](local/Laima/AGENTS.md#the-users-own-workflows-roles-and-skills)
- Notes of your own beside hers: keep the folder in `local/` as a plain folder (the vault's git would hold a
  repository of its own as a pointer only) and list it in `local/Laima/user.md` § Notes areas with who writes there and
  how. She reads it, writes there only as that line says, and commits it with the vault at each wrap-up.
- The core changes through her `authoring` skill, for a miss that happened or because you ask.
- Herdr or cmux know-how in your other sessions too: link the companion skill of the multiplexer you use,
  `adapters/multiplexers/<multiplexer>/`, into `~/.claude/skills/<multiplexer>` and `~/.agents/skills/<multiplexer>`.
  Those sessions then read the core folder as it stands: a `git pull`, or an edit not yet committed, changes what
  they read.

## Contributing

Issues and pull requests are welcome. Before you open one, read `CONTRIBUTING.md`: what belongs in the core, how a
change fits Laima's goals, and how to test it and show that you did.

## License

MIT. See `LICENSE`.
