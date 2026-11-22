# Build

**Use when** the user wants a change made and the way to make it is clear enough to brief. When the design needs
agreeing first, use Planned build.

**Steps**
1. **Builder** (`roles/builder.md`): launch in the place the project gives for a change (`launch` step 2). Its
   brief says how far delivery goes until you send word. The builder makes the change, verifies it, has it
   reviewed inside its own harness and reports with evidence. Laima makes the change herself, with no builder,
   when it is one command or API call the user approved in that form (a merge, closing an issue, one setting),
   followed by a read-back that shows it took effect: a session would cost more than the change. The record's
   Timeline says she made it and why, and the project's documentation rules still apply to it.
2. **Laima** checks the report against facts: the change is where the report says (the commit on its branch, or
   the files in the folder), the verification named in "Done when" was run and passed, and the builder's review
   ran, with each finding fixed or answered. Run or read it yourself when it is cheap. Write into the record
   where the change is and what the builder made for it (a branch, a worktree: the record's `branch` and `worktree`
   fields).
3. **Reviewer** (`roles/reviewer.md`), only when the change touches a risky area (authentication, payments,
   stored data, concurrency), follows an approved plan, or the project note or the user asks for one: a new
   session, pinned to the commit or to the files as they stand, while the builder waits. Any other change goes
   to step 5 on the builder's own review: a session for each step costs a handoff and a wait, which pays only
   where a miss is expensive.
4. **Builder** fixes what the reviewer found and reports the new state. Read the fix yourself (under git,
   `git diff <reviewed>..<new>`; otherwise the files the builder lists as changed). When it changed logic,
   repeat steps 2 to 4; a second round of review needs a reason, a third needs the user.
5. **Deliver and finish** with the `finish` skill: its step 2 says how the reviewed change is delivered, and it
   stops there while a pull request or a merge waits. Where the project ships by pull request, delivery starts
   with your word to the builder to push the branch and open one.

**Ask the user** before a merge or a deploy, unless the project note grants it; and when the reviewer and the
builder disagree and the evidence does not settle it.

**Done when** the project's definition of done is met and verified. Without one: the user has the change where
the project keeps a finished one (the pull request merged where it uses them, otherwise the commit or the files
in its folder) or has taken the work over. Outcome `delivered`.

While a pull request waits, the task stays open. A merge that is the user's is a question in the record; a wait
on other people is `waiting_on` with the next look (`not_before`). Look at the pull request's state (merged,
changes requested, checks failed) when you orient and at wrap-up. A builder you launched may be closed once the
pull request is open and its checks have passed, or, where delivery is a commit the user merges, once you have
checked that commit; resume it from its session id when changes are requested.
