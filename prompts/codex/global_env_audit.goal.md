/goal

Goal: Audit explicitly scoped local configuration and instruction surfaces.
Reality / identity: fresh-read the selected workspace/repo, branch, HEAD and relevant remote state; mark UNKNOWN explicitly.
Authority: Read-only; no configuration writes, cleanup, commits or publication.
Scope: user-selected paths and task acceptance criteria.
Out of scope: unrelated work and effects outside the stated authority.
Known evidence: exact supplied artifact/commit references; prior handoffs are CLAIM / CONTEXT.
Required end state: A secret-safe measured inventory with sources and gaps.
Validation: Parse/hash only authorized nonsecret configuration and fresh discovery; no build.
Stop conditions: identity, authority, scope drift or an unknown external-write result.
Final evidence: changed paths or read-only findings, commands/exit codes, exact identity, remaining risks, NEXT_ACTION=NONE or one bounded action.
