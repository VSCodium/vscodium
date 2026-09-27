# Agent 能力与角色选型

> 本文件描述的是 Claude Code 当前（2.1.x 系列）的多 agent 能力。带版本号的条目表示该行为是某个版本引入或改变的，升级后请复核。
>
> **目录**
> - §1 五种并行机制怎么选
> - §2 内置 subagent 类型
> - §3 自定义 subagent（`.claude/agents/*.md`）
> - §4 teammate 的运行事实
> - §5 模型与 effort
> - §6 权限模式与继承规则
> - §7 subagent 拿不到的工具，以及它对提示词的影响
> - §8 隔离：worktree 与文件冲突
> - §9 角色提示词写法
> - §10 成本与缓存
> - §11 来源

---

## §1 五种并行机制怎么选

| 机制 | 谁在协调 | worker 之间能说话吗 | 适合 |
|------|---------|------------------|------|
| **subagent**（`Agent` 工具） | 你（主对话），派完收结果 | 不能，只把结果交回派出它的对话 | 侧任务、一次性调研、并行评审 |
| **agent view**（`claude agents`） | 你自己，一个个看 | 不能（可用跨会话消息传递发现） | 你手上有几个独立任务想分别托管 |
| **agent team** | lead（主会话）规划、派活、监督 | 能，`SendMessage` 直连；有 Task 工具时还共享任务清单 | 多个较长任务、需要来回协商 |
| **动态 workflow** | 一段 JS 脚本 | 不能直接说话，但脚本能把 A 的结论喂给 B | 同一套动作跑几十上百次、要交叉验证 |
| **projects**（claude.ai/code） | 云端 | 各自独立 thread | 跨天跨周的长期工作，机器关机也要跑 |

两个打包好的用法，不用自己搭：

- **`/batch` skill** — 把一个大改动拆成 5–30 个 worktree 隔离的 subagent，每个各开一个 PR。
- **`/workflow-authoring` skill** — 帮你把一段编排写成脚本存到 `.claude/workflows/<name>.js`，之后用 `/<name>` 直接跑。

### 动态 workflow 的原语与硬限制

脚本体是纯 JavaScript，不能 `import()`，也不能自己读写文件或跑命令——**文件操作和命令都由 agent 做，脚本只负责编排**。

| 原语 | 作用 |
|------|------|
| `agent(prompt, opts)` | 跑一个 subagent，返回它的结果 |
| `parallel([...])` / `pipeline([...])` | 扇出并行 / 串成流水线 |
| `phase(name, fn)` | 分阶段，`/workflows` 里能看到进度 |
| `log(msg)` | 打进度 |
| `args` | 调用时传入的参数 |

限制：默认最多 16 个 agent 并发（环境变量可调到 256）；单次运行最多 1000 个 agent；单个 `parallel()`/`pipeline()` 最多 4096 项。运行中**不能问用户**——只有权限提示和用量等待会让它暂停。需要中途签字确认的，把每一段拆成独立的 workflow。

触发方式：提示词里写 `ultracode`，或 `/effort ultracode`，或直接说「用 workflow 做」。`/workflows` 查看运行中的和已完成的。

**判断口诀**：worker 之间要说话、要共享任务清单、要多轮往返 → agent team；同一套动作重复很多次、结果要互相校验 → workflow；只是不想让侧任务污染主对话 → 后台 subagent。

---

## §2 内置 subagent 类型

通过 `Agent` 工具的 `subagent_type` 指定。省略 `subagent_type` 时，如果会话里没有 `general-purpose` 可回退，会报 `subagent_type is required`。

| 类型 | 工具 | 模型 | 特点与坑 |
|------|------|------|---------|
| **`general-purpose`** | subagent 可用的全部工具 | `CLAUDE_CODE_SUBAGENT_MODEL`，否则跟随主对话 | 需要既探索又改动的多步任务。实现类角色的默认载体 |
| **`Explore`** | 只读；`Write`/`Edit` 被拒 | 跟随主对话，但在 Claude API 上**封顶到 Opus** | 搜索/理解代码库。调用时要指定彻底程度：**quick**（定点查找）/ **medium**（均衡）/ **very thorough**（全面） |
| **`Plan`** | 只读 | 跟随主对话 | plan mode 下收集上下文、出方案的研究 agent。做架构分析可以，但它不是为「常驻架构师」设计的 |
| **`claude`** | subagent 可用的全部工具 | 按模型顺序解析 | 兜底类型，任务不匹配任何专门 agent 时用 |
| `statusline-setup` / `claude-code-guide` | — | Sonnet / Haiku | Claude Code 自用，别拿来当团队角色 |

> **`Explore` 和 `Plan` 都不加载 CLAUDE.md，也不看父会话的 git status**（为了让研究快而便宜）。其他内置类型和自定义 subagent 两者都加载，除非定义里写了 `omitClaudeMd`。所以：凡是依赖仓库约定的角色（架构师、需要遵守目录规范的实现者），别用 `Explore`/`Plan`，或者把必要的约定直接抄进提示词。

两点实用推论：

1. **想让探索跑在便宜模型上**：在项目或用户目录定义一个同名 `Explore` 的自定义 subagent，它会覆盖内置版本并保留自己的 `model` 字段（例如 `model: haiku`）。
2. **想禁掉某个内置类型**：加 deny 规则；`CLAUDE_CODE_DISABLE_BUILTIN_AGENTS=1` 则全部禁用，只留你自己的。

---

## §3 自定义 subagent（`.claude/agents/*.md`）

项目级放 `.claude/agents/`，用户级放 `~/.claude/agents/`，插件也可以带。文件是「YAML frontmatter + Markdown 正文（系统提示词）」。

**什么时候值得落盘成文件**，而不是每次在提示词里现写：

- 这个角色会被反复用（例如每次审计都要的 `security-reviewer`）
- 需要限制工具集（只读审查者不给 `Write`/`Edit`/`Bash`）
- 需要固定模型、effort 或权限模式
- 需要 worktree 隔离

frontmatter 字段（按需选用，不必写全）：

| 字段 | 作用 |
|------|------|
| `name` | 调用名，`subagent_type` 用它 |
| `description` | 什么时候该派它——写清楚才会被自动选中 |
| `tools` / `disallowedTools` | 白名单 / 黑名单。带参数的条目如 `Bash(git push *)` 会**移除整个工具**，不是只移除该参数形式 |
| `model` | `sonnet` / `opus` / `haiku` / `fable` / 完整 ID（如 `claude-opus-5`）/ `inherit` |
| `permissionMode` | 见 §6。`manual` 是 `default` 的别名（需 v2.1.200+）。插件 subagent 忽略此字段 |
| `maxTurns` | 到上限就停，输出会标注被截断 |
| `effort` | 推理强度，见 §5 |
| `skills` | 预加载的 skill。**注意：对 teammate 不生效**（见 §4） |
| `mcpServers` | 只给它连的 MCP server。**只在 split-pane teammate 下生效** |
| `hooks` | 这个 subagent 专属的 hook |
| `memory` | 跨调用记忆 |
| `background` | 是否后台跑。**in-process teammate 派出的 subagent 不能后台**，会报错 |
| `isolation` | `worktree` → 给它单独的 git worktree |
| `omitClaudeMd` | 不注入 CLAUDE.md |
| `color` / `initialPrompt` / `experimental.cacheTtl` | 外观与缓存微调 |

校验：`claude plugin validate .claude/agents`（v2.1.233+）能查出 frontmatter 解析不了的文件。

`/agents` 自 v2.1.198 起**不再打开交互式创建面板**，只会提示文件位置。要建就直接让 Claude 写文件，或自己写。

---

## §4 teammate 的运行事实

这些是 agent team 与「一次性 subagent」的关键差别，设计角色时必须知道：

| 事实 | 影响 |
|------|------|
| 团队是**隐式**的，一个会话一个，名字形如 `session-xxxxxxxx` | 没有 `team_name` 参数可传，也没有 `TeamCreate` / `TeamDelete`（2.1.178 起移除），资源自动清理 |
| teammate 用 `Agent` 工具 + `name` 参数启动 | `name` 就是后续 `SendMessage` 的收件地址 |
| **lead 固定**，主会话终生是 lead | 不能把某个 teammate 提升为 lead，也不能移交 |
| **不能嵌套**：teammate 不能再开 teammate | 需要两层分工时，第二层只能是它自己派的一次性 subagent |
| 权限模式在 spawn 时**不能按人指定** | teammate 继承 lead 的模式（`dontAsk` 除外）；spawn 之后可以单独改某个人的 |
| 用 `.claude/agents/*.md` 当 teammate 时：`tools`、`model`、正文生效；**`skills` 不生效**；`mcpServers` 只在 split-pane 生效 | 需要 teammate 遵循某个 skill 的做法时，把要点直接写进提示词 |
| **idle 通知**会把 teammate 的最终答复自动送给 lead | 不要轮询；等通知 |
| in-process 面板里空闲的行会在整块面板空闲 30 秒后隐藏；超过 3 个空闲折叠成 `N idle agents` | 消失 ≠ 停止。按名字发消息即可唤回 |
| shutdown 是**请求**，teammate 可以拒绝 | 它会先做完当前请求或工具调用；别指望立刻消失 |
| `/resume`、`/rewind` **不恢复** in-process teammate | 恢复会话后 lead 可能去给已不存在的 teammate 发消息——重新 spawn |
| 任务状态会滞后，teammate 也可能遇错就停 | lead 要主动核实、手动改状态、追加指令或换人 |
| split panes 需要 tmux 或 iTerm2（`it2` CLI + Python API） | VS Code 集成终端、Windows Terminal、Ghostty 不支持；`teammateMode` 设置或 `--teammate-mode` 切换 |
| 打开 agent teams 后，**任何被 lead 指名的 subagent 都会变成 teammate** | 想恢复成普通 subagent：把 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` 设为 `0`（用户级 settings 的 `0` 会覆盖 shell 导出；项目/本地/`--settings`/托管设置的优先级更高）。改完不用重启会话 |
| teammate 的权限请求会冒泡到 lead | spawn 前先在 permission 设置里预批常用操作，否则会被打断很多次 |
| 相关 hook：`TeammateIdle`、`TaskCreated`、`TaskCompleted` | `TaskCompleted` 退出码 2 可以拦下完成并把反馈送回 teammate |

**共享任务清单不一定有**：`TaskCreate` / `TaskGet` / `TaskList` / `TaskUpdate` 按模型注入——Claude 3.x、Opus 4–4.7、Sonnet 4–4.6、Haiku 4.5 默认有；其他模型（含 Opus 4.8、Sonnet 5、Fable 5）默认没有，且实测即使设 `CLAUDE_CODE_ENABLE_TASKS=1` 也可能仍被模型门控掉（见 anthropics/claude-code#76076）。**设计流程时按「可能没有清单」来做**：lead 自己记一张任务表，依赖写进派发消息，用 `SendMessage` 推进。`TodoWrite` 在有 Task 工具的会话里默认被禁用，设 `CLAUDE_CODE_ENABLE_TASKS=0` 可换回它。

---

## §5 模型与 effort

### 模型别名

| 别名 | 解析为 |
|------|-------|
| `default` | 特殊值：清除覆盖，回到账号的运行时默认模型。它本身不是别名 |
| `best` | Fable 可用时用 Fable，否则等同 `opus` |
| `fable` | 当前 provider 的 Fable 模型，用于最难、最长时任务 |
| `opus` | 最新 Opus，复杂推理 |
| `sonnet` | 最新 Sonnet，日常编码 |
| `haiku` | 最快的 Haiku，简单检索与格式化 |
| `inherit` | 与主对话同模型（仅自定义 subagent 的 `model` 字段支持） |

也可以写完整 ID，如 `claude-opus-5`、`claude-sonnet-5`；第三方部署（Bedrock / Vertex / Foundry）写各自的 ARN、部署名或版本名。

### subagent / teammate 的模型解析顺序

1. 定义里的 `model` 字段，或 `Agent` 调用时传的 `model`
2. `CLAUDE_CODE_SUBAGENT_MODEL`（`_FORCE` 变体会压过第 1 条；只设 `_FORCE` 时内置 `Explore` 仍保留自己的 Opus 封顶）
3. 主对话的模型

### effort（推理强度）

`low` / `medium` / `high` / `xhigh` / `max`，可用档位随模型而变：Fable 5.1 与 5、Opus 5、Sonnet 5、Opus 4.8、Opus 4.7 支持到 `max`；Opus 4.6 与 Sonnet 4.6 只到 `high` + `max`。设了模型不支持的档位会回落到它支持的最高档。`/effort` 命令改当前会话，自定义 subagent 用 `effort` 字段。

### 给角色配模型的经验

| 角色性质 | 模型 | 理由 |
|---------|------|------|
| lead、架构师、裁决者、需求设计 | `opus` 或 `fable` + `high` | 判断错了整队白跑 |
| 实现者、写文档者 | `sonnet` | 性价比 |
| 只读审查、检索、格式化 | `haiku`，或自定义 `Explore` 覆盖成 `haiku` | 便宜；内置 `Explore` 会被封顶到 Opus，想省钱必须自己定义 |
| 交叉验证里的「第二意见」 | 与被验证者**不同**的模型 | 同模型同偏差，验不出东西 |

---

## §6 权限模式与继承规则

| 模式 | 行为 |
|------|------|
| `default`（别名 `manual`） | 手动模式，逐个提示 |
| `acceptEdits` | 自动接受文件编辑与常见文件操作 |
| `auto` | 由分类器判断工具调用是否放行；Pro/Max/Team 计划上主对话的默认起点 |
| `dontAsk` | 不提示（teammate 不继承这个模式） |
| `bypassPermissions` | 跳过权限确认 |
| `plan` | 只读规划，方案批准后才动手 |

继承规则（**很容易踩**）：

- 主对话处于 `bypassPermissions`、`acceptEdits` 或 `auto` 时，subagent **强制跟随主对话的模式**，你在 `permissionMode` 里写的值被忽略。`auto` 模式下分类器还会在 subagent 交付前复审它的工作和最终报告。
- 主对话处于 `default`、`dontAsk` 或 `plan` 时，subagent 用你写的 `permissionMode`——**但 `bypassPermissions` 除外**，声明了也会保持主对话的模式（该例外需 v2.1.267+）。
- teammate 继承 lead 的模式，`dontAsk` 除外；不能在 spawn 时按人指定，spawn 后可以单独改。

**实践建议**：想给只读审查者真正上锁，别只靠 `permissionMode`——用 `tools` / `disallowedTools` 把 `Write`、`Edit`、`Bash` 拿掉，或在 permission 设置里加 deny 规则。工具集是硬的，模式会被主对话覆盖。

---

## §7 subagent 拿不到的工具，以及它对提示词的影响

每个 subagent 都会被摘掉这些工具：

`AskUserQuestion`、`EnterPlanMode`、`ExitPlanMode`（除非它的 `permissionMode` 就是 `plan`）、`Workflow`、`TaskOutput`、`ScheduleWakeup`、`WaitForMcpServers`、`EndConversation`，以及在深度上限处的 `Agent`。后台运行的 subagent 还会再被裁掉一批内置工具。fork（`/subtask`）跳过这两层过滤，拿到主对话的完整工具集。

另外：主对话在 macOS / Linux / WSL 上默认没有 `Glob` 和 `Grep`，但 subagent 可以被单独授予它们。

**这些主会话状态永远不会传给非 fork 的 subagent**：output style（它跑自己的系统提示词）、auto memory、内置 agent 的预加载 skill。CLAUDE.md 里的规则默认会到（`Explore`/`Plan` 除外），但如果某条规则对这个角色至关重要——比如「忽略 `vendor/` 目录」「所有接口必须过 `xxx` 中间件」——**在派发提示词里重述一遍**，别赌它读到了。

**这四条推论直接决定提示词怎么写**：

1. **teammate 问不到用户。** 任何需要用户拍板的事，它只能回传给 lead。提示词里要明说：「不确定就回传 lead，不要替用户决定」——否则它会自己脑补一个答案继续跑，这是团队里最难发现的错误来源。
2. **teammate 不能开自己的 workflow，也不能在 in-process 下派后台 subagent。** 需要扇出的活儿由 lead 或脚本来扇。
3. **它看不到主对话历史。** 背景、约束、验收口径都得写进提示词，别指望它「知道我们刚才说的」。
4. **结果通过最后一条消息交付。** 让它把结论、证据、未决问题写成结构化的收尾消息，而不是散在中途的碎碎念里。

---

## §8 隔离：worktree 与文件冲突

- **agent team 不会自动给 teammate 开 worktree。** 这是团队里最常见的翻车点：两个人同时改一个文件，后写的覆盖前写的。
- 三种解法，按代价从低到高：
  1. **切分文件范围**——每个角色有明确的可写目录和禁区，写进提示词。共享文件（配置、类型定义、路由表、锁文件）由 lead 统一改。
  2. **`isolation: worktree`**——自定义 subagent 定义里加这个字段，它就在自己的 git worktree 里干活。
  3. **手动 worktree / `/batch`**——你自己开多个 checkout，或用 `/batch` 让 5–30 个 subagent 各自在 worktree 里做完并各开一个 PR。
- 契约类产物（接口定义、数据模型、事件格式）要**先冻结再并行**：由一个角色定稿，其他人只读引用，要改走 lead。

---

## §9 角色提示词写法

teammate 的上下文是空的，提示词就是它的全部世界。五条要点，每条都对应一种典型翻车：

1. **开头定角色与立场。** 「你是安全审查者，只报安全问题，不做风格评价」——不写立场，它会什么都管一点、什么都不深。
2. **给足背景。** 任务来源、相关模块、已有约束、验收口径。它读不到主对话，也（`Explore`）读不到 CLAUDE.md。
3. **划死文件范围。** 可写目录 + 禁区 + 谁负责禁区。这是防冲突的唯一有效手段。
4. **规定输出契约。** 固定字段、判定档位、引用格式（`文件:行号`）。要「结论 + 证据 + 建议改法」，不要「感觉这里可以再考虑一下」——无法执行的评审意见等于没有。
5. **写清协作与收尾。** 什么时候 `SendMessage` 通知谁；不确定就回传 lead；完成后把结构化结论作为最后一条消息发出。

模板见 `SKILL.md` 第 4 步。

**一个反复出现的反模式**：把「审查者」也给了写权限，理由是「顺手改一下更高效」。结果是几个审查者同时改同一批文件，冲突掩盖了真正的问题。审查者就该只读——发现问题、报告、由实现者统一改。

---

## §10 成本与缓存

- 每个 teammate 是独立会话，**各自烧 token**。官方建议 3–5 人起步；本 skill 的规模表按任务复杂度给到 2–8 人。
- in-process teammate 的请求落在主对话的缓存 TTL 桶之外，默认只缓存 5 分钟（订阅计划也一样）；把设置项 `subagentPromptCacheTtl` 设为 `1h` 可延长。注意 API 对 1 小时缓存写入按更高费率计费。
- 动态 workflow 的成本随 agent 数线性涨（上限 1000 个/次）；先用小样本（比如 10 个文件）验证脚本逻辑，再全量跑。
- 便宜的活儿别用贵模型：检索、格式化、定点查找给 `haiku`；判断、裁决、设计给 `opus`/`fable`。

---

## §11 来源

- Claude Code 文档 · Orchestrate teams of Claude Code sessions — `https://code.claude.com/docs/en/agent-teams`
- Claude Code 文档 · Create custom subagents — `https://code.claude.com/docs/en/sub-agents`
- Claude Code 文档 · Orchestrate subagents at scale with dynamic workflows — `https://code.claude.com/docs/en/workflows`
- Claude Code 文档 · Agents and parallel work — `https://code.claude.com/docs/en/agents`
- Claude Code 文档 · Tools reference（含 Task tool availability） — `https://code.claude.com/docs/en/tools-reference`
- Claude Code 文档 · Model configuration（模型别名与 effort 档位） — `https://code.claude.com/docs/en/model-config`
- anthropics/claude-code#76076 — 较新模型上 Task 工具被门控的实测报告
