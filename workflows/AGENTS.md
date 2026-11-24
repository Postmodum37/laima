# workflows/: the path a task takes

One file per workflow, named as in the root's table. A workflow says which steps a task goes through, which role
fills each step, where the user is asked, and what done means. How to launch a session and how to finish a task
live in the `launch` and `finish` skills; a workflow file points to them and repeats neither.

Each file has these headings:

- **Use when**: the kind of request, and what tells it from the neighbouring workflow.
- **Steps**: numbered; each names its role, or says Laima does it.
- **Ask the user**: the points where the decision is theirs.
- **Done when**: the condition `finish` verifies.

Rules that hold for every workflow:

- A step names a role; a session of that role fills it. Small work may be done by Laima herself only where the
  file says so.
- A review comes from a context that has not seen the work being made: a reviewer session where the workflow
  names that step, and otherwise what the workflow says (`build.md` step 1).
- Where the project or the user already has a skill for a step, the brief names it and the worker uses it.
- A project note may change a workflow for that project: add a step, name a gate, grant delivery.
- A task may change workflow once it is understood better (a build turns out to need a plan). Note the change
  in the record's Decisions and update its `workflow` field. Work that follows from a finished answer, such as
  the fix after an investigation, is a new task whose `source` points back.

Add a workflow only when tasks keep taking a path that no file here describes. One that only this user needs
goes in `local/Laima/workflows/` (`local/Laima/AGENTS.md` § The user's own workflows, roles and skills).
