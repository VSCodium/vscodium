# Phase 3 开工记录

- 日期：2026-09-27
- git 快照点：`4df87ec`（Phase 1+2 完工）
- 计划版本 sha256：`a2d036ed1a5c50c70f8222ab6c03a14466a06397cabca90ca6b99c1899d32c27`
- 前置产物：`dev/progress/audit-remove-patch.md`（remove∩patch 审计表）已落盘

## 本阶段动作

1. `patches/91-light-remove-remote.patch`（基于全量 patch 后的工作树生成，helper commit `188022c3`）：
   - 摘 `workbench.common.main.ts`：contrib/remote common+browser、remoteCodingAgents
   - 摘 `workbench.desktop.main.ts`：sharedProcessTunnelService、remoteTunnelService、
     contrib/remote electron、contrib/remoteTunnel electron；tunnelService 换 browser no-op stub
   - 摘 `code/electron-main/main.ts`：ITunnelService/TunnelService(node) 注册（主进程无消费方，已核实）
   - `server-main.ts`/`server-cli.ts` → 可读报错 stub（退出码 1）
   - `extHostExtensionService.ts` resolver 报错文案 → `Remote development is not supported in !!APP_NAME!!`
   - `build/npm/dirs.ts`：删 tunnel-forwarding/test-resolver/remote/remote/web 条目
2. `patches/light/prune.json` + `prepare_vscode.sh` light-prune 阶段（所有 patch 之后）：
   删 `extensions/vscode-test-resolver`、`extensions/tunnel-forwarding`、`src/vs/server`、`cli/`
3. **保留的 inert stub**（DI 消费方在保留功能内）：`remoteExplorerService`、
   `remoteExtensionsScanner`、`sharedProcessMain` 内 tunnel 注册（自包含、无客户端）
4. 文档：`docs/vslight-migration.md` 已含远程扩展不可用与深链失效说明；
   `00-remote-disable-client-validation.patch` 的放大效应对 vslight 无意义（server 整体不装机），
   在完工记录中注明。

## DI 核实记录

- `IRemoteExtensionsScannerService` 被保留的扩展核心服务注入 → 保留注册（本地无 remoteAuthority 时惰性）
- `RemoteExplorerService` 构造无副作用（TunnelModel + 扩展点 handler）→ 保留注册
- `IRemoteTunnelService` 渲染端无其他消费方 → 摘除注册
- 主进程无 `@ITunnelService` 注入 → 摘除注册
- `app.ts` 无 tunnel/remote 服务注册；vscode-remote URI 解析保留（走向可读报错路径）
- `tunnelApplicationName` 已删键：仅 tunnelProcessCoordinator 启动隧道时读取，undefined 有类型防护
