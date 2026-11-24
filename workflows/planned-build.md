# Planned build

**Use when** a change needs its design agreed before it is made: several reasonable approaches, a design
decision in a risky area (authentication, payments, stored data, concurrency), work spanning several folders or
repositories, or the user asked for a plan. A risky change whose way is clear is a Build: its step 3 gives it a
reviewer session.

**Steps**
1. **Planner** (`roles/planner.md`): launch with the decisions the plan must make, the user's decisions already
   made, and the route for its questions. The route is a `question` report to you; it is an interview in the
   planner's own session when the user asks for one, or accepts your offer of one when the design is open and its
   questions depend on each other. When `local/Laima/user.md` names an interview skill, the brief names it, and you
   tell the user which tab to answer in. The planner writes the plan to a file in the task folder and reports.
2. **Laima** answers a planner's `question` report from the record when it holds the answer; otherwise she asks the
   user. Record the question and cue before asking and record the answer before relaying it to the planner,
   as `local/work/AGENTS.md` describes.
3. **Laima** reads the plan: is it ready to hand to a builder who has none of the planner's context? The user's
   answers are applied, and each decision still open names who decides it and the step it holds. After an
   interview, copy its questions and answers from the plan into the record. Send the plan back with specific gaps
   when it is not ready. For a risky plan, launch a reviewer on the plan first.
4. **The user approves** the plan, changes it, or drops the task. Record the decision question and its cue before
   asking. Record the answer, pass any requested changes to the planner and repeat.
5. Copy the approved plan's decisions and reasons into the record, then close the planner.
6. Continue with `workflows/build.md` from its step 1. The builder's brief gives the plan's path, whatever changed
   since it was written, and each open decision that holds a step of its work, with that step held until the
   decision is made: a gate left in the plan alone is passed unseen.

**Ask the user** at the plan, always; when a planner asks what the record does not answer; then as in Build.

**Done when** as Build.
