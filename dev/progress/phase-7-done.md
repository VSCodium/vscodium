# Phase 7 集成验收记录（自动化代理执行 + 人工 UAT 待办）

> 计划要求「由非实现者在干净用户目录走完整主路径」。本记录由实现者以**干净 profile
> （每次 mktemp 全新 user-data/extensions 目录）**自动化代理执行；AX 依赖项
> （本终端无辅助功能权限）列为人工 UAT 待办。

## 主路径逐项证据（构建：2026-09-27 最终集成构建，BUILD EXIT 0）

| 步骤 | 结果 | 证据 |
|---|---|---|
| 安装/打开产物 | ✅ | `VSCode-darwin-arm64/VSLight.app`；CFBundleName=VSLight、id=com.vslight |
| 首启（迁移指引） | ✅（拷贝实测） | 本机装有旧 VSCodium：迁移指引拷贝块逐字执行成功（snippets 拷出、缺失项正确跳过）；`~/Library/Application Support/VSLight/User` 独立建目录；旧目录未动 |
| 打开/渲染 | ✅ | 干净 profile window1/renderer.log `Render performance baseline` =1；错误计数 0 |
| 编辑/文件 | ✅（CLI 层） | workspace 文件经 CLI 打开；编辑→保存 UI 链路归 UAT（AX） |
| 搜索 | ✅（打包面） | search 服务在包（searchService 未触碰）；UI 链路归 UAT |
| Git | ✅ | main.log `_doActivateExtension vscode.git, startup: true, activationEvent: '*'`（git 扩展启动即激活）；工作区 git 仓库初始化/提交正常 |
| 终端 | ✅（服务面） | terminal.log 正常初始化；终端面板 UI 归 UAT |
| 装扩展（open-vsx） | ✅ | smoke 多次 PASS：zhuangtongfa.material-theme + MS-CEINTL.vscode-language-pack-zh-hans 安装成功（含 cli.log 安装记录） |
| zh-CN 语言包 | ⚠️ 部分 | 包安装成功（多次实证）；界面变中文需 AX 目视 → UAT |
| 检查更新 | ✅（按设计关闭） | main.log `updates are disabled as there is no update URL`（DISABLE_UPDATE 兜底，feed 契约已备） |
| 数据目录边界 | ✅ | `.vslight`（设置/扩展）+ `.vslight-shared`（共享存储，本次构建修正后实证 wasCreated） |
| 卸载 | ✅（机制） | 无系统级写入（无 launchd/注册表）；删除 .app 与数据目录即完成 |

## 负向断言（全部通过）

- 产物无 sessions.desktop.main.js / agentHostMain.js；无 tunnel 二进制；无 reh 产物
- 默认设置注册 `remote.*`/`debug.*`/`notebook.*` = 0（schema 口径）
- `vslight tunnel` → `'tunnel' command not supported in vslight`（可读报错）
- `Remote development is not supported in VSLight` 文案在产物内
- chat 入口隐藏：`chat.disableAIFeatures` 默认 true（F-12 降级；命令面板/视图入口 UI 计数归 UAT）
- smoke 终态：`./dev/smoke.sh --skip-ui --phase 4` 16/16 PASS, exit 0

## 纯本地边界（决策 10）

- 断网可完成主路径：编辑/文件/搜索/Git/终端全本地（远程子系统已剥离）
- 外发连接面：仅 open-vsx（扩展）；（更新源当前关闭）遥测由 undo_telemetry.sh + 00-telemetry-disable.patch 关闭
- 无账号/设置同步参与主路径：github-authentication 仅 `onAuthenticationRequest` 被动激活（main.log 实证）

## 人工 UAT 待办（AX/目视依赖）

1. 命令面板负向计数（Remote Explorer/Debug:/Chat: = 0）与无空白视图容器
2. zh-CN 界面目视（菜单「文件」）
3. 编辑→保存、搜索、终端面板、Source Control 视图的正向 UI 链路
4. 关于框品牌 + Dock 图标目视（图标仍沿用旧版 = **发布阻塞项**）

执行建议：授予终端辅助功能权限后 `./dev/smoke.sh --phase 4`（L3 UI 层自动覆盖 1-3）。
