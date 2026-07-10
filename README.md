# AI DevOS Kit

[![Portfolio](https://img.shields.io/badge/portfolio-agent%20workflow%20OS-blue)](docs/PORTFOLIO_OVERVIEW.md)
[![Scope](https://img.shields.io/badge/scope-local--first%20automation-success)](docs/PORTFOLIO_OVERVIEW.md)
[![Discipline](https://img.shields.io/badge/principle-Verify%20First-informational)](docs/PORTFOLIO_OVERVIEW.md)
[![Actions](https://img.shields.io/badge/CI-GitHub%20Actions-informational)](https://github.com/EthanSangSSS/ai-devos-kit/actions)

AI DevOS Kit is a **local-first development workflow kit for solo developers and small teams using AI coding agents**.

It provides reusable templates, scripts, prompts, SOPs, and handoff contracts for Flutter iOS, Swift iOS, and AI-agent projects. The goal is to make AI-assisted development repeatable: each agent run should start from verified repo state, operate inside a bounded task scope, produce durable artifacts, and leave behind enough evidence for a human or another agent to review.

Core principles: **Verify First**, **Trust Telemetry**, **Assume Isolation**, **No destructive changes**, **No secret exposure**, **Reusable First**, **Automation First**, **Agent Friendly**.

## Portfolio fast path

Start here if you are reviewing this as a portfolio project:

- [`docs/PORTFOLIO_OVERVIEW.md`](docs/PORTFOLIO_OVERVIEW.md) — one-page reviewer guide, Mermaid architecture map, core surfaces, and demo flow.
- `scripts/agent_workspace_snapshot.sh` — generates a compact repository snapshot for agent consumption.
- `scripts/agent_run_init.sh` — initializes auditable per-task run artifacts.
- `scripts/repo_health_check.sh` — verifies repo state before work starts.
- `scripts/secret_redacted_scan.sh` — reduces risk of private material leaking into prompts or artifacts.

## Why this exists

AI coding agents are useful, but unmanaged agent workflows drift quickly:

- prompts become too large and stale;
- local repo state is assumed instead of verified;
- agents overwrite unrelated files;
- validation evidence is scattered across chat logs;
- handoffs between ChatGPT, Codex, Claude Code, Gemini CLI, Agy, and local tools lose context;
- release-readiness and App Store checks become manual memory.

AI DevOS Kit treats the development environment as an operating system for agents: scripts, command centers, templates, validation gates, and run artifacts become the control plane.

## What this kit does

- Bootstraps Flutter iOS, Swift iOS, and AI-agent project scaffolds.
- Installs project-local `AGENTS.md`, docs, scripts, GitHub issue templates, and workflows.
- Provides repeatable local checks before handing work to Codex, Claude Code, Gemini CLI, Agy, or Web ChatGPT.
- Packages SOPs for GitHub PR review, App Store readiness, TestFlight, IAP, Computer Use QA, local models, and security.
- Generates handoff prompts and project context summaries for cross-agent collaboration.
- Generates lightweight filesystem-style Agent Workspace snapshots so agents can discover context before loading large files or logs.
- Keeps transient runtime evidence out of durable docs unless it has been curated.

## Best-fit use cases

Use this kit when you need to:

- standardize AI-agent behavior across multiple repositories;
- reduce repeated prompt-writing for recurring development tasks;
- make local agent work auditable before commit / push / PR;
- create consistent GitHub PR review artifacts;
- preserve project-specific constraints without bloating every task prompt;
- support app-release workflows with explicit gates and stop conditions.

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

## Version-sync gate

Every local agent task should start by proving the actual repository state:

```bash
git fetch origin
git status --short
git branch --show-current
git rev-parse HEAD
```

For PR-bound work, also compare local HEAD against the PR head SHA before making changes. If the worktree is dirty, the branch is wrong, the repo cannot fast-forward, or HEAD does not match the expected PR head, the agent should stop and report instead of modifying files.

## Repository layout

- `templates/global/`: global agent rules for Codex, Claude Code, Gemini CLI, and Agy.
- `templates/project/`: reusable project templates for Flutter iOS, Swift iOS, AI-agent projects, and Agent Workspace conventions.
- `scripts/`: project creation, template installation, repo health checks, context collection, Agent Workspace snapshots, run artifact initialization, and handoff prompt generation.
- `prompts/`: reusable prompts for Codex, Claude Code, Gemini / Agy, and Web ChatGPT review.
- `docs/`: development workflow, GitHub review, App Store, TestFlight, IAP, Computer Use QA, local model, security SOPs, and [agent-sop/](docs/agent-sop/) engineering workflow and handoff guidance.
- `examples/`: example bug cards, project plans, handoff prompts, and PR review requests.

## Safety model

This kit should not read or expose secrets. Do not feed broad home-directory scans, token files, SSH keys, browser profiles, certificates, provisioning profiles, banking documents, or private identity records into generated artifacts or agent prompts.

Use secret scans before publishing forks or sharing generated prompts:

```bash
gitleaks detect --source . --no-git --redact
```

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
