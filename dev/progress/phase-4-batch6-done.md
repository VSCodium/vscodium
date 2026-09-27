# Phase 4 批 6（97 Chat）完工记录 —— F-12 降级路径

## F-12 判据执行过程

1. **有界全删尝试**（97 v1：摘 common.main 7 处 + desktop.main 2 处 chat import）：
   typecheck 0 错误（编译面干净），全量构建一次后干净 profile 启动枚举运行时 DI 面。
2. **实测 DI 失败面**（一次启动日志）：
   - 保留面受损：`taskService depends on chatAgentService`（tasks 是决策 2 保留面）
   - 保留功能受损：`mcpAddContext→IContextPickService`、`mcpLanguageFeatures→chatWidgetService`、
     `browserViewWorkbenchService→chatWidgetService`、`emptyTextEditorHint`、issue reporter
   - api 层：`MainThreadChatSessions/ChatDebug/ChatContext/Browsers/LanguageModels/ChatSkills/Task`
     代理失败
   - 去重后 13+ 个相异失败服务；其构造注入闭包（如 ChatAgentService 的二级依赖）展开后
     **修复点 >20 处**，且需为每个服务手写 stub（其实现类静态 import 又把 chat UI 拉回产物）。
3. **结论**：触及 F-12 降级判据（>20 修复点 且 保留面受损）→ **降级为「隐藏入口」**。

## 降级方案

- chat 保持打包；`chat.disableAIFeatures` **上游默认已 true**（chat.shared.contribution.ts:2242，
  code-oss 无 Copilot 的默认）——视图/命令/菜单入口由 when 子句全部隐藏，无需额外改动。
- 仅摘除 `tunnelHost.contribution.js`（workbench 内无消费方，ITunnelHostService 消费方全在
  不打包的 src/vs/sessions）：**消除了此前每次启动的 `tunnelHost channel timed out` 报错**。
- `chat.*` 注册设置保留（10 个，设置页可见但无功能入口）——降级路径的明示偏差，已告知。

## 验收证据

| 断言 | 证据 |
|---|---|
| 全量构建通过 | BUILD EXIT: 0（全链从 pristine 重放，兼作 Phase 4 集成校验） |
| 启动零错误 | renderer.log error 计数 = 0（此前 tunnelHost 超时已消） |
| 入口隐藏 | `chat.disableAIFeatures` 默认 true（源码断言；UI 入口计数归 Phase 7） |
| smoke phase-4 | 16/16 PASS（chat 断言切换为 disableAIFeatures 默认 true） |

## Phase 4 总体账

| 批 | 项 | 装机 JS | 备注 |
|---|---|---|---|
| 基线（Phase 3 后） | — | 48.1MB | |
| 1 (92) | sessions/agentHost 入口 | 27.9MB (-20.2) | 核心目标达成：产物无 sessions/agentHost 入口 |
| 2 (93) | Debug 整体 | 27.6MB | `debug.*`=0；js-debug 不下载 |
| 3 (94) | Notebook | 26.9MB | `notebook.*`=0；ipynb/renderers 31M 源码资产不装机 |
| 4 (95) | testing/welcome/issue/profiles | 26.3MB | merge editor/speech/viewsWelcome 保留（理由见批次记录） |
| 5 (96) | policy-watcher | 26.3MB | postinstall 无 ERR；原生模块 -1 |
| 6 (97) | Chat F-12 降级 | 26.3MB | 入口隐藏；tunnelHost 噪音消除 |

**累计：48.1MB → 26.3MB（-45%），另省 reh ~370MB + tunnel 20MB + 扩展资产 ~31M。**
