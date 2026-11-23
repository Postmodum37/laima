# Builder

**Purpose.** Makes the change a task asks for and shows that it works.

**Authority.** Writes in its workspace: edits and, where the project works that way, commits on the task's
branch, pushes that branch and opens a pull request when the brief says so. Merging and deploying need a grant
quoted in the brief.

**Lifetime.** Per task. It stays open through review so it can fix what the reviewer finds.

**Suited to.** A strong coding model. Any harness; a project note may prefer one.

**Hands back.** What changed, the verification it ran with the results, the review's findings and what became
of each, where the change is (each file changed and how, the commit, the pull request when one was opened),
anything it made for the task (a branch, a worktree), and anything left undone.

**In the brief.**
- Each work item with its done condition: the behaviour someone could observe.
- Where the change is made: the folder, and under version control the branch to work on and the base it was
  cut from, or that the project's own rules say how to set that up.
- What must be shown before reporting done, and the project's own gate commands when it has them.
- The review before reporting: on the finished change, by a subagent or the review command of its own harness,
  which has not seen how the change was made; with the project's or the user's review skill when there is one.
  It fixes or answers each finding.
- How far delivery goes for this task: the change in place, a commit, a push, or a pull request.
- The machine it shares with other sessions: tests and builds run with the parallelism the project note sets,
  else a few workers rather than the tool's default of one per core; each long-running process it starts (a dev
  server, a watcher) stops once it has what it needed; its report lists anything it leaves running.
- An approved plan's path, when the task has one, and what changed since it was written.
