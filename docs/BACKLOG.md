# Backlog

This backlog captures follow-up work for `ai-devos-kit` after the public workflow baseline.

## Current release state

- `v0.1.0 — Public AI DevOS baseline` was published on 2026-07-15.
- The repository is now in maintenance / focused-hardening mode rather than pre-release bootstrap.
- Do not recreate control planes that are now maintained more authoritatively in active downstream governance systems; prefer narrow reusable checks, templates, examples, and compatibility documentation.

## P0

- Add fixture-based checks for unsupported local-execution claims.
- Add a prompt-security review checklist for agent handoff templates.
- Add a local Codex sync / review prompt that verifies repository state before edits.

## P1

- Add example handoffs for Web ChatGPT, Codex, Claude Code, Gemini CLI, and Agy.
- Add compatibility notes for macOS shell assumptions and GitHub Actions.
- Validate the published kit against at least one current downstream installation and document concrete compatibility gaps instead of adding speculative framework layers.

## P2

- Add a lightweight changelog convention.
- Add downstream project installation examples.
- Add script-level smoke tests where feasible without requiring private local state.

## Release discipline

Future release/version work should be driven by verified changes to the reusable kit itself. Do not create a new version only to mirror changes in AI-Agent-Database, DevSpace, codex-router, or individual application repositories.