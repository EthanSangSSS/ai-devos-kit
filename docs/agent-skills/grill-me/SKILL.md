---
name: grill-me
description: Stress-test a plan or design through one evidence-based question at a time. Use for “/grill-me”, “grill me”, “stress test this plan”, “interview me about this design”, or “challenge this idea”; produce critical-review findings, not implementation or approval.
---

# Grill Me

Run a disciplined critical-review and red-team thinking session. Pressure-test decision branches one at a time, identify missing evidence and weak assumptions, and help the user decide the next review route. This skill is not an execution authority.

## Core Rules

1. Ask exactly one primary question at a time, then wait for the user's answer.
2. State why the question matters, a recommended answer, the decision branch resolved, and what remains unresolved.
3. Inspect repository evidence before asking a question whose answer may be documented locally.
4. Produce risks, counterarguments, acceptance-criteria gaps, test gaps, missing evidence, handoff questions, and a recommended next review route.
5. Do not implement, edit files, create a PRD or issues, run commands, or hand off work unless the user explicitly requests the next phase.
6. Do not give final approval, production authorization, merge authorization, or release authorization. Do not claim local commands ran unless command-backed evidence is supplied.

## Scoped Evidence Gathering

When local context is needed, first inspect only the smallest relevant scope:

```text
rg --files -> rg -> scoped read
```

Use `rg --files` to enumerate candidate files, `rg` to locate relevant terms, then read only the scoped files or line ranges needed for the task. Do not dump whole repositories or broad private content into an agent context.

For Git or command-dependent claims, require command-backed evidence. E0 (an agent assertion only) and E1 (a command name without exit code or output) cannot support a decision. Direct the user to the [local-agent handoff template](../../agent-sop/local-agent-handoff-template.md) when an E3/E4 package is needed.

## Question Template

```text
Question N: <one focused question>

Why this matters: <short rationale>

Recommended answer: <evidence-based recommendation and uncertainty>

Decision branch resolved: <branch name>

Still unresolved: <one to three material branches>

Continue only after the user answers.
```

## Decision Branches

Pressure-test the branches that are material to the plan:

- problem definition, target user, and success criteria;
- non-goals, constraints, ownership, and maintenance cost;
- user flow, failure modes, reversibility, accessibility, and localization;
- privacy, security, data ownership, third-party exposure, and compliance;
- payment, subscription, IAP, release, or operational-risk boundaries;
- testability, evidence requirements, acceptance criteria, and handoff gaps; and
- local-execution risk, file scope, stop conditions, and required human review.

## Product Examples Require Human Confirmation

Use these only as safety examples, not product decisions. Require human confirmation before product copy or implementation decisions.

- **口袋心探:** Do not imply therapy, diagnosis, crisis intervention, or emotional-dependency features.
- **岁月留声:** Do not imply simulated-relative personas, virtual-relative companionship, or unbounded memory-chat behavior.

## Routing and Tool Boundaries

- Codex is not the default executor. For an independently authorized L0-L2 execution task, `agy` is the default local executor; this skill does not launch it.
- Web GPT may review GitHub-visible, approved, or redacted evidence only. It is not a local command control plane and cannot claim local execution.
- Qwen is local-only. It requires SOP v1.1 central context planning and a local resource gate before any invocation; do not launch it automatically.
- Tutti is restricted to the SOP v1.1 command-only verification pilot. Do not use it for agent, review, land, or worktree orchestration.
- Apply the single-writer rule: one write-capable executor per repo, worktree, branch, and task window. Parallel contributors may perform read-only review, risk lists, log summaries, or review-packet generation.
- Never authorize or initiate push, merge, rebase, reset, force-push, release, signing, billing, secret access, protected-repository edits, automatic agent launch, Qwen launch, or Tutti orchestration.

## Stop Conditions

End the session when all material branches are resolved, the user says stop, the user requests implementation or a deliverable, or the next step requires evidence unavailable in the current context. State the unknowns rather than guessing.

## Final Summary Template

```text
=== Grill Session Complete ===

Resolved decisions:
- <branch>: <resolved answer>

Risks or missing evidence:
- <branch>: <risk, assumption, or evidence needed>

Recommended next review route:
- human decision, E3/E4 handoff, GitHub-visible Web GPT review, or separately authorized local execution

Not authorized by this skill:
- implementation, final approval, production authorization, merge, release, or local-command claims without evidence
```

## Anti-Patterns

- Batching questions or continuing before the user answers.
- Treating a plan, agent assertion, E0/E1 evidence, or Web GPT review as command-backed proof.
- Converting a grilling session into implementation, PRD, issues, or a handoff without user direction.
- Treating future / optional skills such as `/to-prd`, `/to-issues`, `/tdd`, or `code-review` as installed, required, or authorized.
- Ignoring stated non-goals, protected scopes, privacy boundaries, or stop conditions.
