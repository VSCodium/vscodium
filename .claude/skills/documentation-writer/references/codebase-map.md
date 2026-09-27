# 代码库说明（docs/codebase/ 成套文档）

在 `docs/codebase/` 下产出八份文档，覆盖在这个项目里高效工作需要知道的一切：技术栈、目录、架构、约定、功能、外部集成、测试、风险。它们是随查随用的参考，读者是日常改代码的工程师和 AI agent，所以每份都要短、结构固定、结论有出处。只写能从文件或命令输出里核实的东西，不推测。

和架构文档的区别：架构文档是一篇从头读到尾的解释；这里是八张按主题拆开的参考卡片。

## 目录

- [交付要求](#交付要求)
- [流程](#流程)
- [聚焦模式](#聚焦模式)
- [容易出错的地方](#容易出错的地方)
- [反例](#反例)

## 交付要求

结束前以下各条都要成立：

1. `docs/codebase/` 下正好有这八个文件：`STACK.md`、`STRUCTURE.md`、`ARCHITECTURE.md`、`FEATURES.md`、`CONVENTIONS.md`、`INTEGRATIONS.md`、`TESTING.md`、`CONCERNS.md`。文件名保持英文（方便工具和 agent 查找），标题和正文用文档语言。
2. 每条结论都能追到源文件、配置或命令输出。
3. 查不到的标 `[TODO]`；取决于团队意图的标 `[ASK USER]`。
4. 每份文档末尾有「依据」小节，列出具体文件路径。
5. 模板里的占位符（`[VALUE]`、`[FILE_PATH]`、`[path/to/...]` 这类）全部替换掉，不能留在成品里。
6. 交付回复里编号列出所有 `[ASK USER]` 问题，以及「文档意图与代码现实」的分歧。

范围是 monorepo 的一个子包时，文件放在该子包的 `docs/codebase/` 下，或者按用户指定的位置。

## 流程

照这个清单推进：

```
- [ ] 1. 扫描，读意图文档
- [ ] 2. 按主题调查
- [ ] 3. 按模板填写八份文档
- [ ] 4. 校验、修补、汇报
```

### 1. 扫描，读意图文档

1. 在目标目录跑扫描：

   ```bash
   python3 "$SKILL_DIR/scripts/scan.py" --output docs/codebase/.codebase-scan.txt
   ```

   扫描结果包括目录树、manifest、入口、lint 配置、环境变量模板、TODO / FIXME、近期提交、近 90 天高频改动文件、monorepo 信号、CI、容器、安全配置、性能测试标记、按语言的代码量。交付前删掉这个中间文件，或者提醒用户不要提交它。
2. 找 `PRD`、`TRD`、`README`、`ROADMAP`、`SPEC`、`DESIGN` 之类的文件读一遍。
3. 读源码之前，先用几句话总结这个项目**声称**要做什么。第 4 步要拿它和代码现实对比。

### 2. 按主题调查

用扫描结果回答每份文档的问题，八份文档各自的问题清单在 [inquiry-checkpoints.md](inquiry-checkpoints.md)。扫描答不了的，读源文件。技术栈不明确时读 [stack-detection.md](stack-detection.md)。

### 3. 按模板填写

把 `$SKILL_DIR/assets/templates/` 里的模板复制到 `docs/codebase/`，按这个顺序填（后面的会用到前面的结论）：

1. `STACK.md`：语言、运行时、框架、依赖、命令
2. `STRUCTURE.md`：目录、入口、模块边界
3. `ARCHITECTURE.md`：分层、模式、数据流
4. `FEATURES.md`：功能清单与关键功能的执行路径
5. `CONVENTIONS.md`：命名、格式、错误处理、导入
6. `INTEGRATIONS.md`：外部 API、数据库、鉴权、监控
7. `TESTING.md`：测试框架、文件组织、mock 策略
8. `CONCERNS.md`：技术债、缺陷、安全风险、性能瓶颈

模板标题是英文，按文档语言翻译。默认只填每个模板的「Core Sections (Required)」；「Extended Sections (Optional)」只在仓库复杂度确实需要时加。

`ARCHITECTURE.md` 里的数据流、`FEATURES.md` 里的关键功能路径适合配图，按 SKILL.md 的「出图」一节处理，图放在 `docs/codebase/diagrams/`。

### 4. 校验、修补、汇报

必须做完这个循环再交付：

1. 对照 inquiry-checkpoints.md 逐份检查。
2. 每条非显而易见的结论至少有一处依据。
3. 跑 `python3 "$SKILL_DIR/scripts/check_doc.py" docs/codebase/*.md --repo-root <仓库根>`，修掉不存在的路径和残留的占位符。
4. 有缺失的必填章节或没有依据的结论：修文档，再校验，直到八份都通过。

通过标准：没有无依据的结论；必填章节不空；不知道的用 `[TODO]` 而不是猜；团队意图的空白标 `[ASK USER]`。

然后给用户一份汇报：八份文档各一句话概要、编号的 `[ASK USER]` 问题、第 1 步总结的意图与代码现实之间的分歧。

## 聚焦模式

用户指定了重点（「只要架构」「测试和风险」）时：

1. 第 1 步照样完整做。
2. 先把重点文档写完整。
3. 其余文档保留必填章节结构，没调查的地方标 `[TODO]`。
4. 第 4 步的校验循环仍然覆盖全部八份。

## 容易出错的地方

- **monorepo**：根 `package.json` 可能没有源码。看 `workspaces`、`packages/`、`apps/`。每个 workspace 的依赖和约定可能各不相同，分开写。
- **README 过时**：README 常描述理想中的架构。当事实用之前先和目录结构对一下。
- **TypeScript 路径别名**：`tsconfig.json` 的 `paths` 让 `@/foo` 这种导入不对应真实目录，先映射再写结构。
- **生成产物**：不要从 `dist/`、`build/`、`generated/`、`.next/`、`out/`、`__pycache__/` 里总结约定。
- **`.env.example` 暴露了必需配置**：密钥不会提交，但模板文件会列出需要哪些环境变量。
- **`devDependencies` 不是生产栈**：只有 `dependencies`（或等价物，如 `[tool.poetry.dependencies]`）在生产环境运行。lint、格式化、测试框架单独写成开发工具。
- **测试里的 TODO 不是生产债**：`test/`、`tests/`、`__tests__/`、`spec/` 里的 TODO 是覆盖缺口，在 `CONCERNS.md` 里和生产代码的技术债分开列。
- **高频改动文件就是脆弱区**：近期提交里出现最多的文件，改动率高，往往藏着复杂度。一定写进 `CONCERNS.md`。

## 反例

| 不要这样 | 应该这样 |
|---|---|
| 「采用 Clean Architecture，分 Domain / Data 层」（实际没有这些目录） | 只写目录结构真实体现的东西 |
| 「这是一个 Next.js 项目」（没看 `package.json`） | 先查 `dependencies`，写实际有的 |
| 从 `dbUrl` 这个变量名猜数据库类型 | 在 manifest 里找 `pg`、`mysql2`、`mongoose`、`prisma` 等 |
| 把 `dist/` 里的命名方式写成项目约定 | 只看源文件 |
| 「功能包括用户管理、权限管理等」 | 在 `FEATURES.md` 里逐项列出，每项带入口和核心代码位置 |
