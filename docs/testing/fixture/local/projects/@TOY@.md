---
project: @TOY@
updated: @DAY2@
---
## Done means
The user, @DAY2@: "A change is a commit on the task's own branch. I merge that branch into main myself. Done
means the tests pass and I merged it." The task stays open until main contains the commit
(`git -C @TOYPATH@ merge-base --is-ancestor <commit> main` exits 0).

## Workspaces
A task that changes code gets a new git worktree beside the repository, at `@SLOT@/@TOY@-worktrees/<task-id>`,
on a new branch cut from the local `main`; one such task at a time. The builder sets it up.

## Authority
Commit on the task's branch without asking. Merging into `main`, and any commit on `main`, is the user's.
There is no remote: push and deploy do not apply.
