# SPMS 需求落库速查

本文所有字段/枚举/写面缺口均核自 SPMS 平台实现,当**平台契约**用。文中偶尔出现的 `apps/spms-server/...` 这类源码路径是**门户仓内的核实出处记录**——装到外部 repo 后本 repo 里没有这些文件,不要去读、不要去找;拿不准的以运行中的 SPMS MCP 面实际行为为准。

## 1. PRD 各部分落到哪

| PRD 章节 | SPMS 落点 | 怎么写 |
| --- | --- | --- |
| §0 一句话 | `projects.summary`（概述） | `project_update`(FR-236);**整段覆盖,先 `project_get` 读现状** |
| §1.1 问题陈述与现状 | `projects.background`（背景） | 同上 |
| §2.2–2.3 用户与场景 | `projects.personas`（用户与场景） | 同上;§2.1 领域语言只留在 PRD 文档,不混入 `personas` |
| §1.2 目标 | `projects.goal`（目标） | 同上;**Web 端是列表编辑器,一行一条** |
| §1.3 非目标 | `projects.nonGoals`（非目标） | 同上;**一行一条**(去向写在同一行) |
| §4 约束与前提 | `projects.constraints`（约束与前提） | 同上 |
| §5.2 非阻塞开放问题 | `projects.openQuestions`（开放问题） | 同上;**一行一条**,格式 `Q1 [非阻塞] 问题;默认及理由;负责人;截止时间`;无则传 `null`;阻塞问题未解时不定稿/不回写项目 |
| §3 FR 条目 | `requirements`（`FR-N`) | `requirement_create` |
| §3 NFR 条目 | `requirements`（`NFR-N`,带 `category`) | `requirement_create` |
| 条目正文 | `requirements.description`（UI 标签「PRD 描述」) | 完整 markdown |
| 验收标准 | `requirements.acceptanceCriteria`（UI 标签「验收标准」) | **纯文本,一行一条** |
| TC 种子 | `test_cases`（`TC-N`) | `testcase_create(requirementKey=...)` |
| §7 分期交付建议 | **无独立字段** | 分期本身只留在 PRD 文档;**跨期需求的终验声明**要落进该需求的 `description` 开头 + `acceptanceCriteria` 逐行 `[P#]` 前缀(见 §5),版本(release)人工挂**终验期**那一版 |
| §8 SPMS 落库结果 | — | 记录本次真实写入的 key 与待人工补字段;有阻塞问题时改写「未写入」 |
| 开发计划(下游) | `plans`（`PLAN-N`)+ `plan_requirements` | dev-plan 阶段 `plan_create(requirementKeys)` / `plan_update({content})`。**PRD : 计划多对多**——可拆可合,关联键是 FR/NFR key;⚠️ **只能挂同项目的需求**,跨项目 key 报 `LIFECYCLE_MISMATCH`(平台契约) |

## 2. 枚举真值

| 字段 | 取值 | 中文标签 |
| --- | --- | --- |
| `type` | `functional` / `non_functional` | 功能性 / 非功能性 |
| `category`（**仅 NFR**,FR 留 null） | `performance` / `security` / `usability` / `reliability` / `compatibility` / `maintainability` | 性能 / 安全 / 易用性 / 可靠性 / 兼容性 / 可维护性 |
| `status`（8 值） | `draft` → `reviewing` → `approved` → `in_dev` → `submitted` → `testable` → `shipped`,或 `rejected` | 草稿 / 评审中 / 已批准 / 开发中 / **已提交** / **可测试** / **已上线** / 已拒绝 |
| `priority`（紧急度） | `urgent` / `high` / `medium` / `low` / `none` | 紧急 / 高 / 中 / 低 / 无 |
| `importance`（重要度,**与 priority 正交**） | `critical` / `high` / `medium` / `low` / `none` | 关键 / 高 / 中 / 低 / 未评估 |
| TC `status` | `draft` / `active` / `deprecated` | 草稿 / 可用 / 废弃 |
| TC `result` | `untested` / `passed` / `failed` / `blocked` | 未测 / 通过 / 失败 / 阻塞 |

**PRD 阶段一律建 `status=draft`**;`reviewing`/`approved` 是人的动作。

⚠️ **`shipped`(已上线)就是需求侧的终点** —— 需求**没有**「已上线」之后的第二个人工终态(与 Issue 的不对称是平台刻意的),把需求转到它**本身就是那次需求级验收**,而且会通知需求作者。`submitted`(已提交) / `testable`(可测试) 是「交付中」段,跨期需求的首期完工应停在这里。Agent 写不到两个终态(`shipped` / `rejected` → `FINAL_STATE_FORBIDDEN`),所以**防误记只能靠把终验期写进需求正文**,让点按钮的人先看见。

## 3. MCP 写面

`requirement_create` / `requirement_update` 的 inputSchema:
`projectId` · `title` · `type` · `category` · `priority` · `importance` · `status` · `description` · `acceptanceCriteria` · `ownerId` · `dueDate`(update 用 `key` 寻址)。

**这三个曾经写不到、现在可以写**——不要再把它们列进「待人工补」:

| 字段 | 写法 | 备注 |
| --- | --- | --- |
| `importance` 重要度 | `critical\|high\|medium\|low\|none` | 与 `priority`(紧急度)**正交**,两个都该给 |
| `ownerId` 负责人 | `project_get` 成员名册的 `memberId`;`null` 清除 | 只收本租户未撤销成员,否则 `VALIDATION_FAILED`。与「执行人」(由关联 Issue 派生)不是一回事 |
| `dueDate` 截止日期 | ISO 8601(如 `2026-07-15`);`null` 或空串清除 | 格式不对是 `VALIDATION_FAILED`。需求池按日期范围筛选用 |

**仍然写不到的字段**——交付时单列一张「待人工补」清单:

| 字段 | UI 位置 | 备注 |
| --- | --- | --- |
| `releaseId` 版本 | 需求抽屉 | 单值字段,应与项目的 release 一致否则 UI 出告警;**跨期需求挂「终验期」那一版**——挂首期会让版本报表提前把整条需求算成已交付 |
| 附件 | 需求抽屉 | MCP 只能读(`attachment_read`),不能传 |
| 排期/点数 | Sprint 规划页 | 属规划期(`sprint_plan_items`),**不在 PRD 阶段做** |
| 项目治理字段(名称/状态/负责人/团队/版本) | 项目抽屉 | `project_update` 只写基本信息七段;**无 `project_create`** |

## 4. key 分配规则(建之前必须知道)

- `FR-N` / `NFR-N` / `TC-N` 都是**租户级**序列(不是项目级)——编号跨项目连续,别指望 `FR-1` 是本项目第一条。
- 前缀在**创建时**按 `type` 决定;**之后改 `type`,key 不会重写**(与 issue key 契约一致)。→ **建之前把 FR/NFR 判定定死**,建完再改类型就是永久错配。
- key 创建后才知道 → PRD 草稿的 `R1..Rn` 是原始诉求追踪号,创建前也暂作工作号。**建完立刻回填真实 key**;之后凡是指代需求实体/标题都用 FR/NFR key,`R#` 只留在「承接」与原始诉求追踪表。
- `*_create` **不幂等**:重复调用 = 重复需求 + 烧掉 key。建之前 `pms_search` + `requirement_list` 查重,写库前把清单摊给用户确认。

## 5. 正文与验收标准的物理格式

**`description`(PRD 描述)** —— markdown 全量渲染(平台统一的 markdown 渲染组件),标题/列表/**表格**/代码块都可用。
图片只认 `![name](xgent-attachment:<id>)` 稳定引用,而 MCP 没有上传面 → **正文里不要放外链图**。

**`acceptanceCriteria`(验收标准)** —— **不是 markdown**。展示端按 `\n` 切行、trim、丢空行,渲染成圆点列表,**一个字符都不剥**。
⚠️ 剥列表前缀(`- * • 1. 1)` + 后随空白)只发生在 **Web 列表编辑器保存**那条路径上,**MCP 写进去的不经过它** —— 所以你写的任何前缀都会原样显示在界面上:

```
✅ 管理员在「应用市场」点击安装后，应用 3 秒内出现在左侧导航
✅ 非管理员访问该入口返回 403，且导航不显示该项
✅ 已安装应用重复安装时提示「已安装」，不产生第二条记录

❌ - 管理员可以安装应用        → 行首 "-" 会原样显示成「• - 管理员…」
❌ 1. 管理员可以安装应用        → 同样原样显示（展示端不剥数字前缀）
❌ **重要**：安装要快          → 加粗语法原样显示，且「快」不可断言
❌ （空行分段）                → 空行被丢弃，分段无效
```

一行一条、无前缀符号、无空行、无 markdown 语法、每条可断言。

### 唯一允许的前缀:跨期需求的 `[P#]` 期次标

跨期需求(验收标准分散在两期以上)**逐行**加期次前缀,让 QA 一眼看出这期该验哪几行:

```
✅ [P1] 管理员在「应用市场」点击安装后，应用 3 秒内出现在左侧导航
✅ [P2] 非管理员访问该入口返回 403，且导航不显示该项
```

方括号**不在**剥离表(`- * • 1. 1)`)里,展示端本来也不剥 —— 所以这是**唯一不破坏「纯文本一行一条」契约**的标法。
**单期需求不要加**,加了就是噪声。配套的两处见 §5.1。

### 5.1 跨期需求的终验声明(防「阶段交付被误记为整条完成」)

一条需求跨两期交付时,**整条需求算完成的那一期叫「终验期」= 最后一期**。三处一起写,缺一处就会有界面在说谎:

1. **`description` 开头**一段引用块(正文是 markdown,正常渲染):

   ```
   > **分期与终验**:本需求跨 P1 / P2 交付,**终验期 = P2**。P1 完成后请停在交付段(已提交 / 可测试),**不要转「已上线」**——「已上线」是整条需求的验收,不是某一期的完工。
   ```

2. **`acceptanceCriteria` 逐行 `[P#]` 前缀**(上一节)。
3. **版本(release)挂终验期那一版**(人工在 Web 补,见 §3)。

⚠️ **平台行为**:需求抽屉里,只要**该需求已关联的 Issue 全部完成**、且状态落在交付段(开发中 / 已提交 / 可测试),就会浮出一条一键「转已上线」的绿色提示条。跨期需求首期只挂了首期的 Issue,**首期一完工按钮就亮了** —— 这就是误记发生的方式,而需求侧没有「已上线」之后的第二个终态(见 §2)。Agent 写不到终态,**能做的就是把终验声明写在他会看到的地方**。

## 6. 常用调用序列

```
project_list()                              → 拿 projectId（令牌白名单内）
project_get(projectId)                      → 成员/迭代/计数/基本信息七段(summary,background,personas,
                                              goal,nonGoals,constraints,openQuestions)
project_update({projectId, summary, …})     → 回写基本信息七段(整段覆盖，先读后写；null 清空)
requirement_list(projectId)                 → 看已有需求，校准粒度 + 查重
pms_search(keyword)                         → 跨需求/Issue/TC 查重（上限 50 条，用具体词）
requirement_get('FR-18')                    → 读某条全量（含验收标准/关联 Issue/附件）

--- 用户确认后 ---
requirement_create({projectId, title, type, category?, priority, status:'draft',
                    description, acceptanceCriteria})   → 返回体里拿真实 key
testcase_create({projectId, title, requirementKey:'FR-37', preconditions?, steps, expected,
                 priority?, status:'draft'})            → TC-N，result 默认 untested
```

## 7. 错误码与闸(照实报,别绕道)

| 现象 | 含义 | 怎么办 |
| --- | --- | --- |
| `CAPABILITY_REQUIRED` | 令牌没有 `write` 能力 | 让用户在 SPMS「设置 → Agent 接入」重签带 write 的令牌(能力是签发时定死的,改不了) |
| `PROJECT_NOT_ALLOWED` | 目标项目不在令牌白名单 | 白名单**可就地改签**(令牌列表页「项目」单元格),不必吊销重签 |
| `PROJECT_NOT_FOUND` / `REQUIREMENT_NOT_FOUND` | 不存在,或跨租户(不泄露存在性) | 核对 projectId / key |
| 403（需求写闸） | 需要 `spms:action:requirement.manage` **或**本项目 Lead | 报出缺什么,请用户授权;不要改去建 Issue 绕行 |
| `FINAL_STATE_FORBIDDEN` | 想把需求写到 `shipped` / `rejected` —— 终态留给人 | 别绕道。要报的是「首期已交付,需求停在交付段,终验在 P2」,由人做需求级验收 |
| `VALIDATION_FAILED` | 标题为空等 | 修入参 |
| `429` / `503` | 令牌 rpm 超限 / 门户不可达(fail-closed) | 退避重试;503 时门户侧先恢复 |

> 需求状态变更会通知需求作者 —— 别为了「整理」批量翻状态,会刷屏。
