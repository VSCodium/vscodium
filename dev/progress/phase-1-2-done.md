# Phase 1+2 完工记录

- 日期：2026-09-27
- 提交：`f60797a`（改动）+ 后续 smoke.sh 修正提交
- 验收契约：全量构建 + 产物可观察断言（UI 层归入 Phase 7 集成验收）

## 退出条件逐条证据

### Phase 1（构建级裁剪）

| 条件 | 证据 |
|---|---|
| 全量构建通过 | `./dev/run-build.sh -s` → BUILD EXIT: 0；`grep -c "failed to apply patch" build.log` = 0；无 .rej |
| 产物 `bin/` 只有 vslight | `ls VSCode-darwin-arm64/VSLight.app/Contents/Resources/app/bin/` → 仅 `vslight` |
| 无 reh 产物 | `ls -d vscode-reh*` → no reh artifacts（构建前约 370MB 两包消失） |
| `SKIP_ASSETS=no ... -p` 不因缺 tunnel 失败 | 静态核实：`prepare_assets.sh:40` CLI 块有 `SHOULD_BUILD_CLI != "no"` 守卫；`build/osx/prepare_assets.sh` 无 tunnel/品牌引用（grep 为空）→ 不会触碰缺失二进制 |

### Phase 2（rebrand）

| 条件 | 证据 |
|---|---|
| Info.plist | CFBundleIdentifier=`com.vslight`，CFBundleName=`VSLight`（PlistBuddy 读取） |
| `vslight --version` | 输出 `1.135.06493` / commit `17f0e68...` |
| 新数据目录 | product.json `dataFolderName=".vslight"`、`urlProtocol="vslight"`、`applicationName="vslight"` |
| 删键生效 | product.json `has(serverApplicationName/tunnelApplicationName/sessionsWindowAllowedExtensions)` 全 false；`builtInExtensions=[]` |
| 品牌残留扫描 | `grep -ril codium`（排除 .git/vscode/VSCode-*/docs/icons/*.md/build.log）仅剩 7 类已记录豁免：docker 镜像坐标、AUR/snap/winget 外部商店标识、`@vscodium/*` npm 包名、LICENSE MIT 归属行、letterpress/code.svg（图标延后）、`00-copilot-disable-terminal-suggest.patch` codium 补全文件（随 Phase 3 patch 再生成处理）、dev/smoke.sh 基线回退、dev/build.sh 向后兼容 HELPER 标记 |
| smoke | `./dev/smoke.sh --skip-ui --phase 2` → EXIT 0（10/10 PASS）：含 tunnel 可读报错 `'tunnel' command not supported in vslight`、Git 扩展在包、open-vsx 主题扩展安装、zh-CN 语言包安装 |
| 迁移指引 | `docs/vslight-migration.md`（旧路径对照/设置拷贝/扩展导出重装/失效说明/首启发现性） |

## 未决（按计划标记）

- **图标**：沿用旧图标过编译验收，**阻塞发布验收**（工具链 MISSING + 设计输入未就绪）
- **关于框/首启 UI 目视**：归入 Phase 7
- **旧机首启迁移指引实操**：归入 Phase 7
- `DISABLE_UPDATE=yes` 兜底中，Phase 6 建 versions feed 后回退
