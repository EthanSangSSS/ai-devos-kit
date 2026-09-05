# Workflow regression evidence

`tests/fixtures/workflow-vnext.json` preserves the twelve representative
acceptance scenarios. It records expectations, not observations or routing rules.
The canonical domain registry remains the Web repository's CATALOG.yaml.

Record a reviewed observation per scenario, for example:

```json
{"R1":{"evidence_kind":"LIVE","evidence_ref":"immutable trace reference","facts":{"execution":"native","skills_loaded":0,"delegates":0,"approval_ceremony":false}}}
```

Run `python3 scripts/validate_workflow_trace.py observations.json`.
Missing evidence is NOT_RUN; CONTRACT observations cannot produce PASS_RUNTIME.
The evaluator compares supplied facts; a reviewer must verify each evidence_ref
and its provenance. It does not authenticate traces or execute agents.
Exit zero requires all twelve runtime scenarios to pass. Unit-test success does
not imply live Web, Agy, Company OS, or native-policy migration acceptance.

For R2, primary_count_max describes the observed routing bound. Test explicit
exclusions and ambiguous domains. R5 must cover unavailable, auth, model mismatch
and executor/capability failures, not only successful init. R8 requires independent
access-control evidence; an executor statement that it did not push is insufficient.
R12 compares equivalent task prompts and retains plan-mode control, an appropriate
profile, exact model and zero tool calls. A lower token count alone cannot pass.
