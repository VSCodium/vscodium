---
name: documentation-writer
description: 基于代码事实写和更新技术文档：README、API 文档（HTTP 接口 / OpenAPI / 库与 SDK 参考）、架构文档、代码库说明文档（docs/codebase/ 成套）、用户手册与操作指南。每条结论都能追到仓库里的文件，文字去 AI 味；需要架构图、流程图、时序图时，本地装了 archify skill 就优先用它出图，没有再用 Mermaid。凡用户要求写或更新 README、补接口文档、生成 OpenAPI、写架构文档、画系统架构、梳理仓库、写新人上手文档、写用户手册 / 使用说明 / 教程，或改完代码要同步文档，都用本 skill，即使用户没说「文档」二字。Use for READMEs, API/OpenAPI/SDK reference, architecture docs, codebase onboarding docs, user manuals, tutorials and how-to guides, or syncing docs after code changes.
---

# documentation-writer · 基于代码事实的技术文档

**路径约定**：`references/`、`scripts/`、`assets/` 都相对于本 `SKILL.md` 所在目录。运行脚本前先设 `SKILL_DIR="<本 SKILL.md 所在目录>"`；文档路径、仓库根等参数按目标仓填写。

这份 skill 要的文档有三个特点：说的都是仓库里真实存在的东西；读者拿到就能用（命令能跑、例子能抄、图能看懂）；读起来像熟悉这套代码的工程师写的，不像模型生成的。三者冲突时，准确优先。

## 选文档类型

| 用户要的 | 读者 | 先读 | 默认位置（仓库已有约定时从约定） |
|---|---|---|---|
| README：新建、补全、按代码变更同步 | 第一次接触项目的人 | [references/readme.md](references/readme.md) | 仓库根或子包根的 `README.md` |
| API 文档：HTTP 接口、OpenAPI、库 / SDK 参考 | 调用方开发者 | [references/api-docs.md](references/api-docs.md) | `docs/api/` 或服务目录下 `docs/` |
| 架构文档：系统怎么搭起来、为什么这样搭 | 新加入的工程师、评审者 | [references/architecture.md](references/architecture.md) | `docs/architecture.md` 或 `ARCHITECTURE.md` |
| 代码库说明：成套的结构、约定、功能、测试、风险文档 | 日常改代码的人和 AI agent | [references/codebase-map.md](references/codebase-map.md) | `docs/codebase/` |
| 用户手册、教程、操作指南、运维手册 | 最终用户、运营、运维 | [references/user-manual.md](references/user-manual.md) | `docs/user-guide/` 或 `docs/manual/` |

架构文档和代码库说明容易混。用户要**一份**能从头读到尾的「系统是怎么工作的」，走架构文档；要一**套**放在仓库里、按主题随查随用的参考（技术栈、目录、约定、功能清单、测试、风险），或者明确说「代码库说明 / 功能说明 / map this codebase」，走代码库说明。拿不准时问一句，问不了就写架构文档，并在交付说明里提一句另一种选择。

一个请求涉及多类文档（比如「给这个服务写 README 和接口文档」），按类型分别读对应参考，各写各的，互相链接，不要把 API 参考塞进 README。

**不归本 skill 管**：只改代码注释或 docstring、写 commit message、写 PRD（用 prd skill）、写开发计划（用 dev-plan skill）、制定迁移或现代化方案。

## 通用流程

每类文档都走这六步，差别在参考文件里。

### 1. 定读者、目的和范围

先弄清三件事：谁读、读完要能做什么、覆盖哪些不覆盖哪些。按 [Diátaxis](https://diataxis.fr/) 分清这份文档属于哪一类，四类写法不同，不要混在一起：

- **教程**：带新手完整做成一件事，一步一个结果，不讲原理。
- **操作指南**：解决一个具体问题，假设读者已经会基本操作。
- **参考**：准确、完整、结构统一，像字典，不讲故事。
- **解释**：讲清楚为什么这样设计、有哪些取舍。

能从请求和仓库推断出来的，不要问。真正缺的信息一次问完。新写大文档（架构文档、用户手册、代码库说明）时，先把大纲给用户看：章节、每节一句话、打算画哪几张图，确认后再写。用户已经给了结构、说了「直接写」，或者当前环境没法提问，就把假设写进交付说明，直接写。

输出语言：目标仓已有文档用什么语言就用什么语言；仓库没有文档时用对话的语言。目标仓的 `AGENTS.md` / `CLAUDE.md` / `CONTRIBUTING.md` 里有文档约定（位置、格式、术语）的，照约定来。

### 2. 摸清事实（本地优先）

文档描述的是**眼前这份代码**，所以事实从本地 checkout 里取，不从记忆、网络或远端仓库取。

1. **锚定快照**：`git remote -v`、`git branch --show-current`、`git log -1 --format='%h %ad %s' --date=short`。架构文档和代码库说明要把这三项写进文档，读者才知道描述的是哪个版本。remote URL 里如果带了凭据（`https://<token>@host/...`），写进文档前删掉。
2. **读真实的清单文件**：`package.json`、`go.mod`、`pyproject.toml`、`Cargo.toml`、`pom.xml` 这类 manifest，`Makefile` 或其他任务脚本，CI 配置，`.env.example`，已有的 `README` / `docs/`。技术栈和命令以这些文件为准，不以你对框架的印象为准。栈不明确时读 [references/stack-detection.md](references/stack-detection.md)。
3. **仓库大或者陌生时先扫一遍**：在目标目录下跑

   ```bash
   python3 "$SKILL_DIR/scripts/scan.py" --output /tmp/codebase-scan.txt
   ```

   会输出目录树、manifest、入口、lint 配置、环境变量模板、TODO、近期提交、高频改动文件、CI、容器、代码量。monorepo 里只写一个子包时，在子包目录里跑。扫描结果是线索，结论仍要回到源文件确认。
4. **已有文档是意图，不是事实**。README 常常写的是「打算怎么做」。和代码对不上时以代码为准，把分歧记下来，交付时告诉用户。
5. **只写源码，不写产物**。`dist/`、`build/`、`generated/`、`.next/`、`__pycache__/`、`node_modules/` 里的东西不当作项目约定。

找不到答案的，网络查询是最后手段，只在事实确实影响文档、又无法从本地确定时用，而且要标 `[UNVERIFIED]` 说明来源。

### 3. 写

按对应参考文件的结构写。贯穿所有类型的规矩见下文「证据纪律」和「写作风格」。

### 4. 出图

见下文「出图：archify 优先，Mermaid 兜底」。

### 5. 自检

写完先跑检查脚本，它会核对文中引用的路径是否存在、行号是否越界，扫出凭据、没填的模板占位、AI 腔词汇和破折号密度：

```bash
python3 "$SKILL_DIR/scripts/check_doc.py" <文档路径...> --repo-root <仓库根>
```

脚本报「路径不存在」的逐条修掉；报 AI 腔的逐条看，确属术语或引用原文的可以保留。然后人工过一遍：

- [ ] 写到的命令都在 manifest / 任务脚本 / CI 里出现过；没亲自跑过、又有疑问的，标出来
- [ ] 例子里的字段名、取值形状来自 schema、测试或 seed，不是编的；密钥、token 用占位符
- [ ] 数量写具体数字（「13 个路由文件」），不写「很多」
- [ ] 不确定的地方都打了标记
- [ ] 图的文件存在，链接能点开
- [ ] 按 [references/writing-style.md](references/writing-style.md) 的清单去一遍 AI 腔

### 6. 交付说明

回复用户时说清：

- 新建或改动了哪些文件（路径）
- 图用了 archify 还是 Mermaid；用 archify 的，列出每张图的 HTML 路径、`deliver` 结果和 `visual-check` 状态（通过 / 失败 / 跳过），不要把没做过的检查说成做过
- 所有 `[ASK USER]` 问题，编号列出
- 文档和代码对不上的地方（README 说 A，代码是 B）
- 写作时做的假设

## 证据纪律

文档的价值在于读者可以直接信，不用自己再核一遍。所以：

- **非显而易见的结论都要有出处**。架构文档、代码库说明、API 文档里，用相对仓库根的路径加行号引用：`apps/api/src/index.ts:42` 或 `src/routes/users.ts#L10-L35`。引用了哪一行，就要真的读过那一行。README 和用户手册面向的读者不看源码，正文不放行号引用，但写之前同样要核实。
- **统一用这四个标记**，含义不同，不要混用：

  | 标记 | 用在 |
  |---|---|
  | `[INFERRED]` | 从代码推理出来的，但没有哪里直接写明 |
  | `[UNVERIFIED]` | 转述了别处的说法，自己没核实（例如文档里写的构建耗时、CI 是否是必需检查） |
  | `[TODO]` | 仓库里查不到，需要后续补 |
  | `[ASK USER]` | 取决于团队意图，只有人能回答 |

  标记用英文原样，中文文档也一样，方便 grep。
- **矛盾要裁定，不要转述**。两个来源说法不同（manifest 写的版本和代码里的常量不一致），去读代码，给出结论，并写一句「已核对：X 写的是 A，实际生效的是 B，因为……」。
- **能数就数**。「共 73 个 service 包」读起来是核实过的，「有很多服务」读起来是猜的。
- **诚实的空白比虚假的完整有用**。写不出来的部分标 `[TODO]`，不要用泛泛之词填满。

## 出图：archify 优先，Mermaid 兜底

### 先想清楚要不要画

图用来表达文字说不清的东西：组件之间怎么连、请求怎么穿过系统、状态怎么流转。三步以内的线性流程，用一句话或编号列表就够了。一份文档通常一到四张图，每张图正文里要有一句话说明它在讲什么、读者该看哪里。

### 探测 archify

按顺序判断，命中即停：

1. 当前环境的可用 skill 列表里有 `archify`：可用。在 Claude Code 里用 Skill 工具加载它。
2. 否则跑探测脚本：

   ```bash
   bash "$SKILL_DIR/scripts/find-archify.sh"
   ```

   它在本 skill 的同级目录、项目和用户级的 `.claude/skills`、`.agents/skills`、`.codex/skills`、`.cursor/skills` 以及 Claude Code 插件缓存里找 `archify/SKILL.md`，同时检查 `node` 是否可用。退出码 0 表示可用，并打印 archify 目录；读那个目录下的 `SKILL.md`，按它的流程出图。
3. 都没有：用 Mermaid。

### 用 archify 出图

怎么写 JSON、怎么校验、怎么修布局，全按 archify 自己的 `SKILL.md` 来，这里不复述。本 skill 只约定和文档衔接的部分：

**类型对应**

| 文档里的图 | archify 类型 |
|---|---|
| 系统上下文图、容器图、部署拓扑、模块依赖 | `architecture` |
| 请求链路、接口调用时序、鉴权 / token 交换握手 | `sequence` |
| 业务流程、审批流、CI/CD、操作步骤 | `workflow` |
| 数据管道、ETL、数据血缘、事件流 | `dataflow` |
| 状态机、订单或任务的状态流转、重试与终态 | `lifecycle` |

**文件放在哪**：在文档所在目录下建 `diagrams/`，源文件和产物同名：`docs/diagrams/system-context.json` 和 `docs/diagrams/system-context.html`。源 JSON 要留着，以后改图从它改。

**图里的文字**和文档同语言，中文文档设 `meta.locale: "zh-CN"`。节点名、接口路径、命令等标识符保持原样。

**在 Markdown 里怎么放**：先跑 archify 的 `deliver`，再跑 `visual-check`（需要本机有 Chrome / Chromium）。`visual-check` 成功时会在 HTML 旁边留下截图 `<名字>.visual-check.1440x900.light.png`，把它嵌进正文，下面给出交互版链接：

```markdown
![系统上下文图](diagrams/system-context.visual-check.1440x900.light.png)

交互版：[diagrams/system-context.html](diagrams/system-context.html)，用浏览器打开，可缩放、搜索、追踪调用链。
```

`visual-check` 失败或被跳过时，只放交互版链接，并在交付说明里写明截图没有生成。同一张图不再另画一份 Mermaid，两份会各改各的，最后对不上。

**只留三个文件**：每张图在仓库里保留 `<名字>.json`（源）、`<名字>.html`（交互版）和正文嵌入的 `<名字>.visual-check.1440x900.light.png`。`visual-check` 另外生成的深色和 2048 尺寸截图、`<名字>.visual-check.html` 汇总页、`<名字>.visual-check.json` 回执都是检查证据，把检查结果写进交付说明后删掉，不然一张图会在 `diagrams/` 里留下八个文件。

**修不好就退回**：某张图按 archify 的修复流程连续两轮没有改善，这一张改用 Mermaid，交付说明里写清楚原因和 archify 的报错。

### 用 Mermaid 出图

- 类型：结构用 `flowchart`，时序用 `sequenceDiagram`，状态用 `stateDiagram-v2`。
- 一张图不超过 12 个节点，超了就拆成两张，或者只画主干。
- 节点标签用读者认识的名字（服务名、模块名），不用内部变量名。
- 在紧挨着图的正文里写一句这张图在说什么。
- 交付说明里提一句：装了 archify 可以得到可交互、可导出的图（仓库地址 `https://github.com/tt-a1i/archify`）。只提一次，不要反复推销。

## 写作风格

技术文档去 AI 味，靠的是具体、直接、可核对，不靠加个性。完整清单和中英文例子在 [references/writing-style.md](references/writing-style.md)，写完对照检查。最常见的几条：

- **开头直接说是什么、给谁用、能做什么**。不写「在当今……的背景下」「随着……的快速发展」。
- **删空话**：赋能、助力、打造、一站式、全方位、无缝、强大的、极致、深度融合、值得注意的是、综上所述；英文的 delve、leverage、seamless、robust、comprehensive、cutting-edge。删掉之后句子不成立，说明原来就没有内容，换成具体事实（数字、名称、行为）。
- **不给标题和列表加 emoji**，不写「**性能：** 性能得到提升」这种加粗小标题列表。参考类文档里「**术语**：定义」的格式是正常的，可以用。
- **术语前后一致**。同一个东西第一次叫「租户」，后面就一直叫「租户」，不要换成「组织」「空间」「团队」轮着用。
- **不写总结、展望式结尾**。文档讲完就停。
- **参考文档保持中性**，不加第一人称和观点。教程和 README 可以用「你」直接跟读者说话，可以写真实踩过的坑（「第一次跑 `db:migrate` 会失败，因为 Redis 还没起」），这是技术文档里合适的「人味」。
- **更新已有文档时沿用它的风格**：标题层级、术语、emoji 习惯、中英文混排方式都照旧，只保证你新增和改动的部分没有 AI 腔。

## 更新已有文档

用户说「同步一下文档」「README 过时了」「接口改了，更新文档」时：

1. 先通读现有文档，再看代码变更（`git diff`、`git log -p -- <路径>`，或用户描述的改动）。
2. 列出文档里和现状不符的地方，逐条对应到要改的段落。代码变更和文档章节的对应关系见 [references/readme.md](references/readme.md) 的「变更映射」。
3. 只改需要改的段落，结构、语气、格式保持不变。不借机重写整篇。
4. 删掉已经不存在的功能、参数、命令，不要只加不减。
5. 交付说明里列出改了哪几处、为什么。

## 参考文件索引

| 文件 | 什么时候读 |
|---|---|
| [references/readme.md](references/readme.md) | 写或更新 README |
| [references/api-docs.md](references/api-docs.md) | 写 HTTP 接口文档、OpenAPI、库 / SDK 参考 |
| [references/architecture.md](references/architecture.md) | 写架构文档、系统设计说明 |
| [references/codebase-map.md](references/codebase-map.md) | 写 `docs/codebase/` 成套说明 |
| [references/inquiry-checkpoints.md](references/inquiry-checkpoints.md) | 写代码库说明时，每份文档要回答的问题 |
| [references/user-manual.md](references/user-manual.md) | 写用户手册、教程、操作指南、运维手册 |
| [references/writing-style.md](references/writing-style.md) | 每次交付前，去 AI 味 |
| [references/stack-detection.md](references/stack-detection.md) | 技术栈不明确、多种 manifest 并存时 |
| `assets/templates/*.md` | 代码库说明的八份模板 |
| `scripts/scan.py` | 大仓或陌生仓，动笔前扫描 |
| `scripts/find-archify.sh` | 出图前探测 archify |
| `scripts/check_doc.py` | 交付前自检 |
