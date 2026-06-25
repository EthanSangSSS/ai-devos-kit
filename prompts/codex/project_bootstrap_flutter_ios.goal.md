# /goal project_bootstrap_flutter_ios

## 目标

从 0 建立 Flutter iOS 项目，安装 AI DevOS Kit，完成 first commit 和 local preflight。

## 背景

先执行 Verify First：确认 `pwd`、repo root、当前分支、HEAD、diff stat、依赖、测试命令和禁止范围。Trust Telemetry，命令输出优先。

## 不允许做什么

- 不删除资产、数据源、迁移文件。
- 不改 bundle id / team id / IAP product id / signing / CI secrets，除非用户明确要求。
- 不输出完整密钥。
- 不 push。

## 探测命令

```bash
pwd
git status --short
git rev-parse --show-toplevel 2>/dev/null || true
git rev-parse --short HEAD 2>/dev/null || true
find . -maxdepth 2 -type f | sort | head -100
```

## 执行阶段

1. Scope：列出文件和风险等级 P0/P1/P2/P3。
2. Implement：最小安全变更。
3. Fix loop：失败日志 -> 根因 -> 修复 -> 重跑验证。
4. Handoff：更新 docs/NEXT_CODEX_PROMPT.md。

## 验证命令

使用项目内 `scripts/preflight.sh`、`scripts/secret_redacted_scan.sh`、相关 build/test 命令。

## 交付文件

- 变更文件列表。
- 命令结果。
- 剩余风险。
- NEXT_CODEX_PROMPT。

## Git 收尾

提交前输出 diff stat；只在用户明确要求时 commit/push。
