# local/Laima/projects/: what you work on

`registry.md` lists every tracked folder, grouped under its project. A project is one or more folders worked on
together, most often git repositories. One line per folder:

```markdown
## <project>
- **<name>**: <purpose in a few words> | path: `<local path>` | remote: <url or none> | instructions: `<the instruction files in the folder (AGENTS.md, CLAUDE.md, .claude/CLAUDE.md, GEMINI.md), or none>`
```

The name is the key; the path is a lead, so check it exists before launching there.

A project note, `<project>.md`, exists only for what the project's own files do not hold. Create it when there
is such a fact, with only the headings that have content:

```markdown
---
project: <name>
updated: YYYY-MM-DD
---
## Relates to          other projects, and how
## Issues              where work comes from and how it is tracked
## Done means          the definition of done; who reviews; how a change ships (in place, a commit, a pull request)
## Workflow and harness   which workflow, harness or model its work needs, and why
## Workspaces          where and how a task makes its change (the folder itself, a branch, new or kept
                       worktrees and their place), how many tasks may at once, and what is heavy to run
## Authority           what this project grants or restricts beyond the default
## Obligations         standing duties for any work here, such as a log to keep updated
## Existing memory     pointers to memory the harnesses already hold for it
```

- Facts about the project stay in its own files: read its instruction file and the files when you need them.
  How a change is made and shipped goes in the note only where those files and the user's global rules are silent.
- Dormant folders get no line and no note. Add one through the `set-up` skill when work starts there.
- Existing memory is pointed to, never copied in.
