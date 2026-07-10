# Ethan Local Multi-Agent Delegation and Codex Throttling SOP v1.1 Pilot

版本：1.1 Pilot
Owner：Ethan
范围：本地开发、GitHub PR、App 项目、Skill repo、AI-Agent-Database 与 agent workflow 实验。

本 SOP 的目标是在保留 Codex 高风险判断质量的前提下，减少其日常执行用量。它是工作分配与证据门禁，不是自动化执行器，也不授权 push、release、签名、计费或生产变更。

## 1. Executive Policy

Codex 不再是默认执行器。它是高风险推理、失败测试诊断、架构/安全/隐私/release 判断，以及 **Codex final gate** 的稀缺资源。

默认原则：

```text
Weak agents generate verifiable evidence.
Codex makes high-risk judgments.
Telemetry and tests decide facts.
Ethan authorizes real push, release, signing, billing, and production changes.
```

默认分工：Web GPT 负责规划、审查、外部研究和 prompt；Antigravity execution layer = `agy`，负责 L0-L2 的本地执行；Claude Code 仅在 agy 容量耗尽后备用；Qwen 仅处理高敏感、local-only 内容；Codex 只在定义的升级条件下介入。

## 2. Scope and Non-Goals

适用范围：文档、Skill、测试、局部代码修改、PR evidence、release 前审查和受约束的 Tutti command-only pilot。

不属于本 SOP 的授权：自动 agent launcher、hooks、LaunchAgents、无人值守多 agent 编排、自动 push/merge/release、签名、证书、billing、IAP、真实用户数据处理或秘密管理。任何这些事项必须由独立流程和 Ethan 明确授权处理。

## 3. Agent Roles

### Web GPT

允许：需求拆解、架构审查、prompt 生成、GitHub-visible source review、外部研究、evidence package 审阅和最终人类可读报告。

禁止：声称运行过本地命令；默认接收私有 repo 内容、私有日志或敏感数据；作为本地命令控制平面；替代真实测试结果。

隐私边界：Web GPT 只接收公开、GitHub-visible、Ethan 批准或已脱敏的 evidence package。私有日志或敏感本地内容优先由 Qwen 生成脱敏摘要；若 Qwen 不可用，则停止或由 Ethan 明确批准最小披露范围。

### Agy / Antigravity

```text
Antigravity execution layer = agy
```

`agy` 是 L0-L2 的默认本地执行器。每个任务必须记录：agy version、agent/profile/model（若可得）、sandbox/permission mode、是否使用 dangerous permission bypass、工作目录、branch、HEAD、命令、exit code、log path、改动文件和生成文件。

默认禁止：`--dangerously-skip-permissions`、YOLO/不受限模式、push、merge、rebase、`reset --hard`、签名/计费/secret/release 修改、未经 stop 的 scope 扩大。若无法以 constrained 或 sandbox 模式运行，必须 stop 或升级，不得静默降级为更不安全模式。

### Codex

Codex 仅用于：L3/L4 高风险任务、触发条件满足的 L2 final review、失败测试根因诊断、架构决策、PR go/no-go、安全、隐私、IAP、release 与 CI 判断，以及弱 agent evidence 不完整时的审查。

Codex 默认不承担 README 初稿、文件枚举、机械格式化、普通日志初筛或已经有小范围验证的 docs-only 修改。

### Claude Code

Claude Code 仅在 agy / Antigravity 容量耗尽或不可用后备用。允许 L0/L1 文档、checklist、red-team review、PR 描述草稿，以及显式批准的低风险 backup patch。

禁止：未经明确批准的 L2+ 实现、高风险实现、最终 review、release/signing/billing/IAP/security/privacy 判断、CI/CD 关键修改与广泛重构。

### Qwen Local Model

Qwen 仅用于高数据安全、local-only 场景：敏感日志初筛、私有 repo 摘要、敏感文本分类和脱敏 evidence package 草稿。

在本地命令、模型版本和 offline boundary 被确认前，Qwen 不是已验证运行时。禁止其做最终 review、高风险实现、release/security/privacy 决策或替代 Codex gate。

所有 Qwen 输出必须标记：

```text
LOCAL MODEL PRELIMINARY OUTPUT — REQUIRES VERIFICATION
```

## 4. Risk Levels and Routing

| 等级 | 典型任务 | 默认路由 | Codex 规则 |
| --- | --- | --- | --- |
| L0/L1 | docs、README、SKILL.md、template、checklist、release notes | `agy` → verification → evidence package → Web GPT 可选审查 | 默认 0 轮 |
| L2 | 局部模块修改、小 Flutter fix、测试补充、非关键脚本/schema 调整 | `agy` → verification → evidence → Web GPT 初审 → 触发时 Codex compressed review | 默认最多 1 轮 |
| L3 | IAP、paywall、隐私边界、CI/CD、核心导入导出、多文件架构、原因不明的失败测试 | agy 仅只读收集/明确验证 → Codex leads or reviews → 人工批准 | 必须参与，最多 2 轮后转人工 |
| L4 | secrets、signing、billing、App Store upload、GitHub token、生产发布、force push、破坏性 Git、真实用户数据 | 人工执行/明确人工批准；Codex 仅分析或审 evidence | 人工必需，Codex 不执行 |

非 Codex 输出不是结论，而是待验证 evidence。Claude 仅在 agy 不可用时作为 L0/L1 backup；Qwen 仅在敏感/private 情况下参与。

## 5. Single Writer Rule

**P0：同一 repo、worktree、branch 与 task window 内，只允许一个 write-capable executor。**

允许并行的工作仅限：只读 review、日志摘要、风险清单、测试 checklist 和 Codex review packet 生成。需要第二个写入者时，必须：创建 sandbox copy；或创建经人工批准的隔离 worktree；或等待第一个写入者完成、验证并让工作区回到 clean。Prompt compliance 不足以防冲突，必须使用隔离或串行化。

## 6. Evidence Trust Levels

| 等级 | 内容 | 可用于 |
| --- | --- | --- |
| E0 | 只有 agent 自述，没有命令输出 | 不用于决策 |
| E1 | 提到命令名，没有 exit code 或输出 | 非正式讨论 |
| E2 | exit code 与摘要输出 | Web GPT 初审 |
| E3 | base/upstream SHA、git status、`git diff --stat`、`git diff --check`、命令、exit code、原始输出片段、改动/未跟踪文件、环境版本 | Codex compressed review |
| E4 | E3 加上可复现脚本、CI 或独立验证，以及 clean post-run status 或明确解释的预期未跟踪文件 | PR/release gate 候选 |

硬规则：没有 exit code 与 raw output snippets 就不是 evidence；没有 `git status` 就不能声称 repo clean；没有 diff 就不能审查改动。除 emergency 外，Codex 只接收 E3/E4 package。

## 7. Required Evidence Package

```text
# Agent Evidence Package

## 1. Task
- Goal:
- Risk level:
- Repo:
- Branch:
- Base SHA:
- Local HEAD before:
- Upstream SHA:
- Allowed scope:
- Forbidden scope:

## 2. Executor Identity
- Executor:
- Version:
- Agent/model/profile:
- Permission/sandbox mode:
- Dangerous permissions used: yes/no
- Log path:

## 3. Preflight
- git fetch origin: exit code:
- Branch:
- git status --short before:
- Local HEAD:
- Upstream HEAD:
- Worktree clean before task: yes/no

## 4. Changes
- Files modified:
- Files added:
- Files deleted:
- Untracked files:
- Generated files:
- git diff --stat:
- git diff --check exit code:

## 5. Verification
For each command:
- Command:
- Start time:
- End time:
- Exit code:
- Key raw output:
- Full log path:

## 6. Risk and Unknowns
- Known risks:
- Assumptions:
- Unverified items:
- Potential regressions:
- Evidence trust level: E0/E1/E2/E3/E4

## 7. Stop Conditions
- Triggered: yes/no
- Details:

## 8. Recommendation
- Ready for Web GPT review: yes/no
- Needs Codex: yes/no
- Needs human approval: yes/no
- Recommended next action:
```

## 8. Codex Trigger Conditions and Round Limits

Codex 必须介入：支付/IAP/paywall、release/archive/upload/signing、隐私/安全/数据边界、CI/CD、核心导入导出、多文件重构、无法定位的失败测试、telemetry 与弱 agent 结论冲突、最终 PR go/no-go、弱 agent 请求扩大 scope，或无证据的“应该可以”结论。

轮次限制：L0/L1 默认 0 轮；L2 默认 1 次 compressed review；L3 必须参与但 2 轮后需人工决定是否继续；L4 只分析，人工执行/批准必需。任何额外 Codex round 都必须在 evidence package 中写明 trigger reason。

## 9. Agy / Antigravity Execution Contract

每个 agy 任务必须先执行版本同步 gate：

```bash
git fetch origin
git branch --show-current
git status --short
git rev-parse HEAD
git rev-parse --abbrev-ref --symbolic-full-name @{u} || true
git rev-parse @{u} || true
```

任务开始前 dirty、分支不符合预期、无法安全 fast-forward、所需改动超 scope、需改 protected files、测试因不明原因失败、permission mode 不安全，或命令输出推翻假设时必须 stop。agy 必须记录全部命令与 exit code，并返回 E3 evidence package。

## 10. Claude Backup Contract

仅在 evidence 表明 agy 容量耗尽或不可用时启用。模式限定为 `docs-only`、`red-team-only` 或明确批准的 `low-risk patch`。输出只能是改动/审查内容、evidence、风险、假设和下一步所需审查；不得给出 final approval。

## 11. Qwen Local-Only Contract

Qwen 处理 local-only 私密输入时，应提取事实、精确错误、evidence lines、疑似原因、敏感项和可给 Web GPT 的脱敏摘要，并明确 unknowns。必须脱敏 token、私有路径、邮箱、设备 ID、账户 ID 与凭证，除非 Ethan 明确授权最小范围披露。

## 11.1 Qwen Local Model Resource Safety Gate

```text
Qwen local invocation is privacy-preserving but not automatically system-safe.
Any local Qwen call must pass a central context-planning step and a local resource preflight before model loading.
If either step fails, Qwen must not be launched.
```

### Central Context Planner + Local Resource Gate

Qwen 不是 self-authorizing。每次调用前必须依序满足：

1. 中央 planner 分配最小充分 context budget。
2. 本地 executor 运行 memory/resource preflight。
3. 两者均通过后，才可加载或启动 Qwen。

中央 planner 由 Web GPT 或 Codex 承担，取决于风险和隐私边界。它判断是否需要 Qwen、给出 minimum sufficient context、优先选择 chunking、retrieval、grep/index 或 map-reduce，并且**不直接启动 Qwen**。

本地 executor 为 agy 或人工 terminal。它确认 runtime、model、quantization、context cap、`max_kv_size` 行为和 offline boundary；只有 resource gate 通过，才可启动 Qwen。

### Default Context Policy

- 默认 Qwen context 为 **8K–16K**。
- 32K 需要明确的 task-level approval。
- 64K 需要专门 benchmark 与 idle-system preflight。
- 对 64GB Mac，128K 默认禁止；除非针对精确 runtime、model、quantization、context size 与 prompt pattern 的独立 memory benchmark 已证明安全。
- 不得因为模型宣传支持就默认使用 128K；应以保留任务 evidence 所需的最小 context 为准。
- 优先 chunking、retrieval 和 map-reduce，而非长 single-shot context。
- 请求超过 16K 时，evidence package 必须解释原因；超过 32K 时必须有 Ethan 明确批准。
- runtime 无法限制 context 或 KV cache 时，不得使用 server mode。

| Task type | Default context | Policy |
| --- | ---: | --- |
| 单段敏感日志 | 4K–8K | 仅在 resource gate 通过后 direct processing |
| 多段日志 | 8K–16K | 先 chunk |
| 私有单文件摘要 | 8K–16K | 只含目标 spans |
| 多文件私有 triage | 16K | 按 file/module chunk |
| Evidence package compression | 16K–32K | 32K 需要明确批准 |
| Whole-repo understanding | 不允许 | 使用 grep/index/chunk summaries |
| 64K | Exceptional | 需要 benchmark 与 idle-system preflight |
| 128K | 默认禁止 | 仅可由精确 runtime/model/context benchmark 推翻 |

### Runtime Verification Requirement

Qwen 仍视为未完全验证运行时，直到以下全部确认：

1. exact local command；
2. runtime：MLX、Ollama、llama.cpp、LM Studio 或其他；
3. model path/name；
4. quantization；
5. max context / `max_kv_size` 行为；
6. server mode 是否能限制 context 与 KV cache；
7. execution 是否完全 offline；
8. observed peak memory 与 swap behavior。

### Memory Preflight Gate

加载 Qwen 前必须收集：总 physical memory、memory pressure、swap usage、compressed memory（若可得）、top memory consumers；确认没有 heavy build、simulator、browser、Xcode archive、Docker 或其他 LLM 在运行；估算 model memory + KV cache + headroom，并保留足够安全余量。

硬 stop：memory pressure 不为 green/normal；swap 已明显活跃或持续增长；可用 headroom 小于估算 model requirement 加 12–16GB system reserve；另一个 local LLM、Xcode archive、iOS simulator、Docker 或大型 build 正在运行；请求 >32K 但无明确批准；请求 64K/128K 但无 benchmark evidence；server runtime 无法限制 context 或 KV cache。

建议的只读 preflight evidence：

```bash
date
uname -a
sw_vers || true

sysctl hw.memsize
vm_stat
memory_pressure || true

top -l 1 -s 0 -o mem | head -n 25
ps aux | egrep -i "mlx|ollama|llama|lm studio|qwen|python|node|xcodebuild|simulator|docker" | grep -v egrep || true

du -sh /path/to/model 2>/dev/null || true
```

这些命令是 evidence inputs，不是自动安全证明；结果必须保守解释。若 evidence 含糊，不得启动 Qwen。

### Qwen Context and Resource Gate

```text
## Qwen Context and Resource Gate
- Task:
- Privacy reason for using Qwen:
- Central planner:
- Requested context:
- Minimum context rationale:
- Chunking alternative considered: yes/no
- Runtime:
- Model:
- Quantization:
- Context/KV cap:
- Total memory:
- Memory pressure:
- Swap before:
- Heavy processes:
- Estimated model + KV requirement:
- Required reserve:
- Decision: pass / fail
- If fail, fallback:
```

Pilot-safe mode：context 仅 8K 或 16K；一次仅一个 request；memory/context limit 未验证时不运行 server daemon；不使用 128K；不并行 local LLM；不运行会无限增长 conversation history 的 agent loop。

长私有材料优先：拆分 input、逐 chunk 本地摘要、合并 summaries；必要时只将脱敏后的 E2/E3 package 提交给 Web GPT 或 Codex。

若 gate 失败：不启动 Qwen；降至 8K 或 16K；将输入拆成小批次；请 Ethan 关闭 heavy apps 后重新 preflight；或仅用 Ethan 批准且人工脱敏的最小 evidence 使用 Web GPT。

## 12. Web GPT Privacy Boundary

Web GPT 是 planning/review/prompt/external-research 层，不是本地执行控制平面。它可审公开、GitHub-visible、用户批准或脱敏 evidence；不能代替 terminal telemetry、构建或测试。私有内容进入 Web GPT 前必须满足最小披露与审核边界。

## 13. Tutti Command-Only Policy

已验证事实：Tutti v0.10.1 可构建；command-only strict workflow 通过；explicit allowlist 生效；负向 `pwd` 被拦截。它不支持 external state path，`.tutti/state` 硬编码在 workspace 下，且可能包含 `/Users/...` 绝对路径。

允许的 constrained pilot：sandbox copy、command-only workflow、explicit allowlist、`fail_mode = closed`、sandbox HOME、先运行 `tt run verify --dry-run --json --strict`，再运行 `tt run verify --strict` 与 `tt verify --strict`。

禁止：`tt up`、`tt send`、`tt review`、`tt serve`、`tt watch`、`tt land`、`tt land --force`、`tt land --pr`、`tt usage`、`tt down --clean`、真实 repo `tt init`、agent/prompt/review/land/scheduled/webhook workflow steps，以及 worktree orchestration。

Clean gate adjustment：只有在 `.tutti/` 已进入经人审的 `.gitignore`、validator 只排除 `.tutti/`、`.tutti/` 保持 untracked 时，才可将它作为预期工具状态处理。绝不忽略所有 hidden directories，也绝不忽略所有 untracked files。

## 14. Repo-Specific Rules

- **truth-seeking-skill / rational-product-evaluation / ai-devos-kit**：默认 L1-L2。Tutti 仅 command-only，且 private-path validator 必须经人审后精确排除 `.tutti/`。
- **AI-Agent-Database**：默认 L2-L3。Web GPT 负责策略/evidence review；Qwen 可处理敏感日志；Codex 决定策略 gate、market simulation 规则和自动化安全边界。Tutti 不得替代 Hermes 或接管定时任务。
- **DishPick / APP两元店**：默认 L2-L4。IAP、paywall、release、signing、App Store upload、privacy 与核心业务逻辑必须有 Codex 和人工 gate；Tutti 暂不进入真实 app repo。
- **岁月留声 / syls**：默认 L2-L4。`.syllsbundle`、private/public payload、家庭故事隐私、persona simulation、import/export、delivery bundle 属高风险；Codex 必须参与边界判断与最终交付 gate。

## 15. Stop Conditions

任一 executor 遇到以下情况必须停止并输出 evidence：任务前 worktree dirty；HEAD 与远端不一致且不能安全 fast-forward；需改 protected files；需访问 secrets/auth/signing/billing；测试失败且原因不清；输出与假设冲突；任务需扩大 scope；出现未授权网络写；出现 push/merge/rebase/reset 要求；发现路径、token 或隐私泄漏；sandbox/permission mode 不安全；Qwen requested context 未经过 central budgeting；Qwen resource preflight 未运行或失败；请求 context 超出批准预算；memory pressure、swap、wired memory 或 compressed memory 风险不安全；local runtime 无法限制 context/KV cache。

## 16. KPI and Weekly Review

每周记录：

- **Weekly Codex Review Count**：Codex review 数、任务等级、trigger、轮次、是否发现 blocking issue。
- **Codex Avoidance Rate**：未使用 Codex 完成的 L0-L2 数量、验证通过率、之后的 defect/rollback。
- **Escape / Rollback Rate**：非 Codex 完成后发现的问题、返工、晚升级到 Codex 的任务。
- **Local Model Safety Events**：Qwen preflight pass/fail 数、requested context 分布、已测量的 peak memory、swap/hang incidents，以及因 headroom 不足而避免的 launches。

Pilot targets：L0/L1 Codex avoidance rate ≥ 80%；L2 优先 compressed review 而非 full execution；L3/L4 Codex participation = 100%；escaped defect / rollback rate ≤ 10%；没有 L4 action 可绕过人工批准。

## 17. Templates

### Agy execution prompt

```text
/goal
Execute this task as Ethan's default local execution layer: agy / Antigravity.
Make the smallest safe change, run verification, and return an E3 evidence package.

Allowed files: [insert]
Forbidden files: [insert]
Allowed commands: [insert]

Run the version sync gate first. Stop on dirty worktree, unsafe permission mode,
scope expansion, protected-file access, or unclear test failure. Record agy version,
agent/model/profile if available, mode, every command, exit code, and log path.
Never use --dangerously-skip-permissions, push, merge, rebase, reset --hard,
or signing/billing/secrets/release operations.
```

### Codex review packet prompt

```text
/goal
Review this E3/E4 evidence package and diff. Do not re-run the whole task unless necessary.
Identify correctness issues, hidden risks, missing tests, unsafe assumptions, and whether it can proceed.

Repo: [insert]
Branch/Base/HEAD/Upstream: [insert]
Risk level and task: [insert]
Changed files: [insert]
Verification with exit codes: [insert]
Known failures: [insert]

Forbidden: push, merge, rebase, reset, secrets/signing/billing/release changes,
and scope expansion unless required for correctness.
Return: verdict; blocking/non-blocking issues; required fixes; validation commands;
whether another Codex round and human approval are justified.
```

### Claude backup prompt

```text
/goal
Act as backup only because agy / Antigravity is unavailable or quota-limited.
Mode: [docs-only / red-team-only / low-risk patch]
Do not make high-risk decisions or final approvals.
Allowed scope: [insert]
Return: changed/reviewed items, evidence, risks, assumptions, and required next review.
```

### Qwen local triage prompt

```text
/goal
Process this content locally for privacy-preserving triage.
Label all output: LOCAL MODEL PRELIMINARY OUTPUT — REQUIRES VERIFICATION
Return facts, exact errors, evidence lines, suspected causes, sensitive items,
a redacted Web GPT summary, unknowns, and whether Codex/human review is required.
Do not infer beyond evidence or make final decisions.

## Qwen Context and Resource Gate
- Task:
- Privacy reason for using Qwen:
- Central planner:
- Requested context and minimum-context rationale:
- Chunking alternative considered: yes/no
- Runtime / model / quantization:
- Context/KV cap:
- Total memory / memory pressure / swap before:
- Heavy processes:
- Estimated model + KV requirement / required reserve:
- Decision: pass / fail
- If fail, fallback:
```

### Stop report template

```text
# Stop Report
- Task / repo / branch / HEAD:
- Stop condition:
- Commands and exit codes:
- Raw evidence:
- Files changed before stop:
- Protected scope touched: yes/no
- Safe next action requiring approval:
```

## 18. Adoption Roadmap

1. **Week 1 — shadow mode**：只生成 task packet 与 E2/E3 evidence，不改变既有人工/Codex gate。
2. **Week 2 — L0/L1 delegation**：允许 agy 在明确 scope 内执行，并按 KPI 记录 Codex avoidance。
3. **Week 3 — constrained L2**：仅在验证完整、single writer 生效时引入一次 Codex compressed review。
4. **Week 4 — review**：复盘 escape/rollback、证据完整度、权限事件和实际 Codex 节流结果；未达标则缩小而非扩大自动化范围。

L3/L4 与 Tutti agent/worktree orchestration 不在本 pilot 的升级范围内。

## 19. Change Log

| Version | Date | Change |
| --- | --- | --- |
| 1.1 Pilot P0 | 2026-07-10 | 补充 Qwen central context planner、dynamic context budgeting、memory/swap preflight、context/KV cap、pilot-safe mode 与 fallback gate。 |
| 1.1 Pilot | 2026-07-10 | 建立以 agy 为默认执行、Codex 节流、E0-E4 evidence、single writer、Qwen 未验证运行时和 Tutti command-only 边界为核心的本地协作 SOP。 |
