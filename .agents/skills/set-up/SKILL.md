---
name: set-up
description: Use when local/ is missing a file or on a first run, when the user adds, changes or stops tracking a project, or when installed harnesses or tools changed.
---

# Set-up

Detect, then ask, then write. Safe to re-run: create what is missing, change a line only when its answer
changed, and leave every line the user edited. Reads only; no secret is opened or printed.

Set-up writes inside `local/`, creates the workspaces folder and makes the links to the user's own skills;
nothing else. A project's files, the harnesses' global settings and the core are outside its reach.

## First run, or a repair

1. **Detect what exists:** which files `local/` already holds, the "Set-up runs" section of `local/Laima/setup.md`,
   and the installed harnesses and multiplexers with their versions (`--version`, or the command the tool's adapter
   gives where it refuses that, as Rex does). Look for each tool that has an adapter in `adapters/harnesses/` or
   `adapters/multiplexers/`, and for these known ones without: the harnesses Gemini CLI (`gemini`), OpenCode
   (`opencode`), Cursor Agent (`cursor-agent`), Amp (`amp`) and Aider (`aider`); the multiplexers tmux, Zellij
   (`zellij`) and WezTerm (`wezterm`). Look by `command -v` and, on macOS, in `/Applications` as well: an app's command
   can be missing from the PATH outside its own terminals, as cmux's and Rex's are, and the multiplexer adapter's
   opening then says where it lives. Note the global instruction files and the
   skill folders of each harness by path and size. Done when you can list each tool found as supported (it has an
   adapter) or found without an adapter, the multiplexer this session runs in (the variable each multiplexer
   adapter's opening names), the global instruction files, and which `local/` files are missing.
2. **Find where the user works:** for each harness found with an adapter, run the lookup under its
   § Transcripts, "Folders worked in". It reads only folders and times; the prompts in those files stay unread.
   Drop folders that no longer exist, and fold each other one into its repository: run
   `git -C <folder> rev-parse --path-format=absolute --git-common-dir 2>/dev/null`; when the output ends in
   `/.git`, its parent is the main checkout, which takes in a worktree or a subfolder; otherwise keep the folder
   as it is (it is no repository, or a bare one or a submodule). Add up the counts per harness. Drop the Laima
   folder, the task folders, temporary folders (`/tmp`, `/private/tmp`, `/private/var/folders`) and the home
   folder. A worktree removed since cannot be folded and drops out with the folders that no longer exist. A
   folder that holds other candidates is where projects live: it answers step 4's last question, not step 7's.
   Done when you have the candidates, each with its count in each harness, and the folders that hold them.
3. **Create what is missing:** `local/work/` and `local/Laima/{log,knowledge,projects}/`. Seed
   `local/Laima/{user,setup,index,persona}.md` from the matching files in `templates/` and
   `local/Laima/projects/registry.md` from `templates/registry.md`. An existing file is left alone.
   Without `local/.git`, make `local/` a git repository
   of its own, never pushed, as the vault's undo: `git -C local init -q && git -C local config user.name Laima &&
   git -C local config user.email laima@localhost`. The core's `git status`, `git pull` and its tracked
   tracked guides in `local/` work as before with it there. The `AGENTS.md` files in `local/` come with the
   core. For each folder in `local/Laima/skills/` that lacks its two links, as on a machine `local/` was copied to,
   make them as shown in `local/Laima/AGENTS.md` § The user's own workflows, roles and skills. The first hop is
   from `.agents/skills/my-<name>` to `../../local/Laima/skills/my-<name>`.
4. **Ask about the user:** what to call them; their timezone when the clock does not settle it; anything in
   their global rules Laima should leave aside; any change to the persona; which folders hold their
   projects, offering the ones step 2 found.
5. **Write `local/Laima/user.md`:** their answers in their words, and pointers to the global instruction files. Copy
   nothing from those files: the harness loads them, and a copy goes stale. Persona changes go in
   `local/Laima/persona.md`.
6. **Detect repositories** under those folders, and take step 2's candidates with them: for each, its counts
   from step 2, its last commit date, remote (with any credentials stripped from the URL), and whether it has
   an instruction file. Each harness counts in its own unit (the adapter says which), so take a candidate's
   count as its share of that harness's total and order the candidates by their largest share in any harness.
   Folders no harness saw come after them, by last commit date, which also breaks ties. A commit date also
   moves when the user pulls other people's work, which makes it the weaker sign. A folder that is not a
   repository is tracked when the user names it or picks it from step 2's candidates.
7. **Ask which to track:** in a multi-choice dialog where the harness has one, the top four as its options,
   the most active first and marked recommended, with the rest named in the question and the free-form answer
   left open. Ask in sentences how the chosen ones group into projects. A dormant repository gets nothing.
8. **Write `local/Laima/projects/registry.md`** (format: `local/Laima/projects/AGENTS.md`).
9. **Detect existing memory** for each tracked project: the harnesses' own memory folders and instruction files
   for that folder (each harness adapter § Instruction files it loads says where they are, where that is known).
   List each with its age and size; open none of it in bulk.
10. **Ask, per project, only what the code cannot tell:** where issues come from, what done means and who
    reviews, where and how a task makes a change and how it ships when the project's own instructions and the
    user's global ones do not say, how many tasks may at once, which harness its work needs, what it grants or
    restricts, standing obligations. The user may skip any.
11. **Write a project note** where there were answers, with pointers to the existing memory.
12. **Write `local/Laima/setup.md`:** the multiplexer and harnesses found; the Roles section (a usual row per role,
    and the entries the user wants for a raised step and for a provider running short), taken from the user's
    choices or, without one, from the guidance in the role file matched to the models installed; the task
    folders' location (create the folder); tools a brief can rely on. A multiplexer or harness without an
    adapter is listed as found and unusable until one is written (`authoring`). When more than one multiplexer
    found has an adapter, recommend the one this session runs in. When cmux and agy are both found, ask the
    user once whether cmux may keep the hooks its `agy` wrapper adds to their agy configuration (cmux adapter
    § Gotchas), and write the answer under § Multiplexer. cmux by default takes commands only from its own
    terminals, so there you have to run in one (`adapters/multiplexers/cmux.md`). Laima has no role file: her own row
    takes a model of the harness's top tier. When the user chooses a smaller one, tell them that in tests a
    small model opened no task record and did the work itself.
13. **Finish**, when this run changed anything: update the lines of `local/Laima/index.md` it affects; log
    `- HH:MM [[laima]] set-up — <what was detected, asked and written>`; and replace the line under "Set-up
    runs" with this run's date and what it changed, in a line. Every session reads `local/Laima/setup.md`, so the
    history of runs stays in the log. A run that changed nothing writes nothing.

Done when `local/.git` exists, the private files seeded in step 3 exist under `local/Laima/`,
`git status --short` in the Laima folder shows none of them, and a second run would change nothing.

## When the user cannot answer now

Write what detection alone supports, and list every unasked question under "Not asked yet" in `local/Laima/setup.md`.
Mark a value you inferred as `(inferred, not confirmed)`. List step 2's candidates, most active first, and the
repositories under the folder that holds the Laima folder with commits in the last two weeks, under "Not asked
yet" as candidates to track; the registry takes only folders the user named. Write a project note only for
what the user stated. The next run starts by asking those questions.

## Add, change or stop tracking a project

Run steps 6 to 11 for that project alone, then step 13. To stop tracking, first ask the user what becomes of
the project's open tasks and settle them; then remove its registry lines and move its note to
`local/Laima/projects/archive/`. Its task records stay.

## When tools changed

Run steps 1 and 12, and compare the versions found with the "Version checked" line of each adapter. A newer
version than the adapter was checked against is reported to the user as a reason to re-check the adapter
(`docs/authoring.md` § Adapter document says how).

Verified: 2026-11-24, Claude Code 2.1.331 (unchanged rerun in the Laima/ layout); 2026-11-22, Claude Code 2.1.327 to 2.1.330 and Codex 0.170.0. Not yet run: seeding set-up in the Laima/ layout; the first-run questions asked live; re-making the links to the user's own skills; step 13 keeping one line; step 12's line on Laima's own row; the tools without an adapter and the multiplexer recommendation; a version read from a tool that refuses `--version`; the vault's repository made by step 3; step 12's question on cmux's agy hooks; step 9 by the memory folders the harness adapters now name.
