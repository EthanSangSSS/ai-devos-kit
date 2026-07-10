# Engineering Workflow SOP

This guide complements [Ethan Local Multi-Agent Delegation and Codex Throttling SOP v1.1 Pilot](../ethan-local-multi-agent-codex-throttling-sop-v1.1.md). That SOP is authoritative for risk routing, evidence trust, local-model safety, and tool boundaries. This guide turns those controls into a practical engineering workflow.

**Purpose:** make non-trivial changes reviewable, bounded, and supported by reproducible evidence. It is not an authorization for push, merge, rebase, reset, release, signing, billing, secret access, or scope expansion.

## Operating Rules

- Make the smallest safe change that satisfies the stated acceptance criteria.
- Declare allowed files and forbidden files before editing. Stop when the task needs a file outside allowed scope.
- Only one write-capable executor may operate in the same repo, worktree, branch, and task window. Parallel work is limited to read-only review, risk lists, log summaries, or review-packet generation.
- Record facts from commands and tests; do not replace telemetry with agent assertions.
- Stop rather than silently resolving an unsafe state, unclear failure, protected-scope request, or unauthorized external action.

## Gate 0: Version Sync and Workspace Safety

Before any modification, collect the actual repository state:

```bash
git fetch origin
git branch --show-current
git status --short
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>&1 || echo "No upstream"
git rev-parse @{u} 2>&1 || true
```

Record the branch, worktree state, local HEAD, and upstream HEAD in the evidence package.

- A dirty worktree is a stop condition unless the task explicitly identifies and preserves those changes.
- If local is behind upstream, stop and report it. Run `git pull --ff-only` only when the task packet explicitly authorizes that command.
- If a fast-forward is impossible, stop. Do not silently sync, merge, rebase, or reset.
- If the branch, upstream, or expected base SHA does not match the task packet, stop and request direction.

## Gate 1: Requirement Clarification

Before editing, establish a bounded goal:

- User outcome and concrete acceptance criteria.
- Technical constraints, non-goals, and risk level.
- Allowed files, forbidden files, permitted commands, and required validation.
- Stop conditions and whether any external action is authorized.

Ask targeted questions only when material constraints are missing. Existing repository documentation, an issue, a PR description, or an approved task packet can supply the answer. Repeated unknowns should be recorded in durable project context instead of repeatedly guessed.

## Gate 2: Spec and Verification Plan

For a non-trivial feature, prepare a concise specification before implementation:

| Field | What to establish |
| --- | --- |
| Problem and outcome | Why the change exists and what users receive |
| Boundaries | Allowed scope, forbidden scope, and non-goals |
| Implementation seams | Where the change begins and ends |
| Acceptance criteria | Observable pass/fail conditions |
| Verification plan | Minimum commands, fixtures, and expected evidence |
| Risks | Regressions, privacy, security, release, or migration concerns |

Do not require a separate PRD for a trivial, clearly bounded documentation or copy edit. Do require a clear verification plan before making a change.

## Gate 3: Vertical Slicing

Split broad work into independently reviewable, testable vertical slices. Each slice must have its own file scope, acceptance criteria, validation, and handoff evidence. Avoid an undifferentiated "big bang" change. Do not refactor adjacent code merely because it is visible; stop and request a separate task if cleanup becomes necessary.

## Gate 4: Implementation and TDD

Use TDD when the change has clear executable behavior: algorithms, business logic, parsers, data transforms, and critical regressions. The loop is: failing test, minimal implementation, refactor with tests green, then required verification.

Do not force TDD for pure copy, documentation, configuration-only work, or exploratory investigation. In every case, choose the smallest relevant validation before editing and preserve the raw results for handoff.

## Gate 5: Review Against Spec and Engineering Quality

Review two axes separately:

1. **Spec correctness:** stated goal, acceptance criteria, non-goals, and scope boundaries.
2. **Engineering quality:** maintainability, seams, tests, data safety, accessibility, performance, and obvious regressions.

Report blocking issues separately from non-blocking improvements. Evidence, rather than an agent's conclusion, supports the review. Web GPT or a human may review GitHub-visible evidence only; Web GPT is not a local command control plane and must not claim local command execution.

## Gate 6: Architecture Improvement Path

For a messy codebase, first create a read-only architecture-friction report covering ownership, coupling, test pain, duplicate domain logic, boundary leaks, and oversized modules. Propose separately scoped refactors with risk and verification plans. Do not fold a refactor into feature work unless the approved task explicitly makes it necessary.

## Gate 7: Evidence and Handoff

Use [the local-agent handoff template](local-agent-handoff-template.md) for each task. An E3 package includes at least:

- base SHA and upstream SHA;
- `git status --short`, `git diff --stat`, and `git diff --check`;
- every validation command, exit code, raw-output snippet, and log path;
- modified, generated, and untracked files; and
- known risks, assumptions, stop conditions, and the proposed next action.

E4 adds reproducible validation, CI or independent verification, and a clean post-run status (or an explicit explanation of expected untracked files). E0 (agent assertion only) and E1 (command names without exit codes or output) cannot support decisions.

## Tool and Scope Boundaries

- **Security tooling:** run `gitleaks` when it is available, configured, or triggered by task risk. Do not assume it exists in every environment, and do not fail the workflow solely because it is absent unless the task policy requires it.
- **Qwen:** if Qwen is relevant, follow SOP v1.1's central context planner and local resource gate before any launch. Qwen is not self-authorizing and must not be launched automatically.
- **Tutti:** any use is limited to the SOP v1.1 command-only verification pilot. It is not authorized for agent, prompt, review, land, or worktree orchestration.
- **Always forbidden without explicit approval:** push, merge, rebase, reset, clean, signing, billing, secrets, credentials, release actions, and edits outside the declared file scope.

## Minimal Command Checklist

```bash
# Preflight
git fetch origin
git branch --show-current
git status --short
git rev-parse HEAD

# Before handoff or commit
git diff --stat
git diff --check
git status --short

# Conditional: only when available, configured, or required by task risk/policy
gitleaks detect --source . --no-git --redact
```

## Anti-Patterns

- Automatically pulling, merging, rebasing, or resetting to make a version mismatch disappear.
- Expanding scope to adjacent files without explicit authorization.
- Running multiple writers in one worktree or treating prompt compliance as isolation.
- Calling an E0/E1 assertion evidence, or claiming a clean state without `git status`.
- Treating Web GPT, a local model, or a review summary as a substitute for local telemetry and tests.
