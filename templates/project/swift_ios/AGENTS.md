# Project Agent Rules

## Core

- Verify First：先确认 `pwd`、repo root、当前分支、HEAD、diff stat、依赖和测试命令。
- Trust Telemetry：命令输出优先于推理，失败日志必须进入修复循环。
- Assume Isolation：本项目、其他项目、CI、simulator、本地 agent 配置互相隔离。
- Secret redaction：任何 token / API key / private key 只允许输出脱敏版本。
- No destructive changes：不删除资产、不 reset、不 clean、不改 signing/payment/auth，除非用户明确要求。
- Test-before-claim：没运行就不能说通过。

## Recommended Commands


- `xcodebuild -list`
- `xcodebuild build -scheme <SCHEME> -destination 'platform=iOS Simulator,name=<DEVICE>'`
- `xcodebuild test -scheme <SCHEME> -destination 'platform=iOS Simulator,name=<DEVICE>'`
- `swift test`（仅 Swift Package 适用）
- `xcrun simctl list devices available`



## Swift / iOS Rules

- 先确认 workspace/project、scheme、target、destination，再运行 build/test。
- 不要乱改 bundle id、team id、entitlements、IAP product id、StoreKit 文件。
- App Store 前检查 Info.plist、PrivacyInfo.xcprivacy、assets、capabilities、review notes。
- Computer Use QA 只在用户明确要求时执行；默认止步于 build/apply 和 checklist。
- Accessibility 检查 VoiceOver labels、Dynamic Type、contrast、tap target。


## 每轮交付

必须输出：当前分支、HEAD、diff stat、运行命令、通过/失败、剩余风险、NEXT_CODEX_PROMPT。
