# Security Policy

`ai-devos-kit` is a public, local-first AI-agent operations kit. Its main risks are not only traditional code vulnerabilities, but also unsafe workflow instructions, secret exposure, overbroad local-agent handoffs, and unsupported validation claims.

## Supported scope

Security reports are in scope when they involve:

- accidental exposure of secrets, tokens, credentials, private keys, provisioning profiles, certificates, or private logs;
- instructions that encourage broad home-directory scans, browser-profile reads, SSH-key reads, token-store reads, or credential discovery;
- scripts or templates that can delete, overwrite, publish, exfiltrate, or rewrite repository history without explicit authorization;
- false claims that tests, builds, scans, local commands, or background work completed without evidence;
- workflow documents that encourage use on third-party systems without authorization.

## Out of scope

- Requests for private repository access or credentials.
- Reports that require scanning systems or repositories not owned or administered by the maintainer.
- Speculative concerns without an affected path, command, template, or reproduction outline.
- App-specific security findings from private downstream projects that are not present in this public repository.

## Reporting

Open a GitHub issue if the report contains no sensitive data. If sensitive material is involved, do not paste it into an issue. Open a minimal public issue with:

- affected path or script name;
- risk category;
- safe reproduction outline;
- whether any secret or private data was exposed.

The maintainer will request a redacted artifact if needed.

## Maintainer handling SOP

1. Confirm the affected path and reproduce the issue using public-safe inputs.
2. Preserve evidence without copying secrets into durable public docs.
3. Remove or rewrite unsafe instructions, templates, or scripts.
4. Add a regression check where feasible.
5. Document the fix without exposing sensitive details.

## Boundary

Do not use this repository, its scripts, or any program benefits to probe third-party repositories, services, accounts, devices, or local filesystems without explicit authorization.
