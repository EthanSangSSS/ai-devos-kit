# Agent Run Artifact Schema

Each local agent task should create one directory:

```text
.agent/runs/YYYYMMDD_HHMMSS_<slug>/
```

Required files:

| File | Purpose |
|---|---|
| `task.md` | Goal, scope, forbidden changes, user constraints. |
| `preflight.md` | Version sync gate, repo root, branch, HEAD, initial status. |
| `git_state_before.txt` | Raw bounded git status/diff evidence before work. |
| `commands.log` | Commands run and pass/fail observations. |
| `validation.md` | Validation commands and bounded evidence summaries. |
| `open_loops.md` | Remaining assumptions, risks, unresolved follow-ups. |
| `final_output.md` | User-facing final status in a repeatable format. |
| `telemetry.json` | Structured counters and validation status. |

Telemetry fields should include at least:

```json
{
  "schema_version": "1",
  "created_at": "YYYYMMDD_HHMMSS",
  "repo_root": "/path/to/repo",
  "branch": "branch-name",
  "head_before": "commit-sha",
  "head_after": null,
  "agent": null,
  "commands_run": 0,
  "failed_commands": 0,
  "files_read": 0,
  "files_modified": 0,
  "validation_passed": null,
  "human_review_required": true
}
```

Promotion rule: do not commit noisy runtime logs by default. Commit only curated evidence when it is useful for review, audit, or future SOP improvement.
