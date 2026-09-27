# VSLight 轻量化改造开发计划（v2 · 评审修订版）

> 目标：基于 VSCodium 打造一个**纯本地代码编辑器** —— 保留「编辑 / 文件 / 搜索 / Git / 终端 / 扩展」核心，
> 剥离远程开发、AI Chat、Debug 等非编辑功能，rebrand 为 **vslight**。
>
> 基线：VSCodium master（上游 VS Code 1.135.0，commit `08d4889`），macOS arm64 构建已验证通过。
>
> **v2 修订说明**：依据 `docs/vslight-plan.review.md` 的 23 条发现（F-01…F-23）修订。
> 所有发现均经逐条代码核实，**全部采纳**（仅两处评审数字以实测为准：品牌文件 72 个、codium-tunnel 二进制 20MB）。
> 发现 → 修订落点的映射见附录 A。

---

## 0. 设计原则

1. **改动分层，由浅入深**：构建开关 → product.json 配置 → 剪枝（remove）→ `.patch` 源码补丁。
   能用前一层解决的绝不用后一层。
2. **一个功能一个 patch**：每个裁剪项独立成 patch 文件，冲突时可单独禁用（`*.patch.no` 先例）。
   **号段分配**：Phase 3 用 90/91，Phase 4 从 92 起按批次递增。
3. **UI 级移除优先，API 层保留 stub**：从入口（`workbench.*.main.ts`、buildfile.ts）摘除 contribution，
   未被 import 的代码不进 esbuild 产物（`build/lib/optimize.ts:79-160` 已核实 `bundle:true`）。
   注意：`gulpfile.vscode.ts:78-122` 的 `vscodeResources` 清单会整目录拷贝媒体资源，摘 import 需同步改清单。
4. **单写人约定**：patch 生成与验证独占唯一的 `vscode/` 工作树；`workbench.*.main.ts`、
   electron-main 注册点、buildfile/gulpfile 的 hunk 由单人串行修改；并行仅限根仓文件级工作。
   （`dev/patch.sh:64-80` 前置联调循环有 bug —— 循环内 `git apply --reject "${FILE}"` 应为
   `${CANDIDATE}`，不要依赖它做前置联调。）
5. **每阶段有可观察退出条件**：全量构建 + 打开产物 + 可观察断言（见 §6 验收契约），
   `npm run compile` 只覆盖 src，不构成完工判定。

## 1. 现状分析（实测数据，v2 修正口径）

### 1.1 裁剪对象（源码体积与装机体积分列；装机 = `VSCode-darwin-arm64` 实测）

基线：`vscode/out-vscode-min` 354M = **JS/CSS 51MB + sourcemap 296MB（30 个文件）** + 其余资源；
`VSCodium.app` 1.0GB。**注意**：`stripSourceMapsInPackagingTasks = isCI`（`gulpfile.vscode.ts:185-186`），
CI 发布版本就不含 map —— 296MB 只影响本地/自发布口径；体积排序一律用装机 JS 字节，不用源码 MB。

| 模块 | 位置（均相对 `vscode/`） | 源码 | 装机 | 移除方式 |
|---|---|---|---|---|
| REH 远程服务端 | `src/vs/server` + 产物 `vscode-reh-*` | 332K | reh 包 ≈370MB | 构建开关 `SHOULD_BUILD_REH=no` |
| Rust CLI (tunnel) | `cli/`（依赖目录 311M = openssl 242M + tgz 68M；`cli/target` 是指向共享 cargo 缓存的符号链接） | 1M | 二进制 20MB | 构建开关 `SHOULD_BUILD_CLI=no`（**已存在**，勿新造） |
| **sessions 入口（v2 新增）** | `src/vs/sessions`、`buildfile.ts:28-32` 的 `sessions.desktop.main`/`agentHostMain` 入口 | 11M | **126M（JS 19.4MB + map 107.5MB）** | patch：摘 buildfile 入口 + gulpfile 包/资源清单 + product.json `sessionsWindowAllowedExtensions`（当前 `[]`）+ 窗口创建点（实施时定位） |
| **agentHost（v2 修正体量）** | `src/vs/platform/agentHost`（vscodium 52/53 号已删其 copilot/claude/codex 子目录，需协调避免重复删） | 12M | 14M | patch（随 sessions 入口一并处理） |
| 远程客户端/Explorer | `workbench/contrib/remote` 312K + `workbench/services/remote` 112K + `platform/remote`、`platform/remoteTunnel` 108K | ~0.5M | 中 | patch 摘 import + stub |
| Remote Tunnels | `contrib/remoteTunnel` 36K + `platform/remoteTunnel` | 144K | 小 | patch |
| Chat / AI | `contrib/chat` + `inlineChat`（`workbench.*.main.ts` 直接 import 实测 10 处：7+2+1） | 21M | 大 | patch，风险最高 |
| Debug（整体） | `contrib/debug` + 内置下载扩展 3 个（`ms-vscode.js-debug` 等）+ `extensions/debug-*` | 2.0M | 中 | patch + product.json 新增 `builtInExtensions: []` 覆盖 |
| Notebook | `contrib/notebook` 4.2M + `extensions/ipynb` 4.7M + `extensions/notebook-renderers` 27M | 36M | 中 | patch + 剪枝 |
| testing/welcome/feedback/issue reporter/merge editor/profiles/speech | `contrib/*` | — | 中 | patch（welcome 见 §1.3-d） |
| server 入口（v2 新增） | `src/server-main.ts:21,377`、`src/server-cli.ts:30` 直接 import `vs/server`；在 `src/tsconfig.json` 的 `./*.ts` 包含内 | — | — | patch（不处理则 `npm run compile` 报错） |
| policy-watcher 原生模块 | `@vscodium/policy-watcher`（node-gyp） | — | — | patch 移除 |

**已撤下**（决策 6 全保留）：低频语言扩展、主题包、认证扩展。
**已撤销**（F-16 前提错误）：NLS 精简项 —— `build/lib/i18n.ts` 的 9+4=13 种语言只服务 xlf/ISL 翻译流水线，
装机仅一份英文 `nls.messages.json`，收益≈0。中文改用 open-vsx 语言包，并纳入主路径验收
（「装 zh-CN 语言包后界面变中文」）。
**降级为可选/延后**（F-17）：重开 mangle —— `00-build-disable-mangle.patch` 已删整个 ts2ts mangler，
回滚需同时换 prepack 任务，净收益小且损害崩溃栈可读性；若保留 sourcemap 还需改
`00-build-update-sourcemap-url.patch` 的 VSCodium 基址（品牌泄漏）。

### 1.2 远程功能挂载点（v2 修正：注册点在文件，不在目录）

- `src/vs/workbench/workbench.common.main.ts`：L108-110（remote services）、L350-351、L429
- `src/vs/workbench/workbench.desktop.main.ts`：L79-84（tunnel/remote services）、L96（agentHost）、L143、L185、L189
- `src/vs/code/electron-main/` 下**只有 `app.ts` 与 `main.ts`** —— remote/remoteTunnel/tunnel 服务实现
  在 `src/vs/platform/{remote,remoteTunnel,tunnel}`，注册点在上述两个文件内
- sessions 入口：`build/buildfile.ts:28-32`、`build/gulpfile.vscode.ts:285-288,176`
- server 入口：`src/server-main.ts`、`src/server-cli.ts`
- 内置扩展：`vscode-test-resolver`、`tunnel-forwarding`（剪枝）

### 1.3 既有机制的硬约束（v2 新增，全部代码核实）

- **a. remove 先于 patch**（F-01）：`prepare_vscode.sh:150` 先跑 `patches/*.json`（`rm -rf`，路径缺失 `exit 4`），
  `:156` 才跑 `patches/*.patch`（失败 `exit 1`）。拟删目录被存量 patch 命中：
  `40-cli-use-reh-archive.patch`→`cli/`、`tunnel-forwarding`；`00-brand-remove-branding.patch`→
  `vscode-test-resolver`、`src/vs/server`；`00-remote-*.patch`→`src/vs/server`。
  **对策**：vslight 的剪枝动作必须放在所有 patch 之后（见 Phase 3 的 light-prune 阶段）。
- **b. product.json 无键级删除能力**（F-04）：`prepare_vscode.sh:126-127` 合并是 `jq -s '.[0]*.[1]'`
  （根覆盖上游，无删除语义）；`utils.sh` 的 JSON 动作只有 `rm -rf 路径`。根 `product.json` 仅 8 个键，
  无 `builtInExtensions`。删键需新增显式步骤（合并后 `jq del(...)` 或专门 patch）。
- **c. 删键顺序依赖**（F-04）：`build_cli.sh:14,23` 与 `prepare_assets.sh:45` 读
  `serverApplicationName`/`tunnelApplicationName`（读到 `undefined` 不报错，会静默拷出名为
  `undefined` 的二进制）。**Phase 1（关 CLI）必须先于 Phase 2（删键）**。
- **d. 扩展目录与 postinstall 联动**（F-10）：`build/npm/dirs.ts:32,48,54` 列有 `ipynb`、
  `tunnel-forwarding`、`vscode-test-resolver`，删目录必须同步改 `dirs.ts`（先例：`53-ext-copilot-remove-it.patch`）；
  `prepare_vscode.sh:250` 在 patch 后对 `welcomeGettingStarted/.../gettingStarted.ts` 做 `sed`，
  删 welcome 文件会让 `set -e` 中止构建 —— 保留文件或同步删该行。
- **e. 数据路径即品牌边界**（F-07）：上游 `product.json` `dataFolderName=".vscode-oss"`（vscodium stable
  未覆盖，仅 insider 设 `.vscodium-insiders`）；`userDataDir` 取 `nameShort`，扩展目录取 `dataFolderName`
  （`environmentService.ts:20,147`）。本机实测存在 `~/Library/Application Support/VSCodium` 与
  `~/.vscode-oss/`。rebrand 后老用户设置与扩展「消失」，必须有迁移指引。

## 2. 阶段计划

### Phase 0 — 基线与验收契约（0.5 天）

- [x] 全量构建跑通 —— 实际命令 `./dev/run-build.sh -s`，证据 `build.log`（2026-09-27 13:35）与产物
- [x] 建分支 `vslight`；恢复快照协议（§6）
- [x] `dev/smoke.sh` **规格**：驱动方式（CLI + AppleScript/快捷键注入）、每步断言、超时、退出码；
  正向（打开/编辑/搜索/Git/终端/装扩展）+ **负向清单**（Remote Explorer/Debug/Chat/sessions 入口不存在，
  命令面板与默认设置中 `remote.`/`debug.`/`chat.`/`notebook.` 前缀计数为 0）+ **保留面回归**
  （终端、Git、open-vsx 安装、语言/主题扩展、zh-CN 语言包）
- [x] **remove∩patch 审计表**（Phase 3/4 每项裁剪的开工前置产物）：列出拟删路径 × 存量 patch 命中关系，
  断言「remove 集合 ∩ 晚于剪枝阶段执行的 patch 目标 = ∅」

### Phase 1 — 构建级裁剪（0.5 天，零 patch）

改 `dev/build.sh`（与 Phase 2 的同文件改动合并为一次提交，单人串行）：

```bash
export SHOULD_BUILD_REH="no"      # 不产 vscode-reh-*
export SHOULD_BUILD_REH_WEB="no"  # 不产 vscode-reh-web-*
export SHOULD_BUILD_CLI="no"      # 复用现成开关（build_cli.sh:3-6 / prepare_assets.sh:40 已有守卫）
```

- 收益（本机实测口径）：cargo release 1m10s + reh 两个任务 9.9s/6.35s ≈ **每次构建省 ~2 min**；
  产物少两个 reh 包（≈370MB）与 20MB tunnel 二进制；`cli/` 不再参与。
  （对外宣称构建提速需注明：本机 `cli/target` 是共享 cargo 缓存，冷编译更长。）
- **退出条件**：全量构建通过；产物 `bin/` 只有 `vslight` 一个二进制；
  `SKIP_ASSETS=no ./dev/run-build.sh -s -p` 不因缺 tunnel 二进制失败。

### Phase 2 — Rebrand 为 vslight（1-2 天）

品牌改动为「**三类 + 残留扫描清单**」（F-23：实测 72 个文件含 codium，不止三处）：

1. **构建变量**：`dev/build.sh` 的 `APP_NAME/BINARY_NAME/ORG_NAME/GH_REPO_PATH/ASSETS_REPOSITORY`；
   `utils.sh:3-9` 默认值
2. **`prepare_vscode.sh` 重写**（单人 B 负责，与 Phase 6 同文件改动协调）：
   - setpath 段（L37-121，全文件 66 处品牌引用）：`nameShort/nameLong="VSLight"`、
     `applicationName="vslight"`、`dataFolderName=".vslight"`（显式设置，不再落 `.vscode-oss`）、
     `urlProtocol="vslight"`、`darwinBundleIdentifier="com.vslight"`
   - **键级删除**（F-04）：合并后新增 `jq del(.serverApplicationName, .tunnelApplicationName,
     .serverDataFolderName, .win32Tunnel*, .sessionsWindowAllowedExtensions, ...)` 步骤；
     内置调试扩展用根 `product.json` 新增 `"builtInExtensions": []` 覆盖（Phase 4 Debug 项联动）
   - **外部链接**（F-19）：L41-51 的 `documentationUrl/introductoryVideosUrl/releaseNotesUrl/
     requestFeatureUrl/tipsAndTricksUrl/twitterUrl/reportIssueUrl` 指定到 vslight 自有地址或删除
3. **图标**（F-18）：设计输入 + 责任人 + 最晚确认点；装工具链（`icns2png/png2icns/icotool/
  rsvg-convert` 本机全部 MISSING，`build_icons.sh` 缺依赖会 `exit 0` 静默成功）；
  **先删旧 `code.icns` 再生成**（文件存在会整段跳过）；验收 = 产物 mtime 更新 + Dock/关于框目视；
  设计未就绪允许占位过编译验收，但标记「阻塞发布验收」
4. **迁移与首启**（F-07）：明确「vslight 是独立产品，不承诺原地迁移」；提供首启/README 迁移指引
   （旧 settings/keybindings/tasks/snippets 路径、扩展清单导出与重装、旧目录保留、`codium` CLI 与
   `vscodium://` 深链失效说明）；首启发现性决策（精简 welcome 或 Help 入口）写入验收
5. **残留扫描清单**（F-23）：`dev/cli.sh`、`build/windows/msi/vscodium.wxs(.ru-ru.wxl)`、
   `build/linux/package_*.sh`、`stores/snapcraft/*`、`.github/workflows/*` 的 `APP_NAME`；
   patch 内非 token 品牌串（`@vscodium/vsce`、`@vscodium/native-keymap`、`@vscodium/policy-watcher`、
   `00-ui-custom-font.patch` 版权行）
- **退出条件**：`Info.plist`/关于框/`vslight --version`/新数据目录存在；
  `rg -il "codium" -g '!vscode/**' -g '!VSCode-*/**'` 无命中；装有旧版 VSCodium 的机器首启验证迁移指引可执行

### Phase 3 — 远程功能剥离（2-4 天）

- **前置**：Phase 0 审计表落盘
- **剪枝层**（F-01 对策）：在 `prepare_vscode.sh` 所有 patch 循环**之后**新增 light-prune 阶段
  （对 `patches/light/*.json` 跑 `apply_actions`），删除 `extensions/vscode-test-resolver`、
  `extensions/tunnel-forwarding`、`src/vs/server`、`cli/`；同步 `build/npm/dirs.ts`（§1.3-d）
- **patch 层**：`patches/91-light-remove-remote.patch` 摘 §1.2 挂载点 import 与 electron-main 注册；
  处理 `src/server-main.ts`/`src/server-cli.ts`（改成本地不可用报错或排除出 tsconfig）
- **失败语义**（F-20）：`vscode-remote://` 给出「vslight 不支持远程开发」可读报错（文案 owner 指定）；
  市场安装 Remote-SSH/Dev Containers 类扩展的行为定义（文档说明或最小提示）；
  `00-remote-disable-client-validation.patch` 已禁用客户端校验，需在文档写明放大效应
- **退出条件**：全量构建通过；`grep -c "failed to apply patch" build.log`=0 且 `find vscode -name '*.rej'`
  为空；Remote Explorer 消失；产物无 `vslight tunnel`；干净 profile 打开 `vscode-remote://` 验证文案；
  残留入口检查（默认设置/命令面板 `remote.` 前缀为 0、无空白视图容器）

### Phase 4 — 深度裁剪（3-6 天，单写人串行分批，每批一个号段 92+）

| 批次 | 项 | 验收（每批：编译 + smoke 含负向 + 装机 JS 字节对比 + 保留面回归 + dirs.ts 检查） |
|---|---|---|
| 1 | **sessions/agentHost 入口**（F-03，核心目标达成判定）：摘 `buildfile.ts` 入口、gulpfile 包与资源清单、product.json `sessionsWindowAllowedExtensions`、窗口创建点；与 52/53 号 patch 协调 | 产物无 `sessions.desktop.main.js`、无 `agentHostMain` |
| 2 | Debug 整体：摘 `contrib/debug` + `extensions/debug-*` 剪枝 + 根 product.json `"builtInExtensions": []` | 命令面板 `debug.` 前缀为 0；构建不再下载 js-debug |
| 3 | Notebook：`contrib/notebook` + `ipynb`/`notebook-renderers` 剪枝 + dirs.ts | `notebook.` 前缀为 0 |
| 4 | testing/welcome/feedback/issue reporter/merge editor/profiles/speech；welcome 同步处理 `prepare_vscode.sh:250` | 对应入口不存在；merge editor 删除前核实 Git 扩展是否引用其命令 |
| 5 | policy-watcher 等原生模块修剪 | postinstall 无 ERR |
| 6 | **Chat 最后**：摘 import 后按编译错误逐个击破 | `chat.` 前缀为 0；chat contribution 不进产物 |

**Chat 降级判据**（F-12，可判定化）：单次上游 rebase 中 chat 相关修复点 >20 处或预估 >2 人日，
则降级为「隐藏入口」（chat 仍打包但入口计数为 0），同样需负向断言。
**mangle/NLS**：mangle 延后（§1.1）；NLS 项撤销，zh-CN 语言包验收并入 smoke 保留面。

### Phase 5 — Bun spike（1-2 天，限时，隔离执行）

- **隔离**（F-14）：在独立 `git worktree`/clone 中进行，主工作树只读；不得与 Phase 3/4 共享
  checkout 与 `node_modules`
- 运行时不可替换的结论不变（Electron 内嵌 Node + 扩展宿主）；spike 只试 `bun install` 替 `npm ci`
  与 `bun gulp` 跑构建（1.135 构建脚本已是 TS-in-Node，Bun 原生跑 TS 理论更顺）
- 判定：全量构建通过 + 产物冒烟一致 + lockfile/依赖完整性 + CI 可复现 + 原生模块脚本兼容
- **输出限定为 ADR**；若采纳，另列任务清单（prepare_vscode.sh npm 流程、CI、lockfile 迁移）

### Phase 6 — CI / 更新源 / 发布（1-2 天）

- **更新机制四任务**（F-05）：
  ① 改写 `prepare_vscode.sh:54/57/59`（及 `build_cli.sh:15`、`dev/cli.sh`）指向 vslight ——
     `updateUrl`/`downloadUrl` 是字面量，与 `GH_REPO_PATH` 无关；
  ② 建 vslight 的 versions feed 仓并纳入发布流程，列出 `latest.json` 字段契约
     （`update_version.sh:54,117-135` 生成 `<quality>/<platform>/<arch>/latest.json`，
     `12-update-add-cooldown.patch` 依赖 `timestamp` 字段）；
  ③ 验收 =「从上一版本检查更新 → 下载 → 安装成功」一次真实走通；
  ④ 首版 feed 未就绪兜底：`DISABLE_UPDATE=yes` 或用户可读文案；**注意** `updateService.darwin.ts:143`
     无条件 `autoUpdater.setFeedURL`，adhoc 签名下 macOS 自更新是否可用需实机验证（可能需签名专项）
- **CI 与平台范围**（F-08，**待用户裁定**，默认建议 B）：
  A. 三平台都发都验收（保留/降级 linux/windows CI 为 workflow_dispatch + 逐平台装机验收，工作量约翻倍）
  B. 对外只发 macOS，决策 7 加注「三平台仅保证可构建，本期验收范围 = macOS」，上游升级时跑最低验证点
- 版本号：跟随上游 `1.135.x` + vslight 构建序号
- 发布物清单与 release notes/迁移说明落点（F-19）

### Phase 7 — 最终集成验收（0.5 天）

由**非实现者**在干净用户目录走完整主路径：安装 → 首启（迁移指引）→ 打开/编辑/搜索/Git/终端 →
装扩展（open-vsx）→ zh-CN 语言包 → 检查更新 → 卸载。记录落盘。

## 3. 时间线（v2 修正算术，依据入列）

```
Phase 0   ▌0.5d    验收契约 + 审计表          依据：无构建
Phase 1   ▌0.5d    构建开关                   依据：本机实测省 ~2min/次 + 少 390MB 产物
Phase 2   ▌1-2d    rebrand + 迁移指引 + 图标   依据：72 个品牌文件 + 图标工具链缺失
Phase 3   ▌2-4d    远程剥离                   依据：~10 处挂载点 + 每轮一次全量构建(~14.5min)
Phase 4   ▌3-6d    6 批串行裁剪               依据：每批一次全量构建 × 6 + chat 引用实测
Phase 6   ▌1-2d    更新源 + CI + 发布          依据：feed 仓契约 + 实机升级验证
Phase 7   ▌0.5d    集成验收
主路径    ▌8-15d
Phase 5   ▌+1-2d   Bun spike（独立 worktree，不占关键路径）
```

## 4. 风险与回退

- **patch 冲突**：`dev/update_patches.sh` 工作流；新增 `dev/verify-patches.sh` 门禁
  （全量 `git apply --check` + remove 路径存在性 + patch×remove 冲突自检），挂 PR 检查（F-13）
- **单写人**：Phase 3/4 patch 生成独占 `vscode/` 工作树，期间禁止他人构建
- **chat 耦合**：按 §Phase 4 降级判据执行
- **裁剪回退**：删对应 patch/剪枝条目即可恢复，无不可逆改动
- **上游升级**：独立分支 `vslight-rebase-1.13x` 验证 patch 应用后再合入

## 5. 决策记录

### 已确认（用户拍板）

1. Debug → **整个调试子系统全删**
2. Terminal → **保留**（连带 tasks 任务系统保留）
3. Git 扩展 → **保留**
4. 扩展机制 + open-vsx → **保留**
5. 更新机制 → **自建 GitHub releases 源**（详见 Phase 6 四任务，不是「复用 patch 就行」）
6. 语言/主题/认证扩展 → **全保留**
7. 目标平台 → **保留三平台构建能力**，patch 不得用平台专有条件规避

### 待裁定（评审新增，默认建议已标注）

8. **平台交付范围**（F-08）：A 三平台都发都验收 / **B 只发 macOS（默认）**，决策 7 加注验收范围
9. **sourcemap 取舍**（F-02）：A 体积当 KPI 追 map / **B 不当 KPI（默认）**，体积收益限定为
   「不产 reh+CLI + 摘 sessions/agentHost 入口」记账，验收用装机 JS 字节
10. **「纯本地」边界**（F-21）：默认断言 —— ① 断网可完成主路径；② 外发连接仅 open-vsx 与自建更新源；
    ③ 无账号/设置同步参与主路径（保留的认证扩展仅按需被动触发）。有异议请提出

## 6. 进度与恢复协议（F-06/F-22 新增）

- 每阶段开工：记 `dev/progress/phase-N-start.md`（git 快照点 + 计划版本 sha）
- 每阶段完工：记 `dev/progress/phase-N-done.md`（退出条件逐条证据：命令、日志路径、产物校验和）
- 验收契约统一为「全量构建 + 打开产物 + 可观察断言」；任何「验收通过」必须附证据链接
- 跨对话恢复：只看 `dev/progress/` 即可判断哪些阶段真实验收过

## 附录 A：评审发现 → 修订落点映射

| 发现 | 结论 | 落点 |
|---|---|---|
| F-01 remove 先于 patch | 核实属实（prepare_vscode.sh:150/156 + 4 个存量 patch 命中） | §1.3-a、Phase 0 审计表、Phase 3 light-prune 阶段 |
| F-02 体积口径错 | 核实属实（JS 51M/map 296M；strip=isCI） | §1.1 基线口径、Phase 4 验收、决策 9 |
| F-03 sessions/agentHost 漏项 | 核实属实（11M/126M、12M/14M、buildfile.ts:28-32、server-main/cli） | §1.1/§1.2、Phase 4 批次 1 |
| F-04 无键级删除 | 核实属实（根 product.json 8 键；build_cli.sh:14,23 读键） | §1.3-b/c、Phase 2.2 |
| F-05 更新契约错 | 核实属实（URL 是字面量；setFeedURL:143；feed 仓独立） | Phase 6 四任务 |
| F-06 无端到端验收 | 属实（smoke.sh 未写；compile 只覆盖 src） | §0.5、Phase 0 规格、§6 |
| F-07 数据边界迁移 | 核实属实（.vscode-oss 默认；本机双目录存在） | §1.3-e、Phase 2.4 |
| F-08 CI 与三平台冲突 | 属实 | Phase 6、决策 8 |
| F-09 SKIP_CLI 重复 | 核实属实（SHOULD_BUILD_CLI 已有三处守卫） | Phase 1 |
| F-10 dirs.ts/welcome 联动 | 核实属实（dirs.ts:32,48,54；prepare_vscode.sh:250） | §1.3-d、Phase 3/4 |
| F-11 数据归属错 | 核实属实（全部子项复测修正） | §1.1/§1.2 重写 |
| F-12 chat 降级不可判定 | 属实（直接 import 实测 10 处，阈值据此设定） | Phase 4 批次 6 |
| F-13 patch 门禁/单写人 | 核实属实（dev/patch.sh:71 bug） | §0.4、Phase 4、§4 |
| F-14 Bun 污染工作树 | 属实 | Phase 5 隔离条款 |
| F-15 工期算术 | 属实（主路径 8-15d + spike；收益按实测） | §3 重写 |
| F-16 NLS 前提错 | 核实属实（9+4=13 种仅流水线用；装机单英文） | §1.1 撤项、smoke 保留面 |
| F-17 mangle 倒挂 | 核实属实（mangler 整块已删；sourcemap 基址指 VSCodium） | §1.1 降级 |
| F-18 图标静默空操作 | 核实属实（exit 0 短路；4 工具 MISSING；code.icns 已存在） | Phase 2.3 |
| F-19 外部链接 | 核实属实（prepare_vscode.sh:41-51 指 Microsoft/VSCodium） | Phase 2.2 |
| F-20 残留入口语义 | 属实 | Phase 3 失败语义条款 |
| F-21 纯本地无断言 | 属实 | 决策 10（默认三条断言） |
| F-22 进度/恢复协议 | 属实（Phase 0 勾选与实际命令已核对，无虚报） | §6 |
| F-23 品牌范围低估 | 核实属实（实测 72 文件；含 utils.sh/dev/cli.sh/msi/snapcraft/workflows） | Phase 2「三类 + 扫描清单」 |
