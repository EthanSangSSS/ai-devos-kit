# Contributing

Thank you for improving `ai-devos-kit`.

This repository is a public local-first AI-agent workflow kit. Contributions should improve reproducibility, safety, reviewability, or portability of AI-assisted development workflows.

## Contribution priorities

High-value contributions include:

1. safer local-agent handoff templates;
2. clearer repository-state verification gates;
3. validation scripts that do not require secrets or private services;
4. documentation for review, release, App Store, TestFlight, local model, or GitHub workflows;
5. examples using synthetic or public-safe data only.

## Required boundaries

Do not include:

- secrets, tokens, credentials, private keys, certificates, provisioning profiles, or browser/session data;
- private source code, customer data, employer material, identity documents, or production logs;
- unredacted local-user paths in durable public examples;
- destructive automation without explicit opt-in and stop conditions;
- claims that tests, builds, scans, or local commands ran unless command output or tool evidence is included.

## Pull request process

1. Keep the change narrow.
2. Explain the workflow problem being solved.
3. List the scripts, templates, docs, or examples changed.
4. Run available validation scripts when local shell is available.
5. State exactly what was validated and what was not validated.
6. Do not mark a result as `PASS` unless direct evidence supports it.

## Local validation

Run the relevant subset from the repository root:

```bash
bash scripts/repo_health_check.sh || true
bash scripts/secret_redacted_scan.sh || true
python3 scripts/check_public_safety.py
```

`repo_health_check.sh` and `secret_redacted_scan.sh` may depend on the local environment. If they are unavailable or environment-specific, report that limitation instead of claiming success.

## Issue triage

Issues should include:

- affected script, template, prompt, or document path;
- observed behavior;
- expected behavior;
- reproduction steps or public-safe example;
- whether local execution is required.

Maintainers may close or redirect requests that require private credentials, private data exposure, unauthorized scanning, unsafe automation, or unverifiable claims.
