# Local Agent Handoff Template

Use this template for a bounded local task. It implements the E3/E4 evidence requirements in the [SOP v1.1](../ethan-local-multi-agent-codex-throttling-sop-v1.1.md). Fill it from command output; do not replace missing telemetry with an assertion.

## Version-Sync Gate

```bash
cd "<REPO_PATH>"
git fetch origin
git branch --show-current
git status --short
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>&1 || echo "No upstream"
git rev-parse @{u} 2>&1 || true
```

Record the branch, worktree, local HEAD, and upstream HEAD. If the worktree is dirty, stop unless the task packet explicitly preserves the listed changes. If local is behind, stop and report it; run `git pull --ff-only` only when the task packet explicitly authorizes it. If fast-forward is impossible, stop. Do not silently sync, merge, rebase, or reset.

## Task Contract

| Field | Value |
| --- | --- |
| Goal | |
| Risk level | |
| Repo and worktree | |
| Branch | |
| Base SHA | |
| Local HEAD before | |
| Upstream SHA | |
| Allowed files | |
| Forbidden files | |
| Allowed commands | |
| Forbidden actions | push, merge, rebase, reset, clean, signing, billing, secrets, credentials, release, and any unapproved scope expansion |

### Acceptance Criteria

```text
1. [ ]
2. [ ]
3. [ ]
```

### Stop Conditions

- [ ] Worktree is dirty or branch/upstream identity disagrees with the task packet.
- [ ] A fast-forward is needed but not explicitly authorized, or is impossible.
- [ ] A forbidden or protected file is required.
- [ ] Scope needs to expand, validation fails unexpectedly, or an assumption is contradicted.
- [ ] The task requires secrets, auth, signing, billing, release work, or an unapproved external write.
- [ ] A second write-capable executor would operate in the same repo, worktree, branch, and task window.

Read-only review, risk lists, log summaries, and review-packet generation may happen in parallel. Only one executor may write.

## E3/E4 Evidence Package

### 1. Executor and Preflight

| Field | Value |
| --- | --- |
| Executor and version | |
| Agent/model/profile, if applicable | |
| Permission or sandbox mode | |
| Dangerous permissions used | yes / no |
| Log path | |
| `git fetch origin` exit code | |
| Branch | |
| `git status --short` before | |
| Base SHA | |
| Local HEAD before | |
| Upstream SHA | |
| Worktree clean before | yes / no |

### 2. Changes

| Field | Value |
| --- | --- |
| Modified files | |
| Added files | |
| Deleted files | |
| Generated files | |
| Untracked files | |
| `git diff --stat` | |
| `git diff --check` exit code | |

### 3. Verification

For every command, include all of the following:

| Command | Exit code | Key raw-output snippet | Full log path |
| --- | --- | --- | --- |
| | | | |

State the intended evidence level: E3 for a complete evidence package, or E4 only when E3 is supplemented by reproducible validation, CI or independent verification, and clean post-run status (or a stated expected-untracked-file exception). E0 and E1 cannot support a decision.

### 4. Risks and Recommendation

```text
Known risks:
Assumptions:
Unverified items:
Potential regressions:
Stop condition triggered: yes/no; details:
Ready for GitHub-visible Web GPT or human evidence review: yes/no
Needs Codex review: yes/no; trigger:
Needs human approval: yes/no; reason:
Recommended next action:
```

Web GPT or a human reviews GitHub-visible evidence only. Web GPT is not a local command control plane and must not claim local command execution.

## Conditional Tool Notes

- Run `gitleaks` if it is available, configured, or risk-triggered. Its absence is not itself a failure unless the task policy requires it.
- If Qwen is considered for local-only material, the central context planner and local resource gate in SOP v1.1 must pass first; do not launch Qwen automatically.
- Tutti is limited to the SOP v1.1 command-only verification pilot and is not permitted for agent, review, land, or worktree orchestration.

## Final Output Format

```text
1. Preflight: pass/fail, with branch, base SHA, local HEAD, upstream SHA, and worktree state
2. Files changed: path and one-line purpose
3. Commands run: command, exit code, raw-output snippet, and log path
4. Evidence level: E3/E4, with generated and untracked files
5. Validation: `git diff --stat`, `git diff --check`, and task-specific results
6. Git status: post-run output
7. Remaining risks and stop conditions
8. Commit readiness and recommended next action
```
