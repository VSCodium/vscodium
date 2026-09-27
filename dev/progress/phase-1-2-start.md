# Phase 1+2 开工记录（补记）

- 日期：2026-09-27
- git 快照点：`c523d5b`（Phase 0 完工提交）
- 计划版本 sha256：`a2d036ed1a5c50c70f8222ab6c03a14466a06397cabca90ca6b99c1899d32c27`（docs/vslight-plan.md）
- 合并提交说明：Phase 1（构建开关）与 Phase 2（rebrand）对 `dev/build.sh` 的改动按计划要求合并为一次提交（`f60797a`）。

## Phase 1 改动

- `dev/build.sh`：`SHOULD_BUILD_REH=no`、`SHOULD_BUILD_REH_WEB=no`、`SHOULD_BUILD_CLI=no`（复用现成开关）

## Phase 2 改动要点

- 品牌变量：`dev/build.sh`、`utils.sh` → VSLight/vslight/vslight 仓
- `prepare_vscode.sh`：setpath 全量改写；外部链接删 6 个营销向（twitter/tips/requestFeature/introductoryVideos 等），
  文档与快捷键 PDF 指 code.visualstudio.com 上游文档，项目链接指 github.com/vslight/vslight；
  合并后 `jq del` 7 键（serverApplicationName/serverDataFolderName/tunnelApplicationName/
  tunnelApplicationConfig/win32TunnelServiceMutex/win32TunnelMutex/sessionsWindowAllowedExtensions）
  —— 三处运行时读取点均已核实 nil-safe（cli.ts:56、remoteTunnel.contribution.ts:120、
  extensionEnablementService.ts:118 `?? []`）
- 根 `product.json`：新增 `"builtInExtensions": []`（构建不再下载 js-debug 系扩展，与 Phase 4 批次 2 联动）
- `DISABLE_UPDATE=yes`：versions feed 未就绪前的兜底（Phase 6 任务④），届时回退本行
- 迁移指引：`docs/vslight-migration.md`；首启发现性 = Welcome 页 + README/迁移指引
- 图标：工具链缺失（icns2png/png2icns/icotool/rsvg-convert 全 MISSING），设计输入未就绪 →
  **沿用旧图标过编译验收，标记「阻塞发布验收」**；letterpress SVG 与 code.svg 暂不替换
- 残留扫描（72 文件）四类处理：工作流/打包/src 资源/dev 脚本全量改写；
  豁免并记录：docker 镜像名、AUR/snap/winget 外部商店标识（Phase 6 基础设施决策）、
  `@vscodium/*` npm 包名（外部已发布制品）、LICENSE 归属行（MIT 法律要求）、
  `00-copilot-disable-terminal-suggest.patch` 的 codium 补全文件（需 patch 再生成流程，随 Phase 3 处理）、
  dev/smoke.sh 基线回退路径（功能需要）
