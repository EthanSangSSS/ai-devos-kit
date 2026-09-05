/goal

Goal: Resolve verified release-readiness defects in the approved scope.
Reality / identity: fresh-read the selected workspace/repo, branch, HEAD and relevant remote state; mark UNKNOWN explicitly.
Authority: Bounded local fixes; signing, upload, release and merge need explicit authority.
Scope: user-selected paths and task acceptance criteria.
Out of scope: unrelated work and effects outside the stated authority.
Known evidence: exact supplied artifact/commit references; prior handoffs are CLAIM / CONTEXT.
Required end state: Required checks pass on the exact candidate; unresolved risks remain visible.
Validation: Risk-proportional regression and exact artifact identity; no automatic release.
Stop conditions: identity, authority, scope drift or an unknown external-write result.
Final evidence: changed paths or read-only findings, commands/exit codes, exact identity, remaining risks, NEXT_ACTION=NONE or one bounded action.
