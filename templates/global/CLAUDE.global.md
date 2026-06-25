# Global Agent Standard

本文件用于 Codex / Claude Code / Agy / Gemini CLI。它是项目级 `AGENTS.md` 的上游标准，中文为主，保留必要 English technical terms。

## Non-Negotiables

- Verify First：先探测当前目录、分支、HEAD、依赖、构建目标和测试命令，再下结论。
- Trust Telemetry：命令输出优先于推理；输出矛盾时修正计划。
- Assume Isolation：repo、shell、simulator、CI、本地配置互相隔离，不能跨项目假设。
- No destructive changes：不删除资产，不 reset，不 clean，不改全局 shell / SSH / Keychain / signing，除非用户明确要求。
- Git hygiene：改动前确认 `git status --short`；提交前看 `git diff --stat` 和关键 diff；不 push，除非用户明确要求。
- Secret redaction：不要输出完整 token / API key / private key；扫描结果必须脱敏。
- Test-before-claim：未运行验证就不能声称通过；不能运行时说明 blocker 和最近的静态检查。
- Reusable First：优先沉淀模板、脚本、SOP、checklist，而不是一次性说明。

## Priority Levels

- P0：会导致数据丢失、密钥泄露、支付/签名/上架失败、生产不可用。
- P1：核心功能、构建、测试、IAP、App Store review 高概率失败。
- P2：质量、可维护性、可接力、可观测性风险。
- P3：文案、格式、低风险优化。

## 每轮输出状态

每轮交付必须包含：

```text
当前分支:
HEAD:
diff stat:
运行命令:
通过/失败:
剩余风险:
NEXT_CODEX_PROMPT:
```

## 禁止项

- 不要假设路径；用 `pwd`、`git rev-parse --show-toplevel`、`rg --files` 验证。
- 不要删除资产、数据源、StoreKit 文件、迁移脚本或用户文档。
- 不要改 bundle id / team id / IAP product id，除非用户明确要求并提供目标值。
- 不要盲目大重构；先写 scope、风险和验证标准。
- 不要泄露完整密钥；只输出前缀或 `[REDACTED]`。
- 不要 push、创建 release、改 CI secret、改签名配置，除非用户明确要求。

## NEXT_CODEX_PROMPT 要求

每次工作结束都要更新或输出 `NEXT_CODEX_PROMPT`，包含：当前状态、已验证证据、剩余风险、下一轮最小任务、禁止范围、建议验证命令。


## Claude Code Specialization

Claude Code 适合大规模 UI、重构、复杂阅读和长上下文改造。必须给出 diff 约束、测试命令和回滚边界；不得在没有测试与 diff stat 的情况下声明完成。
