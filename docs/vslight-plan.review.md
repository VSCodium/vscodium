# VSLight 轻量化改造开发计划 · 多视角评审

> 被审计划：[`vslight-plan.md`](vslight-plan.md)
> 评审日期：2026-09-27（AEST）· 只读评审，未改动计划与代码
> 报告交付：聊天内交付后按用户要求落盘于本文件

## 评审基线

| 项 | 值 |
| --- | --- |
| 计划文件 | `docs/vslight-plan.md`，193 行，sha256 `9040c3a4b3443054c5c7540f177b3b22a6949640292620305b50d4b1e8e894a9` |
| 仓库根 | commit `a479e8182d42f22796d58a736225dc8a0822657b`，工作树干净（ahead origin/master 2） |
| 上游源码 | `vscode/` 子仓 HEAD `08d4889f9ec4a1685d257b9b95de036c8e1ce1e5`（VS Code 1.135.0 + VSCodium patch 工作树，5452 个已改文件）；`dev/build.env` 的 `MS_TAG=1.135.0`／`RELEASE_VERSION=1.135.06493` |
| 现有构建证据 | `build.log`（2026-09-27 13:35）、`VSCode-darwin-arm64/`、`vscode-reh-darwin-arm64/`、`vscode-reh-web-darwin-arm64/`、`vscode/out-build` 407M、`vscode/out-vscode-min` 354M |
| 环境 | macOS arm64；node 24.18.0；python3.12 |
| 并发修改核对 | 评审前后计划 sha256 一致、`git status --porcelain` 为空 —— 无并发修改 |

**执行方式**：4 个视角各由 1 名独立、全新上下文的只读 subagent 并行调查。`facts`、`schedule` 首轮完成；`architecture`、`delivery` 首轮 30 分钟超时（未产出结论、未改文件），按评审合同各重派一次并限时后完成。主 agent 复核了全部 P1 结论，并补做独立测量（装机 map/JS 体积、esbuild 捆绑配置、`src/vs/sessions` 与 `agentHost` 体量、`dataFolderName`/userData/扩展目录真实路径、`autoUpdater.setFeedURL` 调用点、`build/npm/dirs.ts`、`icons/build_icons.sh` 短路与工具缺失）。

---

## 1. 确认问题

未发现 P0。以下 P1 影响范围、外部契约或核心目标，须在对应阶段开工前修订。

### P1

**F-01 [P1] `patches/*.json` 的 remove 先于所有 `*.patch` 执行，Phase 3 的删除清单会直接打断存量 patch，首次 prepare 即硬失败**
- 定位：`docs/vslight-plan.md:100-101`（90 号 JSON 删 `extensions/vscode-test-resolver`、`extensions/tunnel-forwarding`、`src/vs/server`、`cli/`）；`:51`、`:106`。
- 问题：VSCodium 的准备阶段先跑完所有 `patches/*.json`（`rm -rf` 目录），再跑所有 `patches/*.patch`；删除与 patch 都是全有或全无。被删目录正是存量 patch 的修改目标，patch 阶段 `git apply` 失败即退出，Phase 3 第一天就中断。
- 证据：`prepare_vscode.sh:4`（`set -e`）、`:150-160`（JSON 循环在前、patch 循环在后）；`utils.sh:28-38`（remove 路径不存在 `exit 4`）、`:63-66`（patch 失败 `exit 1`）；命中关系：`patches/40-cli-use-reh-archive.patch` → `cli/src/*` 与 `extensions/tunnel-forwarding/src/extension.ts`；`patches/00-remote-disable-client-validation.patch:1,38` 与 `patches/00-remote-remove-missing-vsda.patch:101` → `src/vs/server/node/*`；`00-brand-remove-branding.patch:527,536` → `extensions/vscode-test-resolver/*`（该 patch 共 99 文件，任一 hunk 失败整体不应用）。
- 修订：删除动作改到 patch 循环之后（新增 vslight 剪枝阶段，或放进 `patches/user/`），或先列出需 `.patch.no` 的存量 patch；并把「remove 集合 ∩ 存量 patch 目标 = ∅」写成 Phase 3/4 每项裁剪的开工前置产物（审计表）。
- 复核：改稿后核对 Phase 3 是否含该前置与受影响 patch 的处置；实现后跑一次全量 `./dev/run-build.sh -s`，`grep -c "failed to apply patch" build.log` = 0 且 `find vscode -name '*.rej'` 为空。
- 置信度：高；阻塞：Phase 3（并波及 Phase 4 的 Notebook/扩展类删除）。

**F-02 [P1] 体积口径与排序指标错：`out-build` 不是装机产物，`app/out` 的 83% 是 sourcemap，按「源码 MB」排优先级会投错工时**
- 定位：`:17-18`（§0.3 体积收益前提）、`:45`（参考基线 out-build 407MB / app 1.0GB）、`:114-124`（Phase 4 优先级表用源码体积）。
- 问题：装机 `app/out` = `out-vscode-min`，实测 **JS/CSS 51MB + sourcemap 296MB（30 个文件）**；`out-build` 407MB 是 tsc 全量输出（含 `.d.ts`、未打包依赖图、`vs/server` 等非装机内容），拿它做前后对比既不缩也不可比。源码体积与装机字节无单调关系（`src/vs/sessions` 源码 11MB，装机 126MB；`extensions/notebook-renderers` 源码 27MB）。
- 补充读法（重要）：`gulpfile.vscode.ts:185-186` 定义 `stripSourceMapsInPackagingTasks = isCI`，`:306`/`:376` 据此在打包时剥离 map —— 即 **CI 发布版不含 map，296MB 只出现在本地/自行分发的构建**。因此「剥离 map」是本地与自发布口径的杠杆（若需要，用独立开关，勿复用 `CI`），不是用户侧收益来源；用户侧的轻量化来自「不产 reh/CLI + 摘掉 sessions/agentHost 入口」。
- 证据：实测 `du`：`vscode/out-build` 407M、`vscode/out-vscode-min` 354M、`VSCode-darwin-arm64/VSCodium.app` 1.0G；`app/out` 下 30 个 `.map` 计 296MB、`.js/.css` 计 51MB；`build/gulpfile.vscode.ts:160-180`（`bundleVSCodeTask` 注释与 `optimize.bundleTask`）与 `build/lib/optimize.ts:79-160`（`esbuild.build({bundle:true, packages:'external'})`）——「未被 import 的模块不进装机产物」成立，但仅限从该入口可达者。
- 修订：§0.3 与 Phase 4 改口径——基线记 `out-vscode-min`（JS/CSS 与 map 分列），排序改用装机字节口径；并注明资源清单 `vscodeResources`（`gulpfile.vscode.ts:78-122`）会整目录拷贝媒体资源，摘 import 需同步改清单。
- 复核：改稿后检查基线是否含 JS/map 双数字；实现后按 `dev` 侧 `du` 产出与阈值断言。
- 置信度：高；阻塞：Phase 4 排期与「体积收益」类验收。

**F-03 [P1] 最大的 AI/远程面在计划外：`src/vs/sessions` 是独立入口（装机 19.4MB JS + 107MB map），`platform/agentHost` 的 12MB 被记作 8K**
- 定位：`:32`（§1.1 记 `platform/agentHost` 为 8K）、`:33`（Chat 只列 `contrib/chat + inlineChat`）、`:48-51`（挂载点只列 workbench 两个 main）、`:97-112`（Phase 3 范围）。
- 问题：桌面端有两个 workbench 形态的入口，`sessions.desktop.main` 是第二个。Phase 3/4 只摘 `workbench.*.main.ts` 的 import 碰不到它，执行完计划后 AI/远程面在装机产物里仍然完整存在——「剥离 AI Chat」的验收不成立。
- 证据：`vscode/build/buildfile.ts:32`（`workbenchDesktop` 含 `vs/sessions/sessions.desktop.main` 与 `vs/platform/agentHost/node/agentHostMain`）；`vscode/build/gulpfile.vscode.ts:285-288,176,78-122`（session bundle 与资源进桌面包）；装机实测 `app/out/vs/sessions` 126M（`sessions.desktop.main.js` 19.4MB + `.js.map` 107.5MB）；`vscode/src/vs/sessions/sessions.common.main.ts:106-108,143-148,224-233,345-346,407,467-493` 直接 import remote/chat/agentHost 系列；`du`：`src/vs/sessions` 11M、`src/vs/platform/agentHost` 12M（`app/out/vs/platform/agentHost` 14M）。
- 附带：被删模块还有两个入口直接 import `vs/server` —— `src/server-main.ts:21`、`src/server-cli.ts:30`，且都在 `src/tsconfig.json` 的 `./*.ts` 内，`npm run compile` 会因它们报错。删除集合需一并覆盖。
- 修订：把 sessions 入口与 agentHost 纳入范围并给剔除清单（`buildfile.ts` 摘 entry、gulpfile 摘包清单与资源、`product.json` 的 `sessionsWindowAllowedExtensions`、窗口创建点定位后处理），与既有 `patches/52-ext-copilot-remove-it.json`（已删 agentHost 的 copilot/claude/codex 子目录）协调避免重复删；建议列为 Phase 4 首项。
- 复核：改稿后核对范围表是否含 sessions/agentHost/两个 server 入口；实现后断言产物无 `sessions.desktop.main.js`、无 `agentHostMain`。
- 置信度：高；阻塞：核心目标「剥离 AI/远程」的达成判定。

**F-04 [P1] `product.json` 的键级删除/覆盖不是既有能力：Phase 2.2 声明的键不会消失，Phase 4 的 `builtInExtensions` 覆盖键也不存在**
- 定位：`:84-86`（删 `serverApplicationName`/`tunnelApplicationName`/`win32Tunnel*`/`serverDataFolderName`）、`:109`（Phase 3 断言这些键「已删」）、`:37`（`vscodium 根 product.json merge 覆盖` 去掉内置调试扩展）。
- 问题：`setpath` 只是写值，删掉这些行不等于删键——键由上游 `vscode/product.json` 提供，合并是根覆盖上游，根里没有的键不会消失；而 `utils.sh` 的 JSON 动作只有 `rm -rf 路径` 语义，没有删 JSON key 的能力。Phase 4 同理：根 `product.json` 只有 8 个键、没有 `builtInExtensions`，需新增该键才能真正去掉 3 个下载型调试扩展。另：`vscode/build/gulpfile.vscode.win32.ts` 仍读 `tunnelApplicationName`，与 `:193` 的「三平台平台无关」约束不一致。
- 证据：`prepare_vscode.sh:126-127`（`jq -s '.[0] * .[1]' product.json ../product.json`）、`:75-76,90-92,102-103,117-119`（被点名的 setpath 行）；`utils.sh:19-43`（仅 `remove`）；根 `product.json` 仅 8 键（`extensionAllowedBadgeProviders` 等）、`vscode/product.json` 的 builtInExtensions = 3（`ms-vscode.js-debug-companion`、`ms-vscode.js-debug`、`ms-vscode.vscode-js-profile-table`）；实测装机 `product.json` 仍含 `serverApplicationName:"codium-server"`。
- 修订：为 product.json 增加显式键操作（合并后 `jq del(...)` 步骤，或一个专门 patch 在 patch 阶段删键），并写明 Phase 1（关 CLI）必须先于 Phase 2（删键），因为 `build_cli.sh:14,23` 与 `prepare_assets.sh:43-45` 会读这些键（读到 `undefined` 不报错，会把二进制拷成 `undefined`，静默错误比硬失败更难查）。
- 复核：改稿后核对是否存在键级操作与顺序声明；实现后断言产物 `product.json` 无这些键、`VSCode-darwin-arm64/**/bin/` 只有一个二进制。
- 置信度：高；阻塞：Phase 2.2 与 Phase 4 P0（Debug）。

**F-05 [P1] 更新机制是错的契约：`GH_REPO_PATH` 不控制更新源，feed 仓、发布方、首版兜底与签名前提全部缺失**
- 定位：`:153-155`（Phase 6「自建 GitHub releases 源」一行）、`:185`、`:192`（§5.1「指向 vslight 仓库后直接复用，无需 DISABLE_UPDATE」）。
- 问题：`updateUrl`/`downloadUrl` 是 `prepare_vscode.sh` 里的字面量，与 `GH_REPO_PATH` 无关。按现状构建，vslight 的「检查更新」会读 VSCodium 的 feed 并可能引导用户下载 VSCodium 安装包；若改成未初始化的地址，显式检查更新会把原始异常字符串直接弹给用户。此外 macOS 自更新依赖签名，而计划把签名放到「对外分发再考虑」。
- 证据：`prepare_vscode.sh:54`（`updateUrl=…/VSCodium/versions/…`）、`:57-59`（`downloadUrl=…/VSCodium/vscodium(-insiders)/releases`）；`patches/11-update-use-github-release.patch` 的 `createUpdateURL` 只读 `productService.updateUrl`，路径为 `<updateUrl>/<quality>/<platform>/<arch>[/<target>]/latest.json`；`patches/12-update-add-cooldown.patch` 依赖 feed 的 `timestamp`；feed 由独立仓承担（`update_version.sh:54,117-135,142,151` 生成 `<quality>/<platform>/<arch>/latest.json`，工作流用 `VERSIONS_REPOSITORY`）；`vscode/src/vs/platform/update/electron-main/updateService.darwin.ts:143-144` 无条件调用 `electron.autoUpdater.setFeedURL`（上游原实现带 try/catch 并注明「application is very likely not signed」）；`prepare_vscode.sh:41-51` 的 Help 类链接多数仍指向 Microsoft/VSCodium。
- 修订：Phase 6 拆出四项任务——① 改写 `prepare_vscode.sh:54/57/59`（及 `build_cli.sh:15`、`dev/cli.sh`）到 vslight；② 建立 vslight 的 versions 仓并纳入发布流程，列出 `latest.json` 字段契约；③ 验收写「从上一版本触发检查更新 → 下载 → 安装成功」；④ 首版 feed 未就绪时的兜底（`DISABLE_UPDATE=yes` 或用户可读文案 owner）与回退方式，并明确 adhoc 签名下 macOS 自更新是否可用。
- 复核：改稿后核对四项是否都在 Phase 6 有落点；实现后 `jq -r .updateUrl product.json` 指向 vslight，且一次真实升级走通。
- 置信度：高（URL 归属与失败弹窗均有代码证据）；签名一项为中，需实机验证；阻塞：Phase 6 与首版发布。

**F-06 [P1] 没有端到端装机验收：`npm run compile` 判定不了被改的面，Phase 4/5/6 没有退出条件，`smoke.sh` 没有判定契约**
- 定位：`:20`（§0.4「每阶段可验收」）、`:59`（smoke.sh 一句话）、`:114`（Phase 4 每项「独立 patch + 冒烟」）；全文「验收」仅 4 处（`:20/73/93/111`）。
- 问题：Phase 1（只改 shell）、Phase 2（product.json/图标）、Phase 4 的 NLS/mangle/原生模块、Phase 5、Phase 6 都不在 `npm run compile` 的覆盖面上；Phase 4/5/6 无任何退出条件；没有一条跨模块的「安装 → 启动 → 主路径 → 装扩展 → 检查更新」验证；决策 2/3/4/6 的「保留面」没有回归断言，删错只能在发布后发现。
- 证据：`vscode/package.json` `compile: npm-run-all2 -lp compile-client`；`vscode/build/gulpfile.ts:37` `compileTask('src','out',false)`（另有 tsgo typecheck）；`build/**/*.ts` 仅被擦类型不做类型检查（gulp 用 `node --experimental-strip-types`）；`dev/smoke.sh` 不存在（未写）；patch/JSON 生效结果、product.json 键均无静态校验入口。
- 修订：每 Phase 退出条件统一为「全量构建 + 打开产物 + 可观察断言」，为 Phase 3/4 补负向断言（Remote Explorer/Debug/Chat/sessions 入口不存在、命令面板与默认设置中相应前缀为 0）；Phase 0 的 smoke 脚本补规格（驱动方式、每步断言、超时、退出码、负向清单）；增加「保留面回归清单」（终端、Git、open-vsx 安装、语言/主题扩展）；最终集成验收由非实现者在干净用户目录走一遍。
- 复核：改稿后逐 Phase 检查是否有用户可观察的退出条件与 FAIL 路径。
- 置信度：高；阻塞：所有阶段的完工判定。

**F-07 [P1] 产品标识即数据边界：`dataFolderName`/`applicationName`/bundle id 变化后，老用户设置与扩展会「全部消失」，计划零迁移内容**
- 定位：`:83-86`（`dataFolderName=".vslight"`、`applicationName="vslight"`、`darwinBundleIdentifier="com.vslight"`、`urlProtocol="vslight"`）、`:93-94`（验收只看新目录存在）。
- 问题：当前基线（stable）根本没有设置 `dataFolderName`，实际是上游默认 `.vscode-oss`；用户数据目录取 `nameShort`。改动后 userData 与扩展目录都换位置，看起来像数据丢失；`codium` shell 入口与 `vscodium://` 深链失效；macOS 出现两个 bundle id 的并存应用。全文无「迁移/首启说明」相关内容（`grep -c "迁移\|migrat\|首启"` = 0）。
- 证据：`vscode/product.json` `dataFolderName=".vscode-oss"`、`prepare_vscode.sh:71` 仅 insider 设 `.vscodium-insiders`；`vscode/src/vs/platform/environment/node/environmentService.ts:20`（`userDataDir: getUserDataPath(args, productService.nameShort)`）；`vscode/src/vs/platform/environment/common/environmentService.ts:147`（`extensionsPath = userHome/<dataFolderName>/extensions`）；本机实测存在 `~/Library/Application Support/VSCodium` 与 `~/.vscode-oss/extensions/extensions.json`。
- 修订：明确一条决策并写入计划——「vslight 为独立产品，不承诺原地迁移，但提供首启/README 迁移指引」（旧 settings/keybindings/tasks/snippets 路径、扩展清单导出与重装、旧目录保留、可选 `codium`→`vslight` 兼容入口、深链失效说明），并作为 Phase 2 验收项。
- 复核：改稿后检查 Phase 2 是否含「存量用户」段落；实现后在装有旧版 VSCodium 的机器上首启确认指引可执行。
- 置信度：高；阻塞：Phase 2 完工口径与对外发布说明。

**F-08 [P1] Phase 6 的 CI 收敛与决策 7「保留三平台构建能力」冲突，三平台没有产出与验收机制（需用户裁定交付范围）**
- 定位：`:148-156`（「只保留 macOS（+需要的平台）」）对 `:184`（决策 7）与 `:193`（三平台 compile 都要过）。
- 问题：CI 是 macOS 主机上 Linux/Windows 的唯一自动化验证入口（本地只有 Linux docker，Windows 无入口）。裁掉后「三平台保留」只剩口号，而计划自身要求 patch 不得用平台专有条件，等于要维护三平台代码路径却无产出验收。
- 证据：`.github/workflows/` 现有 `ci-build-{macos,linux,windows}.yml` 与 8 个 `publish-*`；`dev/build_docker.sh` 是本地唯一 Linux 入口。
- 修订：二选一并写进计划——① 承诺三平台：Phase 6 保留（或降级为 `workflow_dispatch`/nightly）linux/windows 构建，并给逐平台最小装机验收（安装、首启、PATH 入口、卸载）；② 只承诺 macOS：在决策 7 加注「三平台仅保证可构建，本期验收范围 = macOS」，并补上游升级时的最低验证点。
- 复核：改稿后检查决策 7 是否有范围注记，Phase 6 是否含逐平台产出与验收映射。
- 置信度：高；阻塞：Phase 6。

### P2

**F-09 [P2] `SKIP_CLI` 是重复造开关**
- 定位：`:68`（`export SKIP_CLI="yes"   # 新增开关`）、`:71`（三处调用点加守卫）。
- 问题：`build_cli.sh:3-6` 已有 `SHOULD_BUILD_CLI=="no" → return 0` 守卫，`prepare_assets.sh:40` 同款，`check_tags.sh:141` 已在写该变量。设 `SHOULD_BUILD_CLI=no` 即可，无需新变量与三处守卫。另注意 Phase 1 与 Phase 2 都改 `dev/build.sh`，须同一人串行。
- 修订：删去 `SKIP_CLI`，统一复用 `SHOULD_BUILD_CLI`；把 Phase 1 与 Phase 2 的 `dev/build.sh` 改动合并为一次提交。
- 复核：`grep -rn "SKIP_CLI" .` 为空；`SKIP_ASSETS=no ./dev/run-build.sh -s -p` 不因缺 tunnel 二进制失败。
- 置信度：高。

**F-10 [P2] 删扩展目录未同步 `build/npm/dirs.ts`，postinstall 会失败；welcome 被 prepare 的 `sed` 依赖**
- 定位：`:101`（remove 两个扩展目录）、`:119-121`（Debug/Notebook/welcome）。
- 问题：`build/npm/dirs.ts` 逐目录列了这些扩展并参与 `postinstall` 的逐目录 `npm install`，缺失目录会失败；`prepare_vscode.sh:250` 在 patch 之后对 `src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts` 做 `sed`，若以删文件方式移除 welcome，`set -e` 会中止构建。
- 证据：`vscode/build/npm/dirs.ts:20,32,42,48,54`；`vscode/build/npm/postinstall.ts:241-253`；既有先例 `patches/53-ext-copilot-remove-it.patch` 同步改了 `dirs.ts`；`prepare_vscode.sh:250`、`utils.sh:77-83`（`sed -i` 失败即非 0）。
- 修订：Phase 3/4 每项裁剪的交付物里显式加「同步 `build/npm/dirs.ts`」；welcome 项注明「保留 `welcomeGettingStarted` 文件，或同步删除 `prepare_vscode.sh:250` 的 replace」。
- 复核：删除后 `node build/npm/postinstall.ts` 无 ERR；`rg BUILTIN_ANNOUNCEMENTS vscode/src` 与预期一致。
- 置信度：高。

**F-11 [P2] §1.1/§1.2 现状数据有多处口径与归属错误，会误导范围与优先级**
- 定位与证据（逐条）：
  - `:32` `platform/agentHost` 记 8K —— 实为 12M 源 / 14M 装机，8K 只是 `contrib/remoteCodingAgents`。
  - `:29`「Rust CLI 构建产物 311MB」—— 实为 `vscode/cli` 依赖目录（openssl 242M + tgz 68M + src 1M），实际二进制 21MB（`bin/codium-tunnel`）。
  - `:82`「setpath 段（66 处 codium 引用）」—— 整文件 66 行，setpath 段（L64-121）为 35 行。
  - `:50`/`:105` `src/vs/code/electron-main/{remote,remoteTunnel,tunnel}` 三目录不存在；真实注册点在 `src/vs/code/electron-main/main.ts` 与 `app.ts`。
  - `:34` 未计 `extensions/ipynb` 4.7M 与 `extensions/notebook-renderers` 27M。
  - `:30-31` 同格列出的 `services/remote` 112K、`platform/remoteTunnel` 108K 未计入。
  - `:32`「vscodium 已部分清理 remoteCodingAgents」不实 —— `patches/` 中无该路径，52/53 号清的是 `extensions/copilot` 与 agentHost 的 copilot/claude 部分。
  - `:36` Terminal 行仍写「待讨论」，与 `:182` 决策 2「保留」冲突；`:41` NLS「14 种语言」见 F-16。
- 修订：把「源码体积」与「产物体积」分列重写 §1.1，修正 §1.2 挂载点，删除与决策冲突的「待讨论」标记。
- 复核：改稿后逐行对照 `du`/`grep` 复测值；`check_paths` 类脚本对 `vscode/` 前缀写法做统一（计划里 `src/...`/`build/...` 均省略 `vscode/` 前缀，易误读）。
- 置信度：高。

**F-12 [P2] Chat 降级判据不可判定，且降级本身不省成本**
- 定位：`:129`（「允许降级为隐藏入口而非物理摘除」）、`:126-128`。
- 问题：没有阈值/信号/验收口径，实施者无法决定何时降级；且降级要改的正是菜单/设置 schema/欢迎页这些高耦合点，却拿不到任何体积收益（chat 仍被打包）。
- 修订：给可判定条件（例如 rebase 中 chat 相关修复点超过 N 处或预估超过 X 人日即降级），并要求降级路径同样有验收断言（产物中 chat contribution 仍存在、但入口计数为 0）。
- 复核：改稿后检查该判据是否可判定、是否有对应断言。
- 置信度：高。

**F-13 [P2] 缺 patch/产物门禁，「一个功能一个 patch 独立可并行」在工程上不成立**
- 定位：`:15-17`（§0.2）、`:114-128`（Phase 4 逐项独立 patch）、`:171-175`（§4 用项目工作流修复冲突）。
- 问题：patch 生成与验证独占唯一的 `vscode/` 工作树，`dev/patch.sh`/`dev/merge-patches.sh` 都会 `git reset --hard` 并交互式等待人工消解 `.rej`；所有远程/chat 剥离项又都落在同一批 `workbench.*.main.ts` 挂载点（现存只有 `81-ui-disable-onboarding.patch` 碰该文件）。计划没有单写人、没有序号分配、没有「不应存在 sessions/agentHost/chat contribution」类产物断言。
- 附带缺陷：`dev/patch.sh:64-116` 的同组前置循环实际执行 `${FILE}` 而非 `${CANDIDATE}`，不要依赖它做前置联调。
- 修订：新增 `dev/verify-patches.sh`（全量 `git apply --check` + remove 路径存在性 + patch×remove 冲突自检）并挂 PR；计划写明新 patch 序号分配（90/91 归 Phase 3，Phase 4 从 92 起）、单写人约定（`workbench.*.main.ts` 与 electron-main 注册点相关 hunk 单人串行）、并行仅限根仓文件级工作。
- 复核：改稿后核对波次表里各项写入集互不重叠且都有单写人；CI 跑一次门禁脚本。
- 置信度：高。

**F-14 [P2] Phase 5 的 Bun spike 与主干共用工作树/依赖，判据不足，采纳后无落点任务**
- 定位：`:131-146`、`:165`（「可并行/可裁」）。
- 问题：`bun install` 会改写 `vscode/node_modules`（1.4G）与 lockfile，污染 Phase 2-4 的构建与验收；判据「全量构建通过 + 产物冒烟一致」不覆盖 lockfile/依赖完整性/CI 可复现/供应链审计/三方脚本兼容；若判定保留，`prepare_vscode.sh` 的 npm 流程、CI、lockfile 均无对应任务。
- 证据：`prepare_vscode.sh:207-228`（`npm ci` 重试流程）；`dev/build.sh:109-122`（每次 `-s` 运行 `rm -rf .build out*`）；`.github/workflows/*` 全用 Node 环境；原生模块 30+ 走 node-gyp（与运行时无关，计划已自述「该省不掉」）。
- 修订：规定 spike 在独立 clone/`git worktree` 中进行，主工作树只读；输出限定为「ADR 增补 + 若保留则新增任务清单」。
- 复核：spike 目录不在同一 checkout；结论产物是记录而非代码。
- 置信度：高。

**F-15 [P2] 工期区间算术不自洽，多个估算无依据**
- 定位：`:157-168`（各阶段时长与总计）。
- 问题：下限合计 10 天（去掉 Phase 5 才是 9），上限 17 天含 Phase 5；`:168`「约 9-17 个工作日(Phase 5 不占关键路径)」两端点不可比。Phase 1「省 5-10 min」与本机实测不符（`build.log` 中 `cargo build --release` 为 1m10s，两个 reh 任务 9.9s/6.35s，全量约 14.5min，且 `vscode/cli/target` 指向共享 cargo 缓存）；Phase 3/4/6 的估算无来源。
- 修订：改为「主路径 10-15 天 + 可选 spike 1-2 天」，给每个估算加依据来源列（Phase 1 用实测构建时长、Phase 4 用每项一次全量构建 × 项数 + chat 引用数实测）。
- 复核：区间端点组成一致；每个数字有出处。
- 置信度：高。

**F-16 [P2] NLS 项前提错误，装机收益≈0**
- 定位：`:41`（「构建产物 14 种语言」）、`:122`（P2「只保留 en（+zh-CN）」）。
- 问题：`vscode/build/lib/i18n.ts:28-45` 是 9 default + 4 extra = **13** 种，且只被 xlf/ISL 翻译流水线使用；`vscode-min-prepack` 链不跑 i18n 任务，装机只有一份英文 `nls.messages.json`（实测 app `out/` 仅此一份、无 `translations`、无语言包）。`+zh-CN` 不是 patch 能产出的东西。
- 修订：删除该项，或改写为「构建不产出多语言 NLS；中文通过 open-vsx 语言包获得」并把它纳入主路径验收；若对外宣称中文可用，则补「装语言包后界面变中文」的断言。
- 复核：`ls` 产物确认无多语言文件；干净 profile 装 zh-CN 语言包后确认界面语言。
- 置信度：高。

**F-17 [P2] 重新启用 mangle 的收益/代价倒挂，且与剥离 map 的次序冲突**
- 定位：`:123`（P2「重新启用 mangle」）。
- 问题：`patches/00-build-disable-mangle.patch` 已删掉整个 ts2ts mangler 块，且非 esbuild 路径固定用 `compile-build-without-mangling`；「重新启用」需同时回滚 patch 并换 prepack 任务。收益只作用 JS 且 esbuild minify 已处理局部名，净收益小；代价是崩溃栈/私有字段不可读，而 `patches/00-build-update-sourcemap-url.patch` 把 sourceMappingURL 指向 `github.com/VSCodium/sourcemaps/…`（vslight 的 commit 不存在，功能无害但品牌泄漏、调试更差）。
- 修订：降级为「可选/延后」，并写明与 strip-map 的次序关系；若要保留 sourcemap，需同时改 sourcemap 基址。
- 复核：回滚 patch + 换 prepack 任务试跑，对比 JS 字节与崩溃栈可读性。
- 置信度：中。

**F-18 [P2] 图标是无人负责的外部依赖，且脚本可能静默空操作**
- 定位：`:87-89`（图标项）、`:93-94`（验收不含图标）。
- 问题：`icons/build_icons.sh:25-34` 缺任一依赖即 `exit 0`（静默成功），`:51` 在 `src/${QUALITY}/resources/darwin/code.icns` 已存在时整段跳过（该文件当前存在）；本机 `icns2png`/`png2icns`/`icotool`/`rsvg-convert` 全部 MISSING，源 SVG 仍是 codium 版本。
- 修订：补设计输入与责任人/最晚确认点、工具链准备、先删旧资源再生成、验收加「产物 mtime 与旧品牌不同 + dock/关于框目视」；设计未就绪时允许占位过编译验收，但标记为「阻塞发布验收」。
- 复核：`stat` 产物时间戳；打开 app 目视。
- 置信度：高。

**F-19 [P2] rebrand 未覆盖用户可见的外部链接、反馈通路与首启发现性**
- 定位：`:91`（残留品牌扫描只提 `00-ui-report-issue.patch`）、`:121`（P1 删 welcome/feedback/issue reporter）、`:191`。
- 问题：`prepare_vscode.sh:41-51` 的 `releaseNotesUrl`/`requestFeatureUrl`/`tipsAndTricksUrl`/`twitterUrl` 仍指向 Microsoft 官方，`reportIssueUrl` 指向 VSCodium issues；Phase 4 又计划删 feedback/issue reporter，产品将没有反馈入口，release notes/迁移说明在计划中无落点。叠加既有 `patches/80-ui-disable-onboarding.json`（已禁引导）与拟删 welcome，新用户首启后没有任何「从哪开始」的表面。
- 修订：把 `prepare_vscode.sh:41-51` 纳入 Phase 2 清单并指定目标地址；落一个 release notes/迁移说明发布位置；显式决定首启发现性（保留精简 welcome 或给出 Help 入口）并写进验收。
- 复核：打开关于框/Help 菜单逐一确认链接；新 profile 首启检查是否有入口。
- 置信度：高。

**F-20 [P2] 删除后的残留入口与失败语义没有定义**
- 定位：`:105-111`（stub 与「友好报错」仅一句）；`:119-126`。
- 问题：命令面板/默认设置中 `chat.`/`remote.`/`debug.`/`notebook.` 前缀条目、视图容器空白、菜单悬空项由谁清理到「可理解 + 有下一步」未定义；`vscode-remote://` 文案 owner 未定；从市场安装 Dev Containers/Remote-SSH 等依赖 remote 能力的扩展后的行为未定义，而 `00-remote-disable-client-validation.patch` 已禁用客户端校验会放大不确定性；`urlProtocol` 改 `vslight` 后旧协议亦无说明。
- 修订：Phase 3/4 各加「残留入口清单」验收（默认设置与命令面板前缀为 0、无空白视图容器）；明确文案归属与 remote 依赖扩展的市场处理（文档说明或最小提示）。
- 复核：干净 profile 下搜索三类前缀、打开 `vscode-remote://` 链接、从市场装 Remote-SSH 观察结果。
- 置信度：中高。

**F-21 [P2] 「纯本地」这一核心价值主张没有验收落点**
- 定位：`:3-6`（目标）、`:179-187`（决策清单无此项）、`:111-112`（Phase 3 只验收 Remote Explorer/tunnel）。
- 问题：验收用「模块是否删掉」替代「是否纯本地」，容易被假阳性替代；保留的认证扩展（决策 6）+ open-vsx 与「纯本地」的边界无人裁定；stub 的行为语义（扩展声明 remote/workspace `extensionKind` 时如何表现）未定义。
- 修订：加 3 条可判定断言——① 断网可完成主路径（打开/编辑/搜索/Git）；② 外发连接仅 open-vsx 与自建更新源（列出检查方法）；③ 无账号/设置同步参与主路径；并明确 stub 的报错文案与触发场景。
- 复核：每条断言给出命令或观察点。
- 置信度：中（边界需用户确认）。

**F-22 [P2] 无进度/恢复协议，且 Phase 0 勾选项没有命令与证据链接（默认命令会毁掉工作树）**
- 定位：`:55-59`（Phase 0 勾选项）；全文无「实施进度/恢复快照/完成记录」（对照 dev-plan 骨架，格式本身不判错，此处指实施后果）。
- 问题：无法判断哪个阶段真的验收过；`:57` 只写 `dev/run-build.sh`，而 `dev/build.sh:13-17,84-94` 默认 `SKIP_SOURCE="no"` 会 `rm -rf vscode* VSCode*` 并重新 clone + 重装依赖；实际构建用的是带 `-s` 的参数（`build.log:2-8`）。
- 已核实：Phase 0 勾选项与 `build.log`（13:35）及产物时间一致 —— 计划**没有虚报完成**。
- 修订：加恢复快照 + 每阶段一条记录；勾选项补记实际命令 `./dev/run-build.sh -s`、日志路径与产物校验。
- 复核：只读快照 + 记录能否在没有对话历史的条件下判断验收真实性。
- 置信度：高。

**F-23 [P2] 「品牌字符串集中在三处」低估范围**
- 定位：`:77-91`。
- 问题：vscodium 层（不含 `vscode/` 与构建产物）含 `codium` 的文件实测 87 个；功能面还包括 `utils.sh:3-9` 默认值、`dev/cli.sh:2-6,10`、`build/windows/msi/vscodium.wxs` 与 `vscodium.ru-ru.wxl`、`build/linux/package_*.sh`、`stores/snapcraft/*` 的 snapcraft.yaml、各 `publish-*`/`ci-*` 工作流的 `APP_NAME`。`!!TOKEN!!` 体系真实（`utils.sh:53-61`，9 个 token）但 patch 内仍有非 token 品牌串（`@vscodium/vsce`、`@vscodium/native-keymap`、`@vscodium/policy-watcher`、`00-ui-custom-font.patch` 的版权行）；计划举例的 `00-ui-report-issue.patch` 实际全用 token，例子反了。
- 修订：把「三处」改为「三类 + 残留扫描清单」，逐项列出要改的脚本与 patch。
- 复核：全仓品牌扫描（排除 `vscode/` 与产物）无 `codium` 命中。
- 置信度：高。

---

## 2. 待核实 / 待决策

| 项 | 缺什么证据 / 需谁裁定 | 影响 | 最晚确认点 |
| --- | --- | --- | --- |
| 三平台交付范围（F-08） | 用户裁定：本期对外只承诺 macOS，还是承诺三平台 | Phase 6 与决策 7 的写法 | Phase 6 开工前 |
| 体积目标是否允许牺牲本地 sourcemap（F-02） | 用户裁定：接受剥离 296MB map（影响本地/自发布）换体积，还是把体积收益限定为 JS 口径 | Phase 4 优先级与验收 | Phase 4 开工前 |
| vslight versions 仓布局 | 需核对 `VSCodium/versions` 真实 `latest.json` 字段（含 `timestamp`）并确定新仓产出物 | 更新机制验收 | 写 Phase 6 设计时 |
| adhoc 签名下 macOS 自更新是否可用 | 需一次实机：签名产物 + `setFeedURL`/`checkForUpdates` | F-05 是否需要签名专项 | Phase 6 开工前 |
| Chat 引用实际规模与「50+」口径 | 需给出统计命令；现可见 `workbench.common.main.ts` 7 处、`desktop.main.ts` 2 处 chat 引用 | Phase 4 排期与降级阈值 | Chat 项开工前 |
| cargo 冷编译时长 | 本机 `vscode/cli/target` 是共享缓存符号链接 | Phase 1 收益主张 | Phase 1 验收时 |
| sessions 是否默认对用户可见 | 未定位到窗口创建点（`product.json` 的 `sessionsWindowAllowedExtensions` 是唯一确认的 product 级键） | 删除的用户价值 | Phase 3/4 设计时 |
| 删 merge editor 后 Git 扩展是否引用其命令 | 代码未核 | 保留面回归 | 该项实施前 |
| chat/notebook/debug 在 19.1MB workbench bundle 中的确切字节占比 | 需按 sourcemap sourcesContent 或逐模块统计 | 体积类验收 | Phase 4 前 |

---

## 3. 覆盖摘要

- **实际执行方式**：4 个视角各 1 名独立、全新上下文的只读 subagent（同一 workflow 并行）。`facts`、`schedule` 首轮完成；`architecture`、`delivery` 首轮 30 分钟超时（未产出结论、未改文件），按合同各重派一次并限时后完成。主 agent 复核了全部 P1 结论。
- **主 agent 补做并并入结论的独立测量**：装机 `out-vscode-min` 的 JS/CSS 51MB 与 map 296MB（30 文件）；`build/lib/optimize.ts:79-160` 的 `esbuild.build({bundle:true})` 与 `gulpfile.vscode.ts:160-180` 的 import 图捆绑；`src/vs/sessions` 11M/装 126M 与 `platform/agentHost` 12M/装 14M；`dataFolderName`/`userDataDir`/`extensionsPath` 三处路径来源与真实用户目录（`~/Library/Application Support/VSCodium`、`~/.vscode-oss/extensions`）；`updateService.darwin.ts:143-144` 无保护调用 `setFeedURL`；`build/npm/dirs.ts` 的扩展目录清单；`icons/build_icons.sh` 的 `exit 0` 短路与依赖缺失。
- **脚本**：`check_paths.sh docs/vslight-plan.md <仓库根>` 已运行 —— 18 个路径 token，10 个 MISSING，人工判定均为「新增文件（`patches/90|91`、`dev/smoke.sh`）」或「`vscode/` 内相对路径（`src/vs/...`、`build/lib/i18n` 需理解为 `vscode/` 前缀）」，无真正失效的复用路径；建议计划中统一写清基目录。`check_progress.sh` 跳过：计划未采用 dev-plan 的恢复快照/完成记录协议（属历史自定格式，不按格式判错），等价进度证据为 Phase 0 勾选项，已与 `build.log`/产物交叉核对（一致，未虚报）。
- **四维覆盖**：facts 逐条核对 §1.1/§1.2 全部路径、开关与数字（并入 F-01/04/09/11/16/23）；architecture 覆盖体积前提、捆绑链、sessions/agentHost 范围、patch-first 可持续性与两个未验证判据（F-02/03/12/13/17）；schedule 覆盖映射、依赖边、并发编排、工期与进度可恢复（F-06/13/14/15/22）；delivery 覆盖主路径闭环、迁移、更新、残留与 UI 证据等级（F-05/07/19/20/21）。**未核实**：chat/notebook/debug 在 workbench bundle 中的确切字节占比；`VSCode-darwin-arm64` 内 map 与 `out-vscode-min` 的逐文件对应；sessions 窗口创建点；i18n 改动对 win32 ISL 的影响。以上均不改变本文结论。
- **UI/UX 证据等级**：**文档推演，待实现后应用内验收**。本次无设计稿、无可运行产物、未启动应用或浏览器，因此只能判断入口/闭环/验收方案是否完整，不能判断布局、空状态、失败文案与图标实际观感；`npm run compile`、体积对比、`Info.plist` 字符串核对都**不算** UI/交付验收。

---

## 4. 需求 → 交付映射与实施编排

### 断链项

| 需求/决策 | 设计 | 任务 | 验收 | 状态 |
| --- | --- | --- | --- | --- |
| 纯本地（`:3-6`） | 无 | Phase 3 远程剥离 | **无** | 断链（F-21） |
| 剥离 AI Chat | 摘 import（`:126-129`） | Phase 4 P0 | 无，且 sessions/agentHost 未纳入 | **断链**（F-03/F-12） |
| 剥离远程 | §1.2 挂载点（基本准确） | Phase 3 | `:111-112` | 有闭环但 remove 冲突（F-01/F-20） |
| Rebrand | 变量 + setpath + 图标 | Phase 2 | `:93-94` | 字符串侧基本闭环；数据边界/图标/外部链接缺失（F-07/F-18/F-19/F-23） |
| 更新源（决策 5） | 无（只有「复用 11/12」） | Phase 6 一行 | 无 | **断链**（F-05） |
| 三平台（决策 7） | 无 | Phase 6 反而裁 CI | `:193` 一句 | **断链 + 冲突**（F-08） |
| Debug 全删（决策 1） | Phase 4 表行 | 有 | 无；机制缺失（F-04） | 任务→验收断链 |
| 保留面（决策 2/3/4/6） | 保留 | 无删除项 | 仅正向 smoke 的 Git 一项 | 验收薄弱（F-06） |
| 回退（`.patch.no`） | 约定真实可用 | 有 | 无恢复验证步骤 | 部分 |

### 关键依赖边

`建分支 / 冒烟契约 / remove×patch 审计` → Phase 1 → Phase 2 → Phase 3 → Phase 4；`Phase 1 关 CLI` → `Phase 2 删 product.json 键`（否则 `build_cli.sh`/`prepare_assets.sh` 读到 `undefined`）；`Phase 2 品牌与仓库地址` → `Phase 6 feed 与发布资产命名`；`Phase 2 图标设计交付` → 分发包；`独立 checkout` → Phase 5；`Phase 1 开关在 CI 落地` → Phase 6 CI 收敛。
缺节点：remove∩patch 审计、versions feed 仓、平台验证入口。

### 建议波次

| 波次 | 前置/解锁证据 | 可并行的工作 | 写入边界 / 共享负责人 | 运行资源约束 | 汇合验收 |
| --- | --- | --- | --- | --- | --- |
| W0 收口 | 现有基线 | 建 `vslight` 分支；写 `dev/smoke.sh`（含负向断言契约）；remove∩patch 审计表；恢复快照与记录目录 | `patches/`、`vscode/` 只读 | 无需构建 | smoke 在当前基线全绿并留档；审计表落盘 |
| W1 | W0 | Phase 1（复用 `SHOULD_BUILD_CLI=no`）+ Phase 2 的 `dev/build.sh` 变量 | **单人 A**：`dev/build.sh` + `build.sh` + `build_cli.sh`（Phase 1/2 同文件） | 1 个 `vscode/` 工作树；一次全量 `./dev/run-build.sh -s`（≈14.5min） | 构建通过；产物无 tunnel 二进制；`SKIP_ASSETS=no` 路径不失败 |
| W2 | W1 | Phase 2 字符串与键处理（含 `updateUrl/downloadUrl`、Help 链接）+ 图标 | **单人 B**：`prepare_vscode.sh`（Phase 2 与 Phase 6 都要改）；**单人 C**：`icons/`、`src/stable/resources/**`（图标待设计交付） | 一次全量构建 + 打开 app | Info.plist/关于框/`--version`/新数据目录；图标 mtime 与目视 |
| W3 | W2 | Phase 3：90 号剪枝 + 91 号摘 import（含 sessions/agentHost 与 server 入口） | **单人 D**：patch 生成独占 `vscode/`，期间禁止他人构建 | patch 生成 → 一次全量构建 | 编译通过；无 `.rej`；Remote/sessions/agentHost 断言 |
| W4 | W3 | Phase 4 串行分批：Debug（含 dirs.ts）→ Notebook → testing/welcome → NLS/mangle/原生模块 → **Chat 最后** | 单写人 D；每批一个号段（92+） | 每批一次全量构建，同一时间只有一个构建 | 每批：编译 + smoke（含负向）+ 装机字节对比 + 保留面回归 |
| W5 | W1/W2/W3 | Phase 6：CI 与平台门禁、更新 URL 与 feed 仓、版本号、发布物清单 | 单人 E：`.github/workflows/`、`update_version.sh`、`release.sh` | 无本地构建需求 | 逐平台入口与验收；`jq .updateUrl`；feed 可解析；一次真实升级 |
| W6 | 独立 clone/worktree | Phase 5 Bun spike | 单人 F；不得与 W3/W4 共享 checkout/node_modules | 独立依赖目录 | ADR + 采纳后任务清单 |
| W7 | W4/W5 | 最终集成与装机验收 | 主 agent 单写计划回写 | 一次发布级构建 + 装机验证 | 干净用户目录走主路径 + 记录落盘 |

---

## 5. 总体结论与修订顺序

### 建议状态：`Blocked`

计划本身未声明状态，Phase 0 显示「部分已完成」，读起来像是可开工。判 `Blocked` 的理由：F-01 会让 Phase 3 首次构建硬失败；F-04/F-05 是两处可证伪的机制/契约错误；F-03 使核心目标「剥离 AI/远程」按现计划无法达成；F-02/F-06/F-07 使收益与验收不可判定。这些不是补充细节，会改变范围、契约与验收口径。

**解除阻塞的可观察条件**：
1. remove∩patch 审计表落盘，且 Phase 3 的删除动作改到 patch 之后（或被命中 patch 已处置）；
2. product.json 的键级操作与 `updateUrl`/feed 仓写入计划；
3. sessions/agentHost（及 `server-main`/`server-cli` 入口）进入范围；
4. 每个 Phase 有可观察退出条件，并有一条端到端装机验收；
5. F-08 的三平台范围由用户裁定；
6. 迁移决策写入 Phase 2。

### 决策罗盘（阻塞解除的三个岔路口）

| 岔路 | 选项 A | 选项 B | 建议默认 | 代价 / 可逆性 |
| --- | --- | --- | --- | --- |
| 交付范围（F-08） | 三平台都发、都验收（每平台 CI + 装机验收，Phase 6 工作量约翻倍） | 对外只发 macOS，决策 7 加注「三平台仅保证可构建，本期验收 = macOS」 | **B** | 代价：非 macOS 发布推迟。可逆：加 CI job + 一次装机验收 |
| 体积是不是 KPI（F-02） | 当 KPI：追 map（本地 −296MB）与源码 MB 排序 | 不当 KPI：按「不产 reh（≈370MB 产物）、不产 CLI、摘掉 sessions/agentHost 入口」记账，验收用装机 JS 字节 | **B** | 理由：CI 发布版本就剥离 map，map 只影响本地/自发布。代价：放弃「体积显著变小」的对外说法。可逆：随时可补 strip-map 开关 |
| AI/远程的完成定义（F-03/F-12） | 物理摘除：sessions 入口 + agentHost 12MB 全清 | 入口与打包摘除：摘 sessions entry 与资源、chat 摘 import，agentHost 深层清理留后 | **A 的入口部分 + B 的深度**：验收只认产物断言（无 `sessions.desktop.main.js`、无 `agentHostMain`、命令面板相应前缀为 0） | 代价：agentHost 残留占体积。可逆：agentHost 可后续单独立项 |

### 修订顺序（先纠正前提/契约，再改设计，再补映射与编排）

1. **前提与契约**：F-05（更新源与 feed）→ F-04（product.json 键操作 + Phase 1/2 顺序）。
2. **设计与范围**：F-01（删除层序）→ F-03（sessions/agentHost/server 入口）→ F-09/F-10（开关复用与 `dirs.ts`、welcome 依赖）。
3. **度量与优先级**：F-02（装机口径 + map）→ F-16/F-17（NLS/mangle 项）。
4. **交付闭环**：F-06（退出条件与装机验收）→ F-07（迁移/首启）→ F-19/F-20/F-21（用户可见面与「纯本地」断言）。
5. **编排与估算**：F-13（门禁与单写人）→ F-14（spike 隔离）→ F-15（工期与依据）→ F-12/F-18/F-23。
6. 需要用户裁定的两项（F-08 平台范围、F-02 体积取舍）在对应阶段开工前给出即可，但会改变第 2/3 步的顺序。

### 就绪判断的说明

本文只评审计划文本与其依赖的代码事实，**不代表功能已实现或可发布**；脚本通过（`check_paths.sh`）不证明行为真实或验收完成；UI/UX 部分为文档推演，需实现后在应用内验收。复审时请沿用 F-01…F-23 编号，并区分「已解决 / 仍存在 / 新增」。