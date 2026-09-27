# Phase 4 批 3（94 Notebook）完工记录

- 提交：`94-light-remove-notebook.patch`（三次修正迭代）
- 验收：全量构建 EXIT 0；patch 无失败；无 .rej

## 断言证据

| 断言 | 证据 |
|---|---|
| `notebook.*` 注册设置为 0 | smoke schema 口径：1 → 0（cellEditorOptions 的 lineNumbers 注册已摘） |
| ipynb/notebook-renderers 剪枝 | 产物 app/extensions 无二者；dirs.ts 两条目已删 |
| 构建不再引用剪枝扩展 | gulpfile.extensions.ts tsconfig 清单、lib/extensions.ts esbuildMediaScripts 已同步（否则 extension media 构建崩溃，实测） |
| 应用可启动 | renderer.log Render performance baseline=1；无 MainThreadInteractive/MainThreadNotebook DI 错误 |
| 装机 JS | 27.6MB → 26.9MB（另有 ipynb 4.7M + notebook-renderers 27M 源码资产不装机） |

## 迭代教训（沉淀为批 6 检查单）

1. **buildfile 导出项有模块级消费方**：`build/lib/mangle/index.ts` 在模块加载即对
   `buildfile.worker*.name` 求值，且所有 gulpfile 经 glob 全量加载 → 删 entry 必须同步删
   gulpfile.vscode/.web/reh + mangle 四处引用（首次构建因此失败）。
2. **扩展构建清单独立于 dirs.ts**：`gulpfile.extensions.ts`（tsconfig）与
   `lib/extensions.ts`（esbuildMediaScripts）另有两份清单，剪枝扩展须三处同步。
3. **服务注册内嵌 UI contribution 的处理**：notebook 14 个服务注册在 contribution 里 →
   新建 `notebook.service.contribution.ts` 仅含 registerSingleton（UI 不进产物，API 层 DI 不断）。
4. api 层惰性主线程服务（MainThreadInteractive）会注入被摘 contribution 注册的服务 →
   同文件补 interactive 两个服务注册。
