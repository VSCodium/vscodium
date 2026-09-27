# Phase 4 批 1（92 sessions/agentHost）完工记录

- 提交：`92-light-remove-sessions.patch`（含一次 stub 修正）
- 验收：全量构建 EXIT 0；`failed to apply patch`=0；无 .rej

## 断言证据

| 断言 | 证据 |
|---|---|
| 产物无 sessions.desktop.main.js | `find out -name sessions.desktop.main.js` 空 |
| 产物无 agentHostMain(+/diffWorkerMain).js | 同上，空 |
| 装机 JS 字节 | 48.1MB → **27.9MB（-20.2MB / -42%）**（批 1 前后 `find out -name '*.js'` 字节和） |
| 应用可启动 | 干净 profile renderer.log 有 `Render performance baseline`；agentHostChatDebug/codexAccountService DI 错误已通过「保留 agentHostService/remoteAgentHostService 渲染端 stub」消除 |
| dirs.ts 检查 | 本批无剪枝，dirs.ts 无变化 |

## 决策与偏差记录

1. **目录剪枝延后至批 6**：chat 源码（`contrib/chat/*`）仍 import `vs/sessions` 与
   `platform/agentHost` 模块；批 1 只做 bundle 入口级摘除（计划核心目标：产物无 sessions/agentHost
   入口，体量收益 20.2MB 已兑现）。`src/vs/sessions`、`src/vs/platform/agentHost` 整目录剪枝
   并入批 6（审计表 §2 批次 1 行已据此修正）。
2. **渲染端 agentHost 服务保留为 inert stub**：chat 的 agentHostChatDebug、codexAccountService
   注入 `agentHostService`/`remoteAgentHostService`，批 1 全删会导致 workbench 组合栏渲染崩溃
   （实测）。仅 `agentHostEnablementService` 摘除。批 6 随 chat 一并移除。
3. **已知无害报错**：`Channel name 'tunnelHost' timed out after 1000ms`（chat 的
   tunnelHost.contribution 连已移除的 shared-process 通道；1s 超时、不阻塞启动、不崩溃），
   批 6 摘除该 contribution 后消失。
4. 窗口创建点：`windowsMainService.isSessionsWindow` 恒 false + windowImpl 只载 workbench.html；
   main 进程 `ElectronAgentHostStarter`/`AgentHostProcessManager` 已除；shared process 的
   SSH/WSL/Tunnel agent host 服务与通道已除。
