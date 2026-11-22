# local/knowledge/: curated notes

Durable notes that will change how a later task is done: a lesson from a finished task, a decision that outlives
its task, a researcher's note worth keeping, a fact about the user's systems that no project's files record.

One topic per note, named for the topic in kebab-case (`worktree-cleanup.md`). Update the note that exists before
adding a new one.

```markdown
---
topic: <a few words>
updated: YYYY-MM-DD
origin: task | user | external     # external = taken from a web page or fetched document
source: "[[task-id]]" or a URL
---
The fact or lesson in a sentence or two, then the detail.
**Why:** what happened that taught it.
**Applies when:** the situation in which to recall it.
```

- **Belongs elsewhere:** a fact a project's own files hold (read them); a fact about one project's workings
  (`projects/`); the story of one task (its record); a preference of the user (`user.md`).
- A note enters through the `consolidate` skill, at the delivery of a Research task (`workflows/research.md`), or
  when the user says "remember this". Log `promoted`.
- Every note is linked from the map in `local/index.md`; a note nobody can find is lost.
- Delete a note that turned out wrong, and correct one that went stale when you notice it.
