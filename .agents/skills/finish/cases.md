# Trigger cases: finish

Should start the skill:

- A reviewer reports "ready" and the pull request is open.
- "That one's merged, close it out."
- "Drop the caching task, we won't do it."
- Wrap-up finds a task whose pull request merged days ago.

Near misses, with what handles each:

- A builder reports done and the workflow has a step left before delivery (its reviewer session, for a risky or
  planned change) → that step, through `launch`.
- "Close that tab." → multiplexer adapter § Close a session, when the task itself stays open.
- "Are we done for today?" → `wrap-up`.
