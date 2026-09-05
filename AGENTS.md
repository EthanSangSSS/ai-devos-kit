# AI DevOS Kit

Canonical source for reusable local workflow standards, project templates and prompt contracts. Interactive sessions use their current host directly; Company OS is optional for durable unattended work.

Keep kit changes scoped. Preserve domain acceptance criteria in project templates; keep global instructions model-agnostic. Runtime observations, configuration requirements and executor claims must remain distinct.

Validation: `python3 -m unittest discover -s tests -p 'test_*.py'`; run `bash -n` and `--help` for changed shell/template scripts; run `python3 scripts/check_public_safety.py`; `git diff --check`. Run `bash tests/validate_agent_workspace.sh` when workspace/handoff behavior changes. No automatic build, delegation or remote write follows from this file.

Report actual validation and risks. NEXT_ACTION=NONE when complete; generate a handoff only for unfinished work needing another session.
