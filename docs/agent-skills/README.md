# Agent Skills

Callable, bounded workflows for local AI agents. Each skill is guidance, not execution authority: it must respect the current task packet, file scope, and the [SOP v1.1](../ethan-local-multi-agent-codex-throttling-sop-v1.1.md).

## Available Skills

| Skill | Description |
| --- | --- |
| [`grill-me`](grill-me/SKILL.md) | Red-team a plan or design one decision branch at a time; surface risks, missing evidence, and unanswered handoff questions. |

## `/grill-me` at a Glance

Invoke with `/grill-me`, “grill me”, “stress test this plan”, or “challenge this idea”. It asks one focused question at a time, recommends an evidence-based answer, and records the decision branch resolved. It does not implement, authorize, or approve work.

Before asking a repository-specific question, use this scoped reading pattern:

```text
rg --files -> rg -> scoped read
```

Use `rg --files` to enumerate candidate files, `rg` to locate relevant terms, then read only the scoped files or line ranges needed for the task. Do not dump whole repositories or broad private content into an agent context.

## Skill Relationships

```text
/grill-me                         -> critical review and requirements pressure test
    |
    +-> engineering workflow guide -> bounded spec, slices, and verification plan
    |
    +-> future / optional skills: /to-prd, /to-issues, /tdd, code-review
    |
    +-> local-agent handoff        -> E3/E4 evidence package
    |
    +-> GitHub-visible evidence review by Web GPT or a human
```

Only `/grill-me` is provided by this directory today. The named future / optional skills are neither installed nor required, and must not be treated as authorization to launch an agent or change a repository.

## Safety and Evidence Boundaries

- One write-capable executor is permitted per repo, worktree, branch, and task window. Parallel work is read-only review, risk listing, log summarization, or review-packet generation only.
- Codex is not the default executor; `agy` is the default L0-L2 local executor when a separately authorized task needs execution. `/grill-me` never launches it.
- Web GPT or a human may review GitHub-visible, approved, or redacted evidence only. Web GPT is not a local command control plane and must not claim to have run local commands.
- Command-backed evidence is required where commands matter. E0 and E1 evidence cannot support decisions; use the agent-sop handoff guide for E3/E4 evidence packages.
- Qwen is local-only and requires SOP v1.1 central context planning plus a local resource gate before use; this skill must not launch Qwen automatically.
- Tutti is limited to the SOP v1.1 command-only verification pilot. It is not authorized for agent or worktree orchestration.

## Adding a Skill

1. Create `docs/agent-skills/<skill-name>/SKILL.md` with `name` and `description` YAML frontmatter.
2. Keep the body focused on the reusable workflow and its boundaries.
3. Add it to the table above and add the necessary main README index link.
4. Validate the allowed diff and task-specific checks before proposing a review.

Do not use a skill to authorize push, merge, rebase, reset, force-push, release, signing, billing, secret access, protected-repository edits, or automatic tool launches.

## Attribution

`grill-me` is inspired by Matt Pocock's [Skills for Real Engineers](https://github.com/mattpocock/skills) grilling pattern, adapted for Ethan's local-first evidence and safety boundaries.
