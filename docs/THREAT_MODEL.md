# Threat Model

`ai-devos-kit` is a local-first AI-agent workflow kit. Its main security surface is workflow instruction: scripts, templates, prompts, handoff contracts, and generated run artifacts that influence how AI coding agents operate.

## Assets

- Repository-state verification scripts and prompts.
- Local-agent handoff templates.
- Project scaffolding scripts.
- Public examples and portfolio documentation.
- Maintainer trust that validation evidence is real and reproducible.

## Trust boundaries

| Boundary | Trusted input | Untrusted input |
|---|---|---|
| Maintainer review | GitHub diffs, captured command output, CI logs | Agent summaries without evidence |
| Local agent execution | Explicit repo path, branch, file scope, stop conditions | Broad filesystem, credential stores, hidden shell state |
| Public artifacts | Synthetic examples, curated validation output | Private logs, local paths, employer/customer data |
| Scripts/templates | Bounded opt-in commands | Destructive operations or credential discovery |

## Key threats

| Threat | Example | Mitigation |
|---|---|---|
| Secret exposure | A prompt tells an agent to inspect token stores, SSH keys, browser profiles, certificates, or provisioning profiles | Security policy, contribution guide, public-safety scan |
| False validation claim | An agent says tests or builds passed without command output | PR template evidence boundary and version-sync gate |
| Unbounded handoff | A handoff allows unrestricted edits, force-push, or deletion | Required file scope, forbidden actions, stop conditions |
| Local-path leakage | Durable docs include real local-user paths | Public-safety scan warning and synthetic examples |
| Destructive automation | Template overwrites project files without review | Narrow scripts, review checklist, explicit opt-in |
| Unsafe downstream use | Users apply templates to private projects without validation | Known limitations and human-review requirements |

## Review checklist

Before merging workflow changes, verify:

1. The task scope is bounded.
2. The change does not require credentials or private data.
3. Any command execution claim includes exact output.
4. Generated artifacts stay out of durable public docs unless curated.
5. Scripts fail safely and do not force-push, delete, publish, or exfiltrate without explicit authorization.
6. Examples are synthetic or public-safe.
