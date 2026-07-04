# Agent Workspace

Purpose: give AI coding agents a small, filesystem-style entrypoint before they read large docs, logs, or source files.

## Read order

1. `.agent/current_state.md` — generated repo snapshot.
2. `.agent/catalog.json` — machine-readable entrypoints and validation commands.
3. `PROJECT_COMMAND_CENTER.md` or `AGENTS.md` — durable project-specific rules.
4. Scoped source files, diffs, and logs only after the above index points to them.

## Operating pattern

Use:

```text
ls -> grep -> read scoped files -> cite evidence -> run validation -> write run artifact
```

Avoid:

- reading the entire repository into context;
- scanning outside the git repo root;
- copying secrets or noisy runtime logs into final outputs;
- changing Bundle IDs, product IDs, entitlement rules, privacy text, or release metadata unless explicitly scoped.

## Runtime artifact rule

Per-task runtime output belongs under `.agent/runs/<timestamp>_<slug>/`. These files are generated evidence, not durable product documentation. Promote only verified lessons into `AGENTS.md`, `PROJECT_COMMAND_CENTER.md`, a checklist, or a skill.
