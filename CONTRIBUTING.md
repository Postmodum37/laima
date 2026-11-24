# Contributing to Laima

Issues and pull requests are welcome. Laima is instructions that agent sessions follow, so a change to one of her
files changes how every user's sessions behave, and a test of it costs model sessions. This file says what a
contribution needs before you open a pull request: that it belongs in the core, that it fits what Laima is for, and
that you have run it. How to write a file is in `docs/authoring.md` and how to test one in `docs/testing.md`; this
file points to them rather than repeating them, so that each rule has one place to change.

If you make the change with Laima herself, her `authoring` skill walks through the writing rules and the checks.
What it does not do is decide whether the change should leave your machine; the three sections below are for that.

## Start from a miss or a need

Say in the pull request what went wrong in real use, or the need you have, and where it happened: the request,
what the session did instead, and the harness, model and multiplexer it ran on. A rule against a problem nobody has
met is turned down, because every line is read in every session that loads it and a line that changes nothing
thins the attention left for the rest (`docs/authoring.md` § Writing rules).

Open an issue before you build a new part (a skill, workflow, role, script or folder) or a change to what Laima is
for (README § Why and § What Laima is not). The issue settles whether it fits before you spend sessions on it. A
fix to existing lines, and an adapter for a harness or multiplexer the core does not support yet, can go straight
to a pull request.

## Core or local

The core is the same for every user; everything about you, your projects and your own additions lives in `local/`,
which never leaves your machine. A change belongs in the core only when it passes all of these:

- **A stranger would hit the same miss.** If a line in your `local/Laima/user.md`, a note in `local/Laima/projects/`,
  or a workflow, role or skill of your own would settle it, it is local, and `local/Laima/AGENTS.md` § The user's own
  workflows, roles and skills says where it goes. A core change you need only for your own setup is a cost to
  everyone else.
- **Every line is true for a stranger who cloned the repository.** It names no person, employer, project or path
  that exists on one machine. `docs/authoring.md` § Core or local has the check, with the command that finds such
  paths.
- **A fact about one tool sits in that tool's adapter**, under `adapters/harnesses/` or `adapters/multiplexers/`,
  and the general files stay in general terms. Otherwise the core turns false for users of the other tools. A
  multiplexer fact that sessions outside Laima need as well goes in that multiplexer's `gotchas.md`
  (`docs/authoring.md` § Adapter document).
- **Nothing of your vault is in the diff:** `git status --short` lists nothing under `local/` except its
  `AGENTS.md` files.

## Fit with Laima's goals

The goals are in the README (§ Why, the four goals and § What Laima is not) and in `AGENTS.md` § Lean and § The
user's setup comes first. A pull request that fits can answer yes to each of these:

- **Is it the smallest thing that settles the miss?** A change that adds a file, folder, script, skill or tool
  says in the pull request the smaller version you tried first and what it left unsettled (`authoring` step 2).
  Before building a part, check that no feature of the harness, the multiplexer or the project already does the
  job. Lean is about what earns its place, not about length: a longer line that settles the miss beats a short one
  that does not.
- **Does it work for any harness and multiplexer?** The general files describe the work; an adapter says how one
  tool does it. A change made and run on one tool says which, so that a reader does not take it to hold for all.
- **Does it stay out of the user's setup?** Laima adds nothing to global configuration or to a project's files,
  and prescribes no way of making or shipping a change; those belong to the user and the project.
- **Does it keep Laima what she is?** She is not a service, a sandbox or guard, a notification system, an inbox,
  a voice that posts for the user, or an installer. A change that moves her toward one of these is a change of
  direction: open an issue. A hook, guard or check that enforces a rule is the user's decision, proposed only
  after an incident.

## Test it by hand

Laima is tested by running her, because what has to work is what a model does with the files, on the tools people
use. Before you open the pull request, test the change yourself:

- **Run what applies to your change.** `docs/testing.md` § When to test says which runs count; a run whose failure
  would change nothing is skipped.
  - A general file (the root `AGENTS.md`, `persona.md`, a role, a workflow, a template): the check from
    `docs/authoring.md` § Checks the harnesses ship that shows your harness loads it, and the scenarios in
    `docs/testing.md` that use the file, in a throwaway copy on your real multiplexer.
  - A skill: the same, plus one start case and one near miss from its `cases.md`, and its `Verified:` line names
    the harness versions you ran it on (`authoring` step 6).
  - An adapter: its headings walked on the tool it is about (`docs/testing.md` § The adapters), and its
    `Version checked:` line moved to the version you ran.
  - The README or a guide for people: no run; check that each thing it states holds.
- **Use the tools you have.** One harness and one multiplexer is enough for a change to the general files. An
  adapter can only be tested on its own tool, so a change to the Rex adapter needs Rex.
- **Use the model the role runs on.** A change to how Laima's own session behaves runs on a top-tier model, since
  that is what the README requires of it; a worker role's on the model you would give that role. A smaller model
  is a probe: a failure only there is a limit to note, not a defect (`docs/testing.md` § Which model).
- **Load the core alone where your harness allows** (`docs/testing.md` § Core alone), because your own global
  instructions and skills can hide a gap in the core. Where you cannot, say so.

## The commit message

A commit holds one change, made in the files that own it, that can be read and reverted on its own. Users update
with `git pull` and read `git log` to see what changed in how their sessions behave, so the message is their
changelog. Write it in this form:

    <area>: <what the change does, in the imperative>

    <The miss or need: what happened, on which harness, model and multiplexer, and what should have happened.>

    <What changed, one line per file when there are several, and why that file.>

    Checks: <each check and scenario run, with tool versions, model and what it showed>
    Not run: <what was not run, and why>
    Closes #<issue>

- The subject stays within 72 characters, aiming at 50, with no full stop: GitHub cuts a longer one.
- Start every subject with `<area>: `. Use the changed part's established name and spelling, such as `Herdr adapter`,
  `finish` or `README`, and the owning part's name when related files change with it. Use `core` only for one change,
  revertible on its own, that has no single owning part; several fixes are several commits.
- The body wraps at 72 characters, because `git log` indents it and does not wrap.
- The one trailer is `Closes #<issue>`, when an issue exists. Which agent wrote a contributor's change goes in their
  pull request (§ What the pull request says); the maintainer's commits name none.
- The message is published with the files, so it passes `docs/authoring.md` § Core or local as a core file does.
  It tells the miss in general terms ("the first live session"), with no task id, record path, project or person.

## What the pull request says

The maintainer commits to `main` directly; every other change comes as a pull request. A pull request is
squash-merged: its title becomes the commit's subject and its description the message, so it holds one change, its
title follows § The commit message, and its description starts from that message, with what is missing added:

- The miss or need, and where it happened.
- Why it belongs in the core and not in `local/`, in a line, when the miss does not already show it.
- For a new part, the smaller version tried and what it left unsettled.
- Each check and scenario you ran: its name, the harness and its version, the model and effort, the multiplexer
  and its version, whether the core ran alone, and the result with the evidence for it (what the session did).
- What you did not run, and why: most often a harness, multiplexer or model you do not have. A part of the change
  that is about one tool (an adapter, or a line that holds for some tools only) is narrowed to the tools you ran it
  on: it lands only for those, and the rest stays as it was.
- If an agent wrote the change, which harness and model. A review from a provider that did not write it catches
  more, and the reviewer can only choose one when they know.

## Changes made with agents

Most changes to Laima are made with an agent, often with Laima herself, and that is welcome. You are the
contributor: read every line of the diff, judge the test results yourself rather than take an agent's word that
they passed, and be ready to answer for each line in review. A session's report is a lead to check, here as in
Laima's own work (`AGENTS.md` § Look before you speak). Edit the pull request text down to what a reviewer needs:
an agent tends to write more than that.

## License

A contribution is accepted under the project's license, MIT (`LICENSE`).
