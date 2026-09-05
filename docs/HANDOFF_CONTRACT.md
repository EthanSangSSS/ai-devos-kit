# Minimal sufficient execution contract

Use acceptance criteria and immutable evidence references. Avoid duplicating global governance or narrative reasoning.

```text
/goal
Goal
Reality / identity: repo, workspace, branch, base/HEAD/PR OID; UNKNOWN where unverified
Authority: allowed local/remote effects; explicit remote merge boundary
Scope: exact paths and bounded responsibility
Out of scope
Known evidence: artifact/commit references and dates; claims labeled CLAIM
Required end state
Validation: narrow required checks and acceptance criteria
Stop conditions: identity/scope/authority/model drift or unknown external outcome
Final evidence: changed paths, commands/exit codes, exact SHAs, risks, NEXT_ACTION
```

Producer: record objective, current reality, repo/branch/HEAD/PR, completed work, decisions, evidence references, unresolved risks, unfinished work and the next acceptance target. Do not present earlier reasoning or test results as fresh facts.

Consumer: `REVALIDATE_FIRST=true`. Treat the packet as CLAIM / CONTEXT. Re-read filesystem, Git, GitHub/PR state, runtime and relevant tests before relying on them. Mark unavailable checks NOT_RUN or UNKNOWN. Do not automatically pull, restart or replay an uncertain remote write.
