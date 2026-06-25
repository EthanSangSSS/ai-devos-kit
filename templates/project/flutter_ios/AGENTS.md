# Project Agent Rules

## Core

- Verify First：先确认 `pwd`、repo root、当前分支、HEAD、diff stat、依赖和测试命令。
- Trust Telemetry：命令输出优先于推理，失败日志必须进入修复循环。
- Assume Isolation：本项目、其他项目、CI、simulator、本地 agent 配置互相隔离。
- Secret redaction：任何 token / API key / private key 只允许输出脱敏版本。
- No destructive changes：不删除资产、不 reset、不 clean、不改 signing/payment/auth，除非用户明确要求。
- Test-before-claim：没运行就不能说通过。

## Recommended Commands


- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- `cd ios && pod install`
- `flutter build ios --simulator --debug`
- `xcrun simctl list devices available`



## Flutter / iOS Rules

- 不要乱改 bundle id、team id、IAP product id 或 StoreKit 文件。
- 不要删除数据源、本地存储迁移、assets、Info.plist permission strings。
- 不支持横屏时，检查 Info.plist / Xcode target orientation / Flutter UI safe area。
- IAP 必须验证 StoreKit local、Sandbox、purchase、restore、cancel、pending、fail、entitlement persistence。
- App Store 前检查 PrivacyInfo.xcprivacy、privacy policy URL、age rating、review notes、screenshots。
- Computer Use QA 只在用户明确要求时执行；否则交付 simulator build 和 QA checklist。
- Accessibility 检查 Dynamic Type、VoiceOver labels、contrast、tap target。


## 每轮交付

必须输出：当前分支、HEAD、diff stat、运行命令、通过/失败、剩余风险、NEXT_CODEX_PROMPT。
