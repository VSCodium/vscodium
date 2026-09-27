---
name: swarm
description: '组建并指挥一队并行工作的 agent 完成一个任务：选机制（后台 subagent / 动态 workflow / agent team）、选团队模式、设计角色与提示词、确认后编排执行与收尾。凡用户说「创建团队 / 组建团队 / 开个团队做这个 / 团队作战 / 蜂群 / swarm / 多 agent 协作 / parallel agents / spawn teammates / 并行跑几个 agent / 产品团队 / 需求评审团队 / 审计团队 / 一起 review 这个 PR」，或执行 `/swarm`，或交来一个明显需要多人分工的任务（跨层新功能、全库审计、难查的 bug、技术选型辩论、大规模重构迁移、需求设计与澄清评审）时，务必使用本 skill——即使用户没说「团队」两个字。也用于判断「这个任务到底要不要开团队」：很多时候后台 subagent 或动态 workflow 更便宜更快，本 skill 会先做这个判断。'
---

# 蜂群 Swarm

把一个任务拆给一队并行工作的 agent，由你（lead）负责选人、派活、协调、把关、合成。

> **路径约定**：`references/` 相对于本 `SKILL.md` 所在目录。团队模式文件按需只读命中的那一个，不要全读。

## 核心流程

```
选机制 → 环境预检 → 分析任务 → 选团队模式（只读一个文件）→ 设计角色与提示词
      → 用户确认 → 派发执行 → 监控协调 → 收尾汇报
```

---

## 第 0 步：先选机制，别默认开团队

开团队是最贵的一种做法：每个 teammate 都是独立会话，各自烧 token，还要你逐轮协调。先问三个问题：

1. **worker 之间需要互相说话吗？**（交换发现、互相质疑、协商接口）
2. **需要一份共享任务清单来传递依赖吗？**
3. **需要多轮往返吗？**（草稿 → 评审 → 修订 → 再评审）

三个都是「否」→ 不要开团队，用下面更轻的机制。

| 机制 | 什么时候用 | 代价 |
|------|-----------|------|
| **自己干** | 一两步能完成、改动集中在少数文件 | 最低 |
| **后台 subagent**（`Agent` 工具，默认后台运行） | 侧任务会用搜索结果/日志/文件内容淹掉主对话，且 worker 之间不需要沟通 | 低 |
| **动态 workflow**（提示词里写 `ultracode`，或 `/workflow-authoring` 存成 `.claude/workflows/*.js` 后用 `/<名字>` 跑） | 同一套动作要跑几十到几百次：全库审计、500 文件迁移、多来源交叉验证、从多个角度起草同一份方案 | 中，但脚本一次写好可复用 |
| **`/batch` skill** | 一个大改动要拆成 5–30 份、各自在独立 worktree 里做完并各开一个 PR | 中 |
| **agent team**（本 skill 主场景） | 多个较长任务、worker 之间要交换发现、要共享任务清单、要多轮往返 | 高 |
| **agent view**（`claude agents`）/ 手动 worktree | 你自己想分别盯着几个独立会话 | 你的注意力 |

机制的能力边界、脚本原语、字段清单见 `references/agent-types.md` §1。

---

## 第 1 步：环境预检（只在决定开团队时做）

开团队前把这四件事核实清楚，否则后面每一步都会踩空：

1. **agent teams 是实验特性，默认关闭。** 需要 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`（写进 `settings.json` 的 `env`，或 shell 导出）。没开就如实告诉用户怎么开，不要假装团队已经起来了。
2. **共享任务清单不一定存在。** `TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` 是按模型注入的：Claude 3.x、Opus 4–4.7、Sonnet 4–4.6、Haiku 4.5 默认有；在 Opus 4.8 / Sonnet 5 / Fable 5 这类较新模型上，即使设了 `CLAUDE_CODE_ENABLE_TASKS=1` 也可能拿不到。**没有清单时流程要能降级**：由你（lead）自己维护一张任务表，依赖关系写进每条派发消息里，用 `SendMessage` 指名推进。
3. **展示模式。** in-process（默认，teammate 显示在输入框下方的 agent 面板，↑↓ 选中 + Enter 查看）或 split panes（需要 tmux 或 iTerm2，`teammateMode` 设置 / `--teammate-mode`）。VS Code 集成终端、Windows Terminal、Ghostty 不支持 split panes。
4. **没有 `TeamCreate` / `TeamDelete`**（Claude Code 2.1.178 起移除）。一个会话只有一个隐式团队，名字形如 `session-xxxxxxxx`，资源自动清理。同理：一个会话不能开第二个团队，teammate 也不能再开自己的团队。

---

## 第 2 步：分析任务

| 维度 | 评估内容 |
|------|---------|
| 任务类型 | 功能开发 / 需求设计 / 代码审计 / Bug 调试 / 技术选型 / 重构迁移 |
| 产出物 | 代码 / 文档 / 结论决议 —— 决定文件范围怎么切、谁能写 |
| 可并行度 | 哪些子任务能同时进行，哪些必须串行 |
| 文件冲突 | 不同角色是否会写同一个文件（团队不会自动给 teammate 开 worktree） |
| 依赖关系 | 谁必须等谁；契约类产物要不要先冻结 |
| 用户介入点 | 哪些决定必须用户拍板（teammate 问不到用户，只能回传给你） |
| 复杂度 | 决定团队规模（2–8 人） |

---

## 第 3 步：选团队模式 —— 只读命中的那一个文件

| 团队 | 什么时候选 | 参考文件 |
|------|-----------|---------|
| **功能开发** | 新功能、跨层变更（前端+后端+测试） | `references/teams/feature-dev.md` |
| **产品团队** | 需求设计、需求澄清、需求评审、验收标准体检、需求拆分 | `references/teams/product.md` |
| **代码审计** | PR review、安全/性能/正确性审计、上线前体检 | `references/teams/code-audit.md` |
| **调试竞争** | 难查的 bug、根因分析、多个假设要同时验证 | `references/teams/debug-race.md` |
| **研究辩论** | 技术选型、架构决策、方案评估、要不要自研 | `references/teams/research-debate.md` |
| **重构迁移** | 大规模重构、框架/版本迁移、模块拆分 | `references/teams/refactor-migration.md` |

- **只读命中的那一个文件。** 六个文件全读会把无关的角色表和规则塞进上下文，干扰判断。
- **混合场景**：以主模式为骨架，需要时再去另一个文件借一两个角色，仍然只读用到的那一个。
- **都不像**：按 `references/agent-types.md` §9 的原则自行设计，不要硬套。

---

## 第 4 步：设计角色与提示词

每个 teammate 定六件事：

| 要素 | 说明 |
|------|------|
| 角色名 | 短、可被 `SendMessage` 指名，如 `product-designer`、`security-reviewer` |
| 载体 | 内置 subagent 类型（`general-purpose` / `Explore` / `Plan`），或 `.claude/agents/<name>.md` 自定义定义 |
| 模型 + effort | 按任务难度选；`Explore` 的模型有特殊上限，见 `references/agent-types.md` §5 |
| 权限模式 | 只读分析用 `default`/`plan`，写代码用 `acceptEdits`；**spawn 时不能给单个 teammate 指定**，spawn 后可改 |
| 文件范围 | 明确可写目录 + 明确禁区；同一文件只能有一个写手 |
| 输出契约 | 结构化报告的字段、判定档位、引用格式（文件:行号） |

**提示词模板**：

```
角色：{role}
职责：{responsibilities}

上下文：
- 你的上下文里没有主对话历史，下面是你需要的全部背景：{background}
- 任务来源：{task_description}

工作范围：
- 只修改：{allowed_dirs}
- 不要触碰：{excluded_dirs}（另有 teammate 负责）

输出要求：
- {output_format}
- 结论要有判定档位，不要只写感想

协作规则：
- 你拿不到 AskUserQuestion，需要用户拍板的问题回传给 lead，不要替用户决定
- 发现跨模块影响时，用 SendMessage 通知 {related_teammate}
- 完成任务后把结论作为最后一条消息发出（lead 会通过 idle 通知收到它）

完成标准：
- {completion_criteria}
```

写法要点、字段清单、subagent 拿不到哪些工具（以及这对提示词意味着什么）见 `references/agent-types.md` §3、§7、§9。

---

## 第 5 步：展示计划并确认

```markdown
## 团队计划

**任务**：{task_description}
**机制**：agent team / 后台 subagent / 动态 workflow（说明为什么选它）
**模式**：{pattern_name}
**团队规模**：{count} 人

### 角色分配

| # | 角色 | 载体 | 模型/effort | 职责概要 |
|---|------|------|------------|---------|
| 1 | {name} | {type} | {model} | {summary} |

### 任务与依赖

| ID | 任务 | 负责人 | 依赖 |
|----|------|--------|------|
| 1 | {task} | {owner} | - |
| 2 | {task} | {owner} | 等 1 |

### 文件分工（避免冲突）

| 角色 | 可写范围 | 禁区 |
|------|---------|------|
| {name} | {dirs} | {excluded} |

### 需要你拍板的点
- {open_questions}

确认此计划？(Y / 修改建议)
```

用 `AskUserQuestion` 让用户确认或提修改意见。**不要跳过这一步**：团队一旦跑起来，纠错成本远高于事前改计划。

### 计划就在对话里给，别额外落一堆文件

角色提示词作为计划的一部分写出来就行。只有用户明确说要复用某个角色（「把这个审查者存下来」）时，才写 `.claude/agents/<name>.md`。

原因不是磁盘，是轮次：每多写一个文件就多一轮工具调用，而每一轮都会把已有上下文重新读一遍。实测一次团队规划里，缓存重读占总 token 的 85% 以上，而读 skill 本身只占约 1%。把七份产物合成一份，比精简任何参考文档都省。

---

## 第 6 步：派发执行

### 6.1 启动 teammate

用 `Agent` 工具，带上 `name` 参数（这就是 teammate 的名字，后续 `SendMessage` 用它指名）：

```
Agent → subagent_type: "{agent_type}"     # 内置类型，或 .claude/agents 里的自定义名
        name: "{role_name}"
        prompt: "{designed_prompt}"
        model: "{model}"                  # 可选；不填则按 subagent 模型顺序解析
```

注意：
- 没有 `team_name` 参数（团队是隐式的），也不能在 spawn 时传权限模式。
- agent teams 打开时，**任何被你指名的 subagent 都会以 teammate 形式启动**，包括你在别的场景里习惯性指名的那些。
- 想用 `.claude/agents/*.md` 的定义当 teammate：`tools`、`model` 和正文会生效，`skills` **不会**应用到 teammate，`mcpServers` 只在 split-pane 模式生效。需要 teammate 用某个 skill 时，在提示词里把要点写进去。

### 6.2 建任务清单（如果有 Task 工具）

`TaskCreate` 建全部任务 → `TaskUpdate` 设依赖与 owner。没有 Task 工具就走降级路径（第 1 步第 2 条）。

### 6.3 派活

有清单：`TaskUpdate` 设 owner。没清单：`SendMessage` 指名派发，消息里写清任务、依赖、产出要求。

---

## 第 7 步：监控与协调

1. **不要轮询。** teammate 空闲时，它的最终答复会通过 idle 通知自动送到你这里。
2. **面板里消失的 idle 行是被隐藏，不是被停止**（整块面板空闲 30 秒后隐藏；超过 3 个空闲会折叠成 `N idle agents`）。按名字发一条消息就能唤回。
3. **teammate 遇错可能直接停下**而不是自己恢复。进它的输出看一眼（in-process：面板选中 + Enter；split：点对应 pane），然后追加指令，或换一个 teammate 接手。
4. **你自己也可能提前收工**——任务没全完就宣布结束。用户说「继续」时接着推进。
5. **任务状态会滞后**：teammate 有时忘记标 completed，卡住下游。核实工作实际已完成就手动改状态，或提醒它。
6. **解决文件冲突**：多个 teammate 要写同一文件时，排定顺序或重新切分范围；共享文件（配置、类型定义、路由表）由你统一改。
7. **质量把关**：审查产出，不合格就退回要求修改，别把半成品合进结果。

---

## 第 8 步：收尾

1. 按名字向每个 teammate 发 shutdown 请求。它会先做完当前的请求或工具调用，也可能拒绝关闭（比如认为活没干完）——等它确认，别硬来。
2. 团队资源自动清理，**不要去找 `TeamDelete`**。
3. 提醒用户：`/resume` 和 `/rewind` 不会恢复 in-process teammate。恢复会话后如果 lead 去给已经不存在的 teammate 发消息，需要重新 spawn。
4. 向用户汇报：最终成果、每个角色的关键结论、未决问题、以及需要用户拍板的事项。

---

## 关键规则

### 避免文件冲突（最重要）

不同 teammate 不能同时改同一文件。agent team **不会**自动给 teammate 开 worktree。

- 按目录/模块切分文件范围，写进每个提示词
- 共享文件由 lead 统一修改
- 确实需要隔离时用 `isolation: worktree`（自定义 subagent 定义）或手动 worktree
- 跨模块变更走消息协调，不要各改各的

### 控制团队规模

宁少勿多。每加一个 teammate 都加一份 token 消耗和协调成本。官方建议 3–5 人起步。

| 任务复杂度 | 建议人数 |
|-----------|---------|
| 简单（单模块） | 2–3 |
| 中等（跨模块） | 3–4 |
| 复杂（跨层） | 4–6 |
| 大型（架构级） | 5–8 |

### lead 只协调，不实现

发现自己在写代码/写文档时停下来，把它派给 teammate。你的上下文要留给协调、把关和合成。

### 提示词要具体

teammate 的上下文里没有主对话历史，模糊的提示词等于让它自己猜。必须包含：具体文件路径、明确输出格式、清晰完成标准、以及「不确定就回传 lead」。

### 用户是唯一信息源

teammate 拿不到 `AskUserQuestion`。需要用户拍板的问题一律回传给你，由你**批量、一次性**问完，再把答复广播给相关 teammate。

---

## 参考资源

- **`references/agent-types.md`** — 并行机制对照、内置 subagent 类型、自定义 subagent 字段、teammate 运行事实、模型与 effort、权限模式、工具限制、隔离方案、提示词写法
- **`references/teams/*.md`** — 六种团队模式，各一个文件，按需只读命中的那一个
