# Recommended Shell Safety Notes

- 不把 token 写入 shell history；优先使用系统 credential store 或临时环境变量。
- 不在全局 shell profile 中硬编码 project path；使用项目脚本自己定位根目录。
- 对 destructive 命令先输出目标路径和 `git status --short`，再由用户确认。
- 不把 signing、App Store Connect、SSH private key、Keychain 操作脚本化到通用模板。
