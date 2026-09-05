/goal

Goal: Assess the specified iOS candidate for submission readiness.
Reality / identity: fresh-read the selected workspace/repo, branch, HEAD and relevant remote state; mark UNKNOWN explicitly.
Authority: Read-only by default; no signing/credential/upload/store changes.
Scope: user-selected paths and task acceptance criteria.
Out of scope: unrelated work and effects outside the stated authority.
Known evidence: exact supplied artifact/commit references; prior handoffs are CLAIM / CONTEXT.
Required end state: Evidence-backed readiness assessment and concrete blockers.
Validation: Inspect metadata, privacy, entitlement and artifact checks relevant to the candidate.
Stop conditions: identity, authority, scope drift or an unknown external-write result.
Final evidence: changed paths or read-only findings, commands/exit codes, exact identity, remaining risks, NEXT_ACTION=NONE or one bounded action.
