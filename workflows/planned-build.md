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
   when it is not ready. For a risky or revised design, check the shape and proof called for by
   `roles/planner.md`. For a risky plan, launch a reviewer on the plan first. A finding names a broken
   requirement or operation and the smallest correction that preserves the existing protections. Tie a
   further pass to a substantive risk or a change in behavior or evidence. Use a fresh reviewer context
   for a materially revised design and follow the project's review rules.
4. **The user approves** the plan, changes it, or drops the task. Record the decision question and its cue before
   asking. Record the answer, pass any requested changes to the planner and repeat.
5. **Laima** checks the approved plan and copies its decisions and reasons into the record. Once she has the
   verified plan and decisions for the builder handoff, apply `finish` step 4 to the planner.
6. **Laima** continues with `workflows/build.md` from its step 1. Give the builder the plan's path and what changed
   since it was written. Apply `launch` § The brief, Authority, using the plan and the task record. Carry
   each scoped decision and exact held step to the next builder, reviewer or delivery owner, including
   on resume. Check what changed before releasing the step. At Build's review decision, apply the same
   reason for a further pass as in step 3 here, within Build's own review gates.

**Ask the user** at the plan, always; when a planner asks what the record does not answer; then as in Build.

**Done when** as Build.
