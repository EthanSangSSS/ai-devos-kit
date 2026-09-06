# Agent workflow contract

The stable core is `templates/global/AGENTS.global.md`. Sol is the everyday priority; Astra uses the same rules. Model-specific adjustments require measured regression evidence.

| Owner | Responsibility |
|---|---|
| User | Intent, scope, consequential authority |
| Current Web or local Codex session | Interactive task ownership, direct tools, final audit |
| Web catalog | `EthanSangSSS/web-chatgpt-skills/main/CATALOG.yaml`; sole domain registry |
| DevSpace | Workspace/command/session/artifact transport; no durable task authority |
| Agy delegate | Only a capability-gap slice, exact observed model and no remote-write authority |
| Codex CLI delegate | Explicitly classified permitted fallback; exact profile gate, never silent |
| Native Luna | Direct Codex quota-saving execution worker; PRIMARY keeps judgment and acceptance |
| Company OS | Optional durable unattended tasks, lease/fencing, recovery and independent verification |
| This kit | Reusable standards, templates and minimal execution/handoff contracts |

For Web routing, apply exclusions first, select zero or one primary domain workflow, optionally one phase-scoped process skill and an explicitly requested adversarial overlay. Use one thin catalog bootstrap; do not create another routing registry. Complexity, multiple files, tests and build time alone do not justify delegation.

The requested Agy profile is absolute binary `/Users/ethan/.local/bin/agy`, model `gemini-3.8-flash-high`, effort high and sandbox enabled. Record version as observed telemetry. Verify stream init.model exactly; classify unavailable/auth/model mismatch/executor failure/capability mismatch visibly. Agy failure or an explicit Codex request permits considering fallback, never an unannounced switch. The validated Codex fallback profile slug is `gpt56lunamax`, resolving to model `gpt-5.6-luna` with max reasoning; `gpt5.6lunamax` is a human label and not a CLI model slug. This profile remains opt-in and must not silently substitute a model or route Web through Direct Codex/Luna. This does not change direct Codex use or its selected model.

Use `docs/HANDOFF_CONTRACT.md` only for delegation or session transfer. Use `docs/GITHUB_EXECUTION_POLICY.md` for CI/GitHub work and `docs/BROWSER_SESSION_POLICY.md` for browser session work. Do not copy those procedures into every AGENTS file.

Skill tiers are CORE_ACTIVE, LOCAL_ON_DEMAND, WEB_PRIMARY, ARCHIVED and BROKEN. Only CORE_ACTIVE is routinely advertised. On-demand sources remain on disk and can be loaded explicitly by exact path; Web-primary sources stay with the canonical Web catalog. The local manifest is a discovery inventory, not a second Web routing registry. Validate fresh discovery after every plugin update; versioned plugin paths can invalidate old disable entries.

Instruction conflicts must disclose the exact source, short rule and effect. A source-backed BLOCKED result is preferable to a fabricated PASS. Configuration changes affect new processes; they do not rewrite an already running session.

Direct Codex retains Native Luna as an optional cost-aware execution layer. Repetitive edits and command/test/build volume are candidates; small reasoning-heavy work stays with PRIMARY. Routine success needs no visible routing header. Failures, model mismatches and fallback remain explicit. Use a fresh bounded worker context and verify actual model identity when full-history inheritance overrides the role profile. Web and Company OS fallback profiles disable descendants.

The reusable fallback profile is `templates/global/gpt56lunamax.config.toml`; copy it to the intended Codex home only with local configuration authority. CLI profile names are plain names (letters, numbers, hyphens, underscores), so the human label containing a dot is not passed to `--profile`. This was verified on CLI 0.144.0; no upgrade is required.
