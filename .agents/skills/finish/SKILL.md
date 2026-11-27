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
   - A message a session drafted for the user to send to other people is delivered once it is in the record and
     the user has been told where it is. Sending the copied draft is the user's step. For text still in a live
     input, use the hold in step 4.
   - A reviewed change ships the way the project ships one. Where that is a pull request: the branch pushed and
     the pull request opened, then merged; tell the user it is ready. Where the change is made in place: tell
     the user what changed and what was checked. Any other way (a commit, a push) goes as far as the project's
     rules say, and you tell the user where the change is. A merge or a deploy waits for the user's word or the
     project note's grant. Before you ask for a merge, or make one, read what the merge sets off on the target branch
     (a deploy, a release) and whether that branch's own checks pass now (on GitHub, `gh run list --branch <branch>
     --limit 5`): a check failing there for a cause outside the change stops the release after the merge as well.
     Put both in the merge question, and call the change live only once the run after the merge shows it.

   Where the project or the user has a skill, command or template for a delivery step (a pull request's text, a
   release, an update to the issue), use it. What the project asks at the end of a task is part of delivery: the
   issue updated or closed and the standing duties, as its note's § Done means and § Obligations say. A delivery step
   that needs the user's word becomes a question with your recommendation, naming the commit or the files: write it in
   the record with `needs_user` as `local/work/AGENTS.md` describes, log `asked`, and stop here. Done when the
   delivery the record's "Done when" names is shown: the user has the answer, the change is where the project's
   definition of done puts it (on the remote's main branch, in the folder), or the user has taken the work over.
3. **Copy out** before anything is removed. From the reports and the files in the workspace into the record: the
   outcome with evidence, decisions with reasons, verification commands with results, each review finding in a
   line with what became of it, follow-ups. A file the
   record's "Done when" names as the user's deliverable (a note, a report or a plan they asked to have) leaves the
   task folder first: to where the user keeps such files when they said where, otherwise into `local/` (a
   knowledge note, or the record itself); the record names its final path. Done when the record makes sense to a
   reader who has no transcript and no workspace, and no deliverable is left in the task folder.
4. **Release a worker** at handoff, during a delivery wait, or at final cleanup. Check the report against
   facts. For a final result or decision, give the user a synthesis they can use before closing. For an
   intermediate result, preserve it and hand it to the verified next owner first. If a required artifact is
   missing, use `launch` step 7 and hold the handoff until it is recovered or replaced with a verified durable source.
   - Confirm ownership from the record and live listing. Read the screen, last task or user action and any
     downstream references. If the user is reading or discussing, there is text in the live input, this tab holds
     a decision or next action, or the user asked you to keep it, record the tab or address, its use and its
     release event in the Timeline. Keep the parent chain of a held descendant. Ask when use or authority still
     needs a decision.
   - Recheck at the recorded event (the approval, next relevant report or turn, or wrap-up). If the user set the
     hold, release it only on their stated event or instruction. Once delivery is settled and the owned session
     is idle with nothing unreported and no hold on it or a descendant, close it (multiplexer adapter § Close a
     session), then check the listing. A reviewer that `workflows/review.md` keeps open for posting is in use until
     the reviewer reports the settled outcome and you verify and record it.
   - For a task being dropped, a session still working or at a dialog is closed as well, once step 3 holds what
     its screen shows and any live user hold has released. An adopted session is the user's and stays: tell them
     the task is closed. A session tagged with the task id that the record does not name is not one you can show
     is yours: leave it and tell the user it is there.
   Done when the listing confirms each eligible session closed and the Timeline shows any hold and its recheck.
   At final cleanup, wait for any held owned sessions to release before step 5.
5. **Remove the workspace:** whatever the record says was made for the task alone (a worktree, a branch, a
   reviewer's copy) and the task folder. First show that nothing would be lost.
   - A worktree of the task, under git: `git status --short --untracked-files=all` is empty, and the ignored files
     (`git status --short --untracked-files=all --ignored`) hold nothing to keep.
     - For a standalone Review, confirm delivery is complete, this is the recorded detached reviewer copy, and
       no other task uses it. Confirm `git rev-parse HEAD` matches the pin in the task record, original review
       brief or report. The clean copy at its recorded pin can be removed without a remote check.
     - For other worktrees, run `git fetch --prune` where there is a remote. Where the project ships to a remote,
       verify `git log --oneline HEAD --not --remotes` prints nothing or the project's own tool shows delivery done:
       the pull request merged with its head at the commit that was reviewed (on GitHub,
       `gh pr view <pr> --json state,headRefOid` shows `MERGED` and the commit `git rev-parse HEAD` prints).
       A squash or rebase merge puts other commits on the remote, so only that second form shows it.
   - A change made in a place the project keeps (its folder, its checkout, a kept worktree): the place is in
     the state its rules ask for, committed where they ask for commits, and nothing is removed there.
   - Without version control: each file the builder listed is in the project's folder, and none exists only in
     the task folder.

   Before retiring the workspace, search the other open tasks' briefs in the task folders configured in
   `local/Laima/setup.md` for references into it. Check that each needed artifact exists and matches its pin
   where recorded. Read the durable copy back and update the referring brief before removing its source. If a
   reference remains or the artifact is missing, keep the workspace and record the referring task or brief and
   the event that permits removal. Anything uncommitted, unpushed or unexplained stops this step and becomes
   a question to the user.

   Then remove what was made for the task, with the project's own command when it has one. For a standalone Review copy,
   use `git worktree remove` without force. Delete a local branch that was merged, once no checkout is on it
   (`git branch -D` for one the tool showed merged by a squash or rebase, since git does not count it as merged).
   Done when nothing made for the task alone is left, the task folder is gone and the record's `worktree` field
   is empty. Verify this separately from terminal closure in step 4.
6. **Record follow-ups and close.** Before setting `closed` and `outcome`, give each accepted, unresolved obligation
   an open record. Reuse the record for the same deliverable or open one. Include the parent link in its `source`,
   preserving existing provenance. Keep the actor or dependency, next verifiable step and dates in that record,
   and link it from Follow-ups.
   Put any decision still owed in its open record with the full question and `needs_user`, then clear the parent's
   cue. Optional ideas and settled evidence may stay as prose. A lesson that would change a later task goes under
   Follow-ups as a line starting `lesson:`, for `consolidate`. Done when every owed action links to its open record
   and the parent's `closed` and `outcome` are set.
7. **Log** `finished` with the outcome (`delivered`, `answered`, or `failed` with the reason), or `dropped` with
   the reason, and the evidence.
8. **Tell the user** in a line or two: what was delivered, where it is, and what follows.

Verified: 2026-11-26, Codex 0.172.0 on Herdr (herdr-app 0.1.18, hc 0.1.22) and Claude Code 2.1.330 (earlier). Not yet run: the revised remote-free cleanup in a live session; review findings copied in step 3; the step 5 check for another open task's brief referencing the task folder; the target branch's checks read before a merge, as now worded; delivery by a push without a pull request; a worktree the project keeps; step 2 with a scalar decision cue and step 6 with linked open obligations; the note's duties at delivery; a tagged session the record does not name; a working session of a dropped task closed by step 4; a task whose only open item is a message drafted for the user, delivered by step 2; a reviewer kept open for posting, closed by step 4 only after its outcome; worker release and recheck during a task, held descendants, and separate terminal and dependent artifact disposition.
