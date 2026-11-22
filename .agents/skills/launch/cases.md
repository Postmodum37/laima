# Trigger cases: launch

Should start the skill:

- "Fix the flaky login test in the web app." (Build step 1 needs a builder)
- "Find out why the nightly job got slower."
- "Keep an eye on the session I started in the other tab."
- "The reviewer wants changes; get the builder back on it." (resume from its session id)

Near misses, with what handles each:

- "What is the builder doing?" → look at the sessions; multiplexer adapter § Read a session.
- "What does the registry say about the web app?" → Answer workflow.
- "The builder says it's done." → check the report, then the workflow's next step or `finish`.
