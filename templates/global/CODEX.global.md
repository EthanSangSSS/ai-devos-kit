# Optional CODEX entrypoint

Use `AGENTS.global.md` from this kit as the single governance source. Copy it only to the one instruction file actually loaded by the target runtime. Do not install multiple identical global instruction files in one session. Executor-specific settings belong in the task's runtime contract, not here.
