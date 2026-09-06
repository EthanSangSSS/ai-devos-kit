# Project Agent Rules

## Core

- Verify First：先确认 `pwd`、repo root、当前分支、HEAD、diff stat、依赖和测试命令。
- Trust Telemetry：命令输出优先于推理，失败日志必须进入修复循环。
- Assume Isolation：本项目、其他项目、CI、simulator、本地 agent 配置互相隔离。
- Secret redaction：任何 token / API key / private key 只允许输出脱敏版本。
- No destructive changes：不删除资产、不 reset、不 clean、不改 signing/payment/auth，除非用户明确要求。
- Test-before-claim：没运行就不能说通过。

## Recommended Commands


- `bash scripts/preflight.sh`
- `bash scripts/doctor.sh`
- `bash scripts/agent_config_lint.sh`
- `bash scripts/secret_redacted_scan.sh`
- 项目自带 eval / regression tests



## AI Agent Rules

- Prompt、tool contract、eval dataset、safety policy 必须版本化。
- 不把 token、cookies、private endpoints 写入 prompt 或 test fixture。
- 每次 agent 行为变更都要补 regression test 或 eval case。
- Tool contract 变更要记录输入、输出、错误模式、权限边界和 fallback。


## 每轮交付

交付相关改动、实际验证与风险；NEXT_ACTION=NONE 或一个有界行动。涉及 Git 时附 exact branch/HEAD。

For GitHub/CI work, load `docs/GITHUB_EXECUTION_POLICY.md`; it carries the repository-scoped self-hosted runner constraints.
