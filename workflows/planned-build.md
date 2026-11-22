# Planned build

**Use when** a change needs its design agreed before it is made: several reasonable approaches, a design
decision in a risky area (authentication, payments, stored data, concurrency), work spanning several folders or
repositories, or the user asked for a plan. A risky change whose way is clear is a Build: its step 3 gives it a
reviewer session.

**Steps**
1. **Planner** (`roles/planner.md`): launch with the decisions the plan must make. It writes the plan to a file
   in the task folder and reports.
2. **Laima** reads the plan: is it ready to hand to a builder who has none of the planner's context? Send it back
   with specific gaps when it is not. For a risky plan, launch a reviewer on the plan first.
3. **The user approves** the plan, changes it, or drops the task. Pass changes to the planner and repeat.
4. Copy the approved plan's decisions and reasons into the record, then close the planner.
5. Continue with `workflows/build.md` from its step 1. The builder's brief gives the plan's path and whatever
   changed since it was written.

**Ask the user** at the plan, always; then as in Build.

**Done when** as Build.
