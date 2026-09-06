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

Direct Codex retains Native Luna as an optional cost-aware execution layer. Before substantial execution, PRIMARY selects one owner by weighing whether expected premium-model quota savings exceed coordination cost without reducing quality; when bounded execution clearly saves premium work, delegate that slice to one fresh, verified Luna. Small, reasoning-heavy and tightly coupled work stays with PRIMARY. Once Luna owns a phase, Luna exclusively owns its implementation, tests, builds, debugging, retries and validation; PRIMARY may review read-only evidence, monitor an active request, communicate with the user, make independent judgment or wait, but does not duplicate overlapping work merely to stay busy or because of latency. Transfer ownership only after terminal state or confirmed interruption; timeout alone never authorizes takeover, and separate parallel execution needs explicit current-task authorization plus disjoint ownership. Record the routing rationale and actual model in native evidence; routine success needs no visible header. Failures, model mismatches and fallback remain explicit. On native spawn surfaces that document it, bind the role explicitly with `agent_type="luna_worker"`; `task_name` is only a label, and `task_name="luna_worker"` cannot select the role or model. Use `fork_turns="none"` for a fresh bounded worker context when that field exists. If no explicit role field is documented, report capability failure and verify actual model identity before accepting offload evidence; never silently substitute a model. Web and Company OS fallback profiles keep their separate contracts.

The reusable fallback profile is `templates/global/gpt56lunamax.config.toml`; copy it to the intended Codex home only with local configuration authority. CLI profile names are plain names (letters, numbers, hyphens, underscores), so the human label containing a dot is not passed to `--profile`. This was verified on CLI 0.144.0; no upgrade is required.
