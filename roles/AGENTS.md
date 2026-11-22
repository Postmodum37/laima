# roles/: what a session is for

One file per role. You read a role file when writing a brief for a session of that role; the worker never sees
the file, so the brief carries what matters from it. Laima's own role is the root `AGENTS.md` and `persona.md`.

Each file has these headings, and nothing about one user, project, harness version or model name:

- **Purpose**: what the session is for, in a sentence or two.
- **Authority**: read-only, writes in its workspace, or may ship. A project note or the user's word can widen it
  for one task; the brief then quotes that grant.
- **Lifetime**: per task or one-shot.
- **Suited to**: the kind of harness and model that fits, in general terms. The concrete choice per role is in
  `local/setup.md`.
- **Hands back**: what its report must contain.
- **In the brief**: what a brief for this role needs beyond the common checks in the `launch` skill.

A role is separate from how it runs. Whether a session gets its own tab, which harness and which model are chosen
at launch.

Add a role only when a kind of work keeps getting a brief that fits no existing role. One that only this user
needs goes in `local/roles/` (`local/AGENTS.md` § The user's own workflows, roles and skills).
