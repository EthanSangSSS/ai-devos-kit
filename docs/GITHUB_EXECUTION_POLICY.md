# GitHub and CI operations

Fresh-read repository, branch, base/head OIDs, worktree status, expected paths and PR state before consequential writes. Task authorization is required for publication; never merge without explicit authority. Reconcile ambiguous writes before retry.


For Ethan-owned private repositories, GitHub Actions CI must default to a
repository-scoped self-hosted runner and must not silently fall back to billed
GitHub-hosted runners. For agent-lab, use the repository-scoped runner labeled
agent-lab-ci. This runner is an owner-approved exception running under Ethan's
current macOS user, so keep it offline except during explicitly authorized CI,
do not run fork or untrusted pull-request code, do not use real secrets, and do
not access files outside the dedicated runner workspace. Before starting the
runner, verify the exact workflow, actor, repository, pull request, and approved
head SHA. New repositories must not automatically reuse agent-lab-ci; create a
separate repository-scoped runner and label.
