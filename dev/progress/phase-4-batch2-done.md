# Phase 4 批 2（93 Debug）完工记录

- 提交：`93-light-remove-debug.patch`（含一次 stub 修正）
- 验收：全量构建 EXIT 0；patch 无失败；无 .rej

## 断言证据

| 断言 | 证据 |
|---|---|
| `debug.*` 注册设置为 0 | smoke schema 口径：21 → 0 |
| 构建不再下载 js-debug | 根 product.json `builtInExtensions=[]`（Phase 2）；build.log 中 js-debug 仅出现于 product.json 配置回显（proposal 白名单键名），无下载记录 |
| debug 内置扩展剪枝 | 产物 `app/extensions` 无 debug-auto-launch/debug-server-ready；dirs.ts 两条目已删（npm 目录同步） |
| 应用可启动 | renderer.log 有 Render performance baseline；残留唯一报错为已记录的 tunnelHost 超时（批 6 消除） |
| 装机 JS | 27.9MB → 27.6MB |

## stub 决策记录（同批 1 模式）

- 保留 `debug.service.contribution.js`（IDebugService 注册）：`MainThreadDebugService`（api，扩展宿主
  启动即实例化）、accessibilitySignals、mcpDevMode、viewQuickAccess 等保留功能均注入 IDebugService。
- 保留 `extensionHostDebugService.js`（desktop.main）：`DebugService` 构造依赖
  `IExtensionHostDebugService`，初版摘除导致全部 IDebugService 消费方启动报错（实测回归→修正）。
  其为服务层而非 UI，`debug.*` 设置仍随 debug.contribution 摘除归零。
- 结果：扩展调试 API 调用不崩溃（DebugService 可构造），但无任何调试 UI/命令/设置入口。
