# AI DevOS Kit

AI DevOS Kit is a local-first development workflow kit for solo developers and small teams using AI coding agents.

It provides reusable templates, scripts, prompts, and SOPs for Flutter iOS, Swift iOS, and AI Agent projects.

Core principles: Verify First, Trust Telemetry, Assume Isolation, No destructive changes, No secret exposure, Reusable First, Automation First, Agent Friendly.

## What this kit does

- Bootstraps Flutter iOS, Swift iOS, and AI Agent project scaffolds.
- Installs project-local `AGENTS.md`, docs, scripts, GitHub issue templates, and workflows.
- Provides repeatable local checks before handing work to Codex, Claude Code, Gemini CLI, Agy, or Web ChatGPT.
- Packages SOPs for GitHub PR review, App Store readiness, TestFlight, IAP, Computer Use QA, and security.
- Generates handoff prompts and project context summaries for cross-agent collaboration.

## Quick start

Set a local kit root:

```bash
export AI_DEVOS_KIT_ROOT="/path/to/ai-devos-kit"
cd "$AI_DEVOS_KIT_ROOT"
```

Create a Flutter iOS app:

```bash
bash scripts/create_flutter_ios_project.sh "sample_app" "Sample App" "com.example.sampleapp"
```

Install standard project files into an existing app:

```bash
cd /path/to/your/app
bash "$AI_DEVOS_KIT_ROOT/scripts/install_project_kit.sh"
```

Before handing a project to an AI coding agent, run:

```bash
bash scripts/repo_health_check.sh
bash scripts/secret_redacted_scan.sh
bash scripts/next_prompt_builder.sh
```

## Repository layout

- `templates/global/`: global agent rules for Codex, Claude Code, Gemini CLI, and Agy.
- `templates/project/`: reusable project templates for Flutter iOS, Swift iOS, and AI Agent projects.
- `scripts/`: project creation, template installation, repo health checks, context collection, and handoff prompt generation.
- `prompts/`: reusable prompts for Codex, Claude Code, Gemini/Agy, and Web ChatGPT review.
- `docs/`: development workflow, GitHub review, App Store, TestFlight, IAP, Computer Use QA, local model, and security SOPs.
- `examples/`: example bug cards, project plans, handoff prompts, and PR review requests.

## Publish your own fork

```bash
gh repo create ai-devos-kit --public --source=$AI_DEVOS_KIT_ROOT --remote=origin
cd $AI_DEVOS_KIT_ROOT
git push -u origin main
```

Run a secret scan before publishing any fork:

```bash
gitleaks detect --source . --no-git --redact
```

## License

MIT
