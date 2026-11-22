---
name: finish
description: Use when a task's last step has reported, when the user says a task is done or should be dropped, or when a task found at wrap-up should be closed.
---

# Finish

A task is finished when every step below is done. Stopping after step 2 is normal when delivery waits on the
user or on other people; the task then stays open and you return here later.

1. **Verify the work** against the record's "Done when", leaving aside the conditions that are the delivery
   itself. Look at the facts yourself: the change where it should be (the commit on the branch, the files in the
   folder), the result of the check, the reviewer's verdict on that state, or on the one before it when you read
   the difference yourself and it changed no logic. Done when each such condition is shown met, with its
   evidence noted. When one is unmet, the task is still running: take the workflow's next step or ask the user.
   A task being dropped skips to step 3 with the reason.
2. **Deliver** what the workflow says, as far as `AGENTS.md` § Authority and the project note allow. This step
   holds how a result is delivered; a workflow adds only what is its own.
   - An answer or findings go to the user.
   - A reviewed change ships the way the project ships one. Where that is a pull request: the branch pushed and
     the pull request opened, then merged; tell the user it is ready. Where the change is made in place: tell
     the user what changed and what was checked. Any other way (a commit, a push) goes as far as the project's
     rules say, and you tell the user where the change is. A merge or a deploy waits for the user's word or the
     project note's grant.

   Where the project or the user has a skill, command or template for a delivery step (a pull request's text, a
   release, an update to the issue), use it. What the project asks at the end of a task is part of delivery: the
   issue updated or closed and the standing duties, as its note's § Done means and § Obligations say. A delivery step
   that needs the user's word becomes a question with your recommendation, naming the commit or the files: write it in
   the record, log `asked`, and stop here. Done when the delivery the record's "Done when" names is shown: the user has
   the answer, the change is where the project's definition of done puts it (on the remote's main branch, in the
   folder), or the user has taken the work over.
3. **Copy out** before anything is removed. From the reports and the files in the workspace into the record: the
   outcome with evidence, decisions with reasons, verification commands with results, follow-ups. A file the
   record's "Done when" names as the user's deliverable (a note, a report or a plan they asked to have) leaves the
   task folder first: to where the user keeps such files when they said where, otherwise into `local/` (a
   knowledge note, or the record itself); the record names its final path. Done when the record makes sense to a
   reader who has no transcript and no workspace, and no deliverable is left in the task folder.
4. **Close the sessions you launched** for the task, by the ids its record holds: read each one's screen, confirm
   it is idle with nothing unreported, then close it (multiplexer adapter § Close a session). An adopted session is
   the user's and stays: tell them the task is closed. A session tagged with the task id that the record does not
   name is not one you can show is yours: leave it and tell the user it is there. Done when the listing shows none
   of the record's sessions of yours.
5. **Remove the workspace:** whatever the record says was made for the task alone (a worktree, a branch, a
   reviewer's copy) and the task folder. First show that nothing would be lost.
   - A worktree of the task, under git: after `git fetch --prune` where there is a remote, `git status --short`
     is empty, the ignored files (`git status --short --ignored`) hold nothing to keep, and, where the project
     ships to a remote, `git log --oneline HEAD --not --remotes` prints nothing, or the project's own tool shows
     the delivery done: the pull request merged with its head at the commit that was reviewed (on GitHub,
     `gh pr view <pr> --json state,headRefOid` shows `MERGED` and the commit `git rev-parse HEAD` prints). A
     squash or rebase merge puts other commits on the remote, so only that second form shows it.
   - A change made in a place the project keeps (its folder, its checkout, a kept worktree): the place is in
     the state its rules ask for, committed where they ask for commits, and nothing is removed there.
   - Without version control: each file the builder listed is in the project's folder, and none exists only in
     the task folder.

   Then remove what was made for the task, with the project's own command when it has one. Delete a local
   branch that was merged, once no checkout is on it (`git branch -D` for one the tool showed merged by a squash
   or rebase, since git does not count it as merged), and delete the task folder once nothing in it is still
   needed. Anything uncommitted, unpushed or unexplained stops this step and becomes a question to the user.
   Done when nothing made for the task alone is left, the task folder is gone and the record's `worktree`
   field is empty.
6. **Complete the record:** `closed`, `outcome`, and each follow-up either opened as its own task (with `source`
   pointing here, and `not_before` when it is for a later date) or listed under Follow-ups. A lesson that would
   change how a later task is done goes under Follow-ups as a line starting `lesson:`, for `consolidate`.
7. **Log** `finished` with the outcome (`delivered`, `answered`, or `failed` with the reason), or `dropped` with
   the reason, and the evidence. In `local/index.md`, remove
   the task's lines under "Needs the user" and add it under "Recently finished".
8. **Tell the user** in a line or two: what was delivered, where it is, and what follows.

Verified: 2026-11-21, Claude Code 2.1.327 to 2.1.330 and Codex 0.170.0, on herdr (hc 0.1.21) and cmux 0.65.2. Not yet run: a pull request on GitHub; delivery by a push without a pull request; a worktree the project keeps; a dated follow-up first opened by step 6; the issue update and the note's duties at delivery; the record's field read as `worktree`; a squash or rebase merge shown by the project's tool; a deliverable moved out of the task folder; a tagged session the record does not name.
