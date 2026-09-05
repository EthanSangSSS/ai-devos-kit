# Browser session operations

Load only for browser automation. Runtime tool documentation defines supported APIs.


- 重新获取 `iab`、`browser`、`chrome` 或 `edge` 后，先同步对应的 `globalThis` 与裸变量；首次调用或出现旧 browser ID 错误时，验证对象身份和 `browserId`。发现分叉只重新绑定一次；在完成检查前，不重置环境、不切换浏览器族、不改 bundled Browser 插件，也不报告浏览器不可用。
- 单次 `mcp__node_repl__js` 只做一个有界动作或一次只读探测；不得用循环、`setTimeout`、`waitForTimeout` 或多轮 DOM 读取等待 ChatGPT/DevSpace 长回复。
- 点击、输入、发送、新建对话或导航必须与后续读取拆开。超时且页面状态未知时，先恢复句柄并用最小稳定信号做幂等性检查；不得重放状态变更。
- 长回复或会话切换优先读取 `tab.url()`、`tab.title()` 或定向 locator/布尔状态；不得用 `document.body.innerText`、完整 `domSnapshot()` 或 `get_visible_dom()` 轮询。完整 DOM 仅在页面稳定后单独读取一次。
- 可能超过默认 30 秒的单次调用使用外层 `timeout_ms: 60000`，但调用内不得主动耗尽该预算。若 60 秒触发 kernel reset，只恢复 runtime、同步句柄并读取最小稳定信号；不得重复上一状态变更或同一重型读取。
- `chatgpt.com/plugins` 的 `domSnapshot()` 或 `get_visible_dom()` 每次只尝试一种接口并使用 60 秒外层超时；60 秒仍失败即停止页面自动化，保持未验证并改用脱敏后端证据或用户手动操作，不盲目重试、猜坐标或切换浏览器。
