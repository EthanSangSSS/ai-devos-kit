/goal

Goal: Resolve the specified PR findings.
Reality / identity: fresh-read the selected workspace/repo, branch, HEAD and relevant remote state; mark UNKNOWN explicitly.
Authority: Bounded local edits; commit/push/Draft PR changes only as explicitly authorized. REMOTE_MERGE=NO.
Scope: user-selected paths and task acceptance criteria.
Out of scope: unrelated work and effects outside the stated authority.
Known evidence: exact supplied artifact/commit references; prior handoffs are CLAIM / CONTEXT.
Required end state: Address verified findings on the exact reviewed head without unrelated changes.
Validation: Fresh GitHub PR/head/base/files/checks; focused regression and diff check.
Stop conditions: identity, authority, scope drift or an unknown external-write result.
Final evidence: changed paths or read-only findings, commands/exit codes, exact identity, remaining risks, NEXT_ACTION=NONE or one bounded action.
