# GitHub Connector Review SOP

1. Push to GitHub repo only after local secret scan.
2. Open PR with evidence and risk level.
3. Paste `prompts/chatgpt/github_connector_pr_review.md` into ChatGPT GitHub Connector.
4. Convert findings into P0/P1/P2/P3 bug cards.
5. Codex fixes smallest safe diff, reruns tests, updates PR body and NEXT_CODEX_PROMPT.
