# Phase 3 完工记录

- 日期：2026-09-27
- 提交：见 `git log`（91 patch + light-prune + smoke 口径修正）
- 验收契约：全量构建 + 打开产物 + 可观察断言

## 退出条件逐条证据

| 条件 | 证据 |
|---|---|
| 全量构建通过 | `./dev/run-build.sh -s` → BUILD EXIT: 0 |
| patch 无失败 | `grep -c "failed to apply patch" build.log` = 0；`find vscode -name '*.rej'` 为空 |
| light-prune 生效 | build.log L7598+：`light-prune: ../patches/light/prune.json` → Removed: extensions/vscode-test-resolver、extensions/tunnel-forwarding；`ls` 证实 `src/vs/server`、`cli/` 亦删除 |
| Remote Explorer 消失 | contrib/remote common+browser+electron 三处 import 摘除（91 patch）；schema 形 `"remote.*":{` 注册设置计数 = 0（产物 grep） |
| 产物无 `vslight tunnel` | bin/ 仅 vslight（Phase 1）；`vslight tunnel` → `'tunnel' command not supported in vslight`（可读报错，删键自然产生） |
| `vscode-remote://` 可读报错 | 文案 `Remote development is not supported in VSLight: no resolver for ...` 已入产物 `out/vs/workbench/api/node/extensionHostProcess.js`（grep 命中）；干净 profile 实开归入 Phase 7 |
| 残留入口检查 | smoke `--phase 3` schema 口径 = 0；命令面板/空白视图容器 UI 检查归入 Phase 7（本终端无完整 AX 权限，L3 层标注） |
| 应用可启动 | 干净 profile 启动：window1/renderer.log 有 `Render performance baseline`（窗口渲染完成）+ 本地扩展宿主启动，全程无 DI 错误；main.log 显示 `updates are disabled as there is no update URL`（DISABLE_UPDATE 生效） |
| smoke | `./dev/smoke.sh --skip-ui --phase 3` → EXIT 0（11/11 PASS） |

## 口径修正记录（重要）

- smoke 的前缀计数从「quoted-prefix」改为「schema 属性形 `"prefix.key":{`」：原口径把保留服务
  内部的使用串（`getValue('remote.restoreForwardedPorts')` 等 48 处）计入，与计划意图
  （默认设置/命令面板用户可见入口为 0）不符。注册设置已在摘除 contrib/remote 时归零；
  `mainThreadTunnelService` 的 3 处动态注册需 remote 环境存在才触发，本地永不命中。

## 文档与附带说明

- `00-remote-disable-client-validation.patch` 的校验放大效应：对 vslight 无意义 ——
  `src/vs/server` 整体不装机（light-prune），不存在可被放大的服务端。
- 市场安装 Remote-SSH/Dev Containers 类扩展的行为：迁移指引已写明「不可用 + 可读报错」。
- shared process 的 `RemoteTunnelService` 注册保留（自包含、无客户端、构造惰性）；
  `remoteExplorerService`/`remoteExtensionsScanner` 保留为 inert stub（DI 消费方在保留功能内）。
- 日志中仍见 `remoteTunnelService.log`/`tunnelHostService.log`：服务惰性初始化、无副作用，
  tunnelHost 属 chat 范畴（Phase 4 批次 6 处理）。
