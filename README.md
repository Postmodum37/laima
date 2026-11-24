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

**Status:** early. The core is built, and a test task has run from request to finish under each of the three
multiplexers. Daily use is starting; expect it to change.

An illustration of a day, with invented projects:

```
you     Add a --json option to the report command in billing-tools. I want to see the design first.
Laima   Opened as a planned build. The planner has its own tab; I'll bring you the plan when it has been reviewed.

you     What needs me?
Laima   One thing: the --json plan is ready, with two questions and my recommendation on each.
        Running: the flaky-test investigation in web-app. Finished today: the README fix, merged as #212.
```

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
- **Any harness, any multiplexer.** The core describes the work in general terms; one adapter document per tool
  says how that tool does each step. A new tool needs a new document.
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

- macOS. It is the only system she has run on; Linux is untried.
- A harness. One is enough; with more, each role can run where it suits, and a review can come from a provider
  that did not write the change. What each has run as so far:
  - [Claude Code](https://claude.com/product/claude-code): Laima's own session, and workers.
  - [Codex CLI](https://github.com/openai/codex): workers, and Laima's own session in tests: it started a session
    and ran a task from request to finish, but also did part of its workers' steps itself, beside them.
  - Google's [Antigravity CLI](https://antigravity.google) (`agy`): workers, and Laima's own session in tests: it
    started a session, took the right workflow for six requests and ran a task from request to finish. Read its
    adapter's note on consumer plans before using it.

  Laima's own session needs a model of the harness's top tier: in tests a small model opened no task record and
  did the work itself.
- A terminal multiplexer. A test task has run from request to finish under each of these three; Claude Code and
  Codex workers have run from her briefs under each, and agy workers have run under each.
  - [Herdr](https://github.com/herdrdev/herdr-app), with its core [herdr-core](https://github.com/herdrdev/herdr-core),
    is the default suggestion and holds a slight edge for now: it is open source (Apache-2.0), and it splits into
    workspaces, with an agent view for each.
  - [Rex](https://www.superlogical.com/rex) is as strong an option. It is in invite-only beta; you can apply for it
    on its site.
  - [cmux](https://github.com/manaflow-ai/cmux) is supported too. On a default cmux she has to run in a cmux
    terminal.
- `jq`, and git to clone and update Laima herself. Your projects need neither git nor pull requests: she works
  with what each one already uses.

Each tool's adapter is in `adapters/harnesses/` or `adapters/multiplexers/`, with the version it was last checked
against on its `Version checked:` line. Any other harness or multiplexer needs an adapter document, and
`docs/authoring.md` lists the questions it has to answer.

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
2. Open a tab in that folder in your multiplexer and start your harness. Claude Code (`claude`) is the tested lead.
   Codex CLI (`codex`) and Antigravity CLI (`agy`) have run as Laima in tests only: read Requirements and the
   harness's adapter before you use one as her. The harness asks once whether you trust the folder.
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
  They add to the core, are never pushed, and an update of the core does not touch them. Ask her to make one.
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
