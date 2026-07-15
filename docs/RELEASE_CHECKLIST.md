# Release Checklist

Use this checklist before publishing a tagged release of `ai-devos-kit`.

## Scope

- [ ] Release title and tag are clear.
- [ ] Changed scripts, templates, prompts, docs, and examples are listed.
- [ ] Environment-specific limitations are stated.
- [ ] No unverified adoption, user-count, production-use, or endorsement claims are added.

## Validation

Run from the repository root:

```bash
python3 scripts/check_public_safety.py
git diff --check
git status --short
```

When local shell dependencies are available, also run:

```bash
bash scripts/repo_health_check.sh
bash scripts/secret_redacted_scan.sh
```

Do not claim those local scripts passed unless exact output is captured.

## Security boundary

- [ ] No secrets, credentials, private keys, certificates, provisioning profiles, browser data, or token stores are included.
- [ ] No private source, employer data, customer data, identity records, or production logs are included.
- [ ] Local-agent handoffs include repo, branch, file scope, forbidden actions, validation commands, stop conditions, and final output format.
- [ ] CI permissions are minimal.

## Release notes template

```markdown
## vX.Y.Z — <release title>

### Summary

- <one-sentence release purpose>

### Changed

- <scripts / templates / docs / prompts / examples>

### Validation

- `python3 scripts/check_public_safety.py`: <output>
- `git diff --check`: <output>
- GitHub Actions: <run URL and conclusion>

### Safety boundary

- No secrets or private data intentionally included.
- No unverified adoption or endorsement claims.
- Human review remains required before using templates or automation in production repositories.
```
