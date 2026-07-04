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
- Generates lightweight filesystem-style Agent Workspace snapshots so agents can discover context before loading large files.

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

## Agent Workspace

Agent Workspace is a lightweight filesystem-style interface for local coding agents. The goal is to reduce prompt bloat and context drift by giving agents a small, named, searchable workspace before they open large project files or logs.

Generate a current repo snapshot:

```bash
bash scripts/agent_workspace_snapshot.sh
```

This writes:

```text
.agent/current_state.md
.agent/catalog.json
.agent/handoffs/NEXT_AGENT_PROMPT.md
.agent/telemetry/snapshot_<timestamp>.json
```

Initialize a per-task run directory:

```bash
bash scripts/agent_run_init.sh "fix-testflight-gate"
```

This writes a standard artifact directory:

```text
.agent/runs/YYYYMMDD_HHMMSS_fix-testflight-gate/
  task.md
  preflight.md
  git_state_before.txt
  commands.log
  validation.md
  open_loops.md
  final_output.md
  telemetry.json
```

Recommended agent pattern:

```text
ls -> grep -> read scoped files -> cite evidence -> run validation -> write run artifact
```

Generated runtime outputs under `.agent/` are gitignored by default because they may contain local paths or bounded runtime evidence. Promote only curated `final_output.md`, `validation.md`, or `open_loops.md` content into durable docs, `AGENTS.md`, `PROJECT_COMMAND_CENTER.md`, checklists, or skills when useful.

## Repository layout

- `templates/global/`: global agent rules for Codex, Claude Code, Gemini CLI, and Agy.
- `templates/project/`: reusable project templates for Flutter iOS, Swift iOS, AI Agent projects, and Agent Workspace conventions.
- `scripts/`: project creation, template installation, repo health checks, context collection, Agent Workspace snapshots, run artifact initialization, and handoff prompt generation.
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
