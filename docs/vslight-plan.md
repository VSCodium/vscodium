# VSLight 轻量化改造开发计划

> 目标：基于 VSCodium 打造一个**纯本地代码编辑器** —— 保留「编辑 / 文件 / 搜索 / Git / 扩展」核心，
> 剥离远程开发、AI Chat 等非编辑功能，rebrand 为 **vslight**。
>
> 基线：VSCodium master（上游 VS Code 1.135.0，commit `08d4889`），macOS arm64 构建已验证通过。

---

## 0. 设计原则

1. **改动分层，由浅入深**：构建开关 → product.json 配置 → JSON remove 动作 → `.patch` 源码补丁。
   能用前一层解决的绝不用后一层（patch 越少，跟随上游的成本越低）。
2. **一个功能一个 patch**：每个裁剪项独立成 patch 文件，冲突时可单独禁用/重建
   （项目已有先例：`*.patch.no` 后缀即禁用）。
3. **UI 级移除优先，API 层保留 stub**：不追求物理删除所有代码，而是从
   `workbench.*.main.ts` 的 import 列表摘除 contribution。未被 import 的代码
   不会进入 esbuild 产物 —— 体积收益是真实的，且避免了 `src/vs/workbench/api`（6.1MB）
   层大面积手术。
4. **每阶段可验收**：`npm run compile` 通过 + 冒烟清单 + 构建产物体积对比。

## 1. 现状分析（实测数据）

### 1.1 裁剪对象与成本估算

| 模块 | 位置 | 源码体积 | 耦合度 | 移除方式 |
|---|---|---|---|---|
| REH 远程服务端 | `vscode/src/vs/server` + 产物 `vscode-reh-*` | 332K | 无 | **构建开关** `SHOULD_BUILD_REH=no` |
| Rust CLI (tunnel) | `vscode/cli/` | 构建产物 311MB | 无 | **跳过 `build_cli.sh`**（省 5-10 min Rust 编译） |
| 远程客户端/Explorer | `workbench/contrib/remote`、`services/remote` | 312K | 中 | patch 摘 import + stub |
| Remote Tunnels | `contrib/remoteTunnel`、`platform/remoteTunnel`、electron-main | 36K | 中 | patch |
| Remote Coding Agents | `contrib/remoteCodingAgents`、`platform/agentHost` | 8K | 中 | patch（vscodium 已部分清理） |
| **Chat / AI** | `contrib/chat` + `inlineChat` | **21MB** | **高**（菜单/设置/欢迎页耦合） | patch，风险最高 |
| Notebook | `contrib/notebook` + `extensions/ipynb`、`notebook-renderers` | 4.2MB | 中 | patch + JSON remove |
| Debug（整体） | `contrib/debug` | 2.0MB | 中 | patch + product.json 去掉 3 个内置调试扩展 |
| Terminal | `contrib/terminal` + `terminalContrib` + `terminal-suggest` | 2.3MB | 中 | patch（**待讨论**） |
| 内置调试扩展 | `ms-vscode.js-debug` 等 3 个（product.json `builtInExtensions`，构建时下载） | — | 无 | vscodium 根 `product.json` merge 覆盖 |
| ~~低频语言扩展~~ | ~~`extensions/` 下 ~40 个~~ | — | — | **已撤下**（决策 6：全保留） |
| ~~主题包~~ | ~~`extensions/theme-*`~~ | — | — | **已撤下**（决策 6：全保留） |
| ~~认证扩展~~ | ~~`microsoft-authentication`、`github-authentication`~~ | — | — | **已撤下**（决策 6：全保留） |
| NLS 多语言 | 构建产物 14 种语言 | — | 无 | patch `build/lib/i18n` 只保留 en（+zh-CN） |
| policy-watcher 原生模块 | `@vscodium/policy-watcher`（node-gyp 编译） | — | 低 | patch 移除（顺带消除上次 util-linux 头文件冲突点） |

参考：全量 `out-build` 当前 **407MB**，`VSCodium.app` **1.0GB**。

### 1.2 远程功能挂载点（patch 时需要动的 import）

- `src/vs/workbench/workbench.common.main.ts`：L108-110（remote services）、L350-351、L429
- `src/vs/workbench/workbench.desktop.main.ts`：L79-84（tunnel/remote services）、L96（agentHost）、L143、L185、L189
- `src/vs/code/electron-main/`：`remote/`、`remoteTunnel/`、`tunnel/` 三个目录的注册点
- 内置扩展：`vscode-test-resolver`、`tunnel-forwarding`（JSON remove 即可）

## 2. 阶段计划

### Phase 0 — 基线（0.5 天）✅ 部分已完成

- [x] 全量构建跑通（node 24.18.0 / python3.12 / 隔离 util-linux 环境变量，`dev/run-build.sh`）
- [ ] 创建工作分支 `vslight`，后续所有改动落在 vscodium 仓库层（**不改 `vscode/` 子目录**，只加 patch）
- [ ] 冒烟脚本 `dev/smoke.sh`：启动 app → `--version` → 打开文件 → 搜索 → Git 状态，输出 PASS/FAIL

### Phase 1 — 构建级裁剪（0.5 天，零 patch）

改动 `dev/build.sh` / `build.sh`：

```bash
export SHOULD_BUILD_REH="no"        # 不产 vscode-reh-darwin-arm64
export SHOULD_BUILD_REH_WEB="no"    # 不产 vscode-reh-web
export SKIP_CLI="yes"               # 新增开关：跳过 build_cli.sh（Rust CLI）
```

- `build_cli.sh` 调用点加 `SKIP_CLI` 守卫（macOS/Linux/Windows 三处）
- **收益**：构建时间 -10~15 min，产物少两个 reh 包、无 `vslight-tunnel` 二进制
- 验收：构建通过；`VSCode-darwin-arm64/` 下无 tunnel 二进制

### Phase 2 — Rebrand 为 vslight（1-2 天）

品牌字符串集中在三处（patch 的 `!!TOKEN!!` 体系会自动跟随，无需逐个改 patch）：

1. **`dev/build.sh` 环境变量**：
   `APP_NAME="VSLight"`、`BINARY_NAME="vslight"`、`ORG_NAME="vslight"`、
   `GH_REPO_PATH`/`ASSETS_REPOSITORY` 指向新仓库
2. **`prepare_vscode.sh` 的 setpath 段**（66 处 codium 引用）：
   `nameShort/nameLong="VSLight"`、`applicationName="vslight"`、
   `dataFolderName=".vslight"`、`urlProtocol="vslight"`、
   `darwinBundleIdentifier="com.vslight"`；*同时删掉* `serverApplicationName`、
   `tunnelApplicationName`、所有 `win32Tunnel*`、`serverDataFolderName`（Phase 3 不再需要）
3. **图标**：
   - 设计 vslight 图标 → `icons/build_icons.sh` 重新生成（需 imagemagick/png2icns/librsvg）
   - 替换 `src/stable/resources/darwin/code.icns` 及 `resources/server/`、`resources/linux/` 图标
4. **残留品牌检查**：`rg -i "codium" --type-add 'b:*.icns' -g '!*.icns' -g '!*.png'` 全仓扫描；
   注意硬编码字符串 patch（如 `00-ui-report-issue.patch`）中的仓库 URL

- 验收：`Info.plist` 的 `CFBundleName/CFBundleIdentifier`；关于框；`vslight --version`；
  数据目录 `~/Library/Application Support/VSLight`、`~/.vslight`

### Phase 3 — 远程功能剥离（2-4 天）

按 §1.2 挂载点做两个新文件：

**`patches/90-light-remove-remote.json`**（remove 动作，删目录零 patch）：
`extensions/vscode-test-resolver`、`extensions/tunnel-forwarding`、`src/vs/server`、`cli/`

**`patches/91-light-remove-remote.patch`**：
- `workbench.common.main.ts` / `workbench.desktop.main.ts`：摘除 remote/tunnel/agentHost imports
- `src/vs/code/electron-main/main.ts` 及 `app.ts`：摘除 remote/remoteTunnel/tunnel 服务注册
- 迭代修编译错误：`npm run compile` → grep 引用点 → 逐一处理
- **保留 stub**：`remoteExtensionsScanner` 被扩展管理服务依赖、`vscode-remote://` 协议解析
  需保留一个"报错误导"的最小实现，避免扩展 API 层连锁反应
- `product.json` 中 remote/tunnel 相关 key 在 prepare_vscode.sh 阶段已删（Phase 2.2）

- 验收：编译通过；Remote Explorer 消失；`vslight tunnel` 命令不存在；
  打开 `vscode-remote://` 链接给出友好报错

### Phase 4 — 深度裁剪（3-6 天，按优先级逐项推进，每项独立 patch + 冒烟）

| 优先级 | 项 | 预期收益 | 风险 |
|---|---|---|---|
| P0 | Chat/AI 移除（21MB，产物中占比更大） | 大 | **高** |
| P0 | Debug 整体移除 + 3 个内置调试扩展 ✅ 已确认 | 中 | 中 |
| P1 | Notebook 移除 | 中 | 中 |
| P1 | testing / welcome / feedback / issue reporter / merge editor / profiles / speech | 中 | 低-中 |
| P2 | NLS 只保留 en（+zh-CN） | 小 | 低 |
| P2 | 重新启用 mangle（禁用 `00-build-disable-mangle.patch`） | 体积/启动 | 低 |
| P2 | 原生模块修剪：policy-watcher 等 | 构建稳定性 | 低 |

Chat 移除说明：1.135 中 chat 与菜单、设置 schema、欢迎页、状态栏深度耦合，
预计 50+ 处引用。策略是从 `workbench.*.main.ts` 摘 import 后按编译错误逐个击破，
引用点多为可选注册（menu/registry），用条件注释或空实现处理。
**若上游耦合持续加重，该 patch 允许降级为"隐藏入口"而非物理摘除。**

### Phase 5 — Bun 替代 Node 可行性（1-2 天 spike，限时）

**先说结论（基于架构分析）**：

| 场景 | 可行性 | 说明 |
|---|---|---|
| 桌面运行时 | ❌ 不可能 | VS Code 桌面端 = Electron（内嵌 Node.js）+ 从 Electron fork 的扩展宿主进程。Bun 无法替换 Electron 内嵌的 Node；扩展生态（`require('vscode')` + Node API）全部假定 Node 运行时 |
| REH 服务端 | ⬜ 无意义 | Phase 1 已删除，没有可替换的对象 |
| 构建工具链 | ⚠️ 可实验 | `bun install` 替代 `npm ci`；`bun gulp` 跑任务（1.135 构建脚本已是 TS，Bun 原生支持，理论上比 `node --experimental-strip-types` 更顺） |

构建链 spike 的**已知障碍**：
- ~30 个原生模块走 node-gyp，需要 Node/Electron 头文件（与 Bun 运行时无关，该省不掉）
- `package-lock.json` vs `bun.lock`；`.npmrc` 中 electron `disturl` 下载逻辑
- 收益预估：install 阶段 ~10 min → 3-4 min；对全量构建（~25 min）占比有限

**判定标准**：全量构建通过 + 产物冒烟一致 → 保留；否则放弃，不影响主线。

### Phase 6 — CI / 发布（1-2 天）

- 精简 `.github/workflows/`：只保留 macOS（+需要的平台），接 `SHOULD_BUILD_REH=no`
- 签名：本地 adhoc；对外分发再考虑 Apple Developer 签名 + notarize
- 版本号策略（建议）：跟随上游 `1.135.x`，加 vslight 构建序号
- 更新机制 ✅ 已定：**自建 GitHub releases 源** —— `GH_REPO_PATH`/`ASSETS_REPOSITORY` 指向 vslight 仓库后，
  复用 `11-update-use-github-release.patch` + `12-update-add-cooldown.patch`；
  release 产物命名与 `updateUrl` feed（`VSCodium/versions` 仓格式）对齐

## 3. 时间线总览

```
Phase 0   ▌0.5d   基线与冒烟脚本          (部分完成)
Phase 1   ▌0.5d   构建开关裁剪            ← 立即见效
Phase 2   ▌1-2d   rebrand vslight
Phase 3   ▌2-4d   远程功能剥离
Phase 4   ▌3-6d   深度裁剪(chat/debug/notebook…)
Phase 5   ▌1-2d   Bun spike(可并行/可裁)
Phase 6   ▌1-2d   CI 与发布
          ─────
          约 9-17 个工作日(Phase 5 不占关键路径)
```

## 4. 风险与回退

- **patch 冲突**（跟随上游时）：用项目自带 `dev/update_patches.sh` 工作流修复；
  单个 patch 可重命名为 `.patch.no` 临时禁用。
- **chat 耦合超预期** → 降级为隐藏 UI 入口（settings + menu 清理），后续版本再物理摘除。
- **裁剪后发现某功能刚需** → 对应 patch/json 条目移除即可恢复，架构上无不可逆改动。
- 每次上游升级前：先在独立分支 `vslight-rebase-1.13x` 验证 patch 应用，再合入。

## 5. 已确认的决策

1. ~~Debug 范围~~ → **整个调试子系统全删**（contrib/debug + 3 个内置调试扩展 + debug-auto-launch/debug-server-ready），纯编辑器不留本地调试
2. ~~Terminal~~ → **保留**（集成终端属编辑器核心体验；连带 `tasks` 任务系统也保留）
3. ~~Git 扩展~~ → **保留**
4. ~~扩展机制~~ → **保留**（open-vsx 市场 + 扩展宿主不动）
5. ~~更新机制~~ → **自建 GitHub releases 源**（保留 `11-update-use-github-release.patch`，指向 vslight 仓库）
6. ~~语言/主题修剪~~ → **全保留**，从裁剪清单撤下（低频语言扩展、主题包、认证扩展均不删）
7. ~~目标平台~~ → **保留三平台构建能力**（macOS/Linux/Windows），patch 尽量平台无关

## 5.1 决策对计划的影响

- Phase 4 裁剪表更新：P0 = Chat/AI、Debug；P1 = Notebook、testing/welcome 等（`tasks` 随 Terminal 保留）；**移除**「低频语言/主题/认证扩展」「Terminal」行
- Phase 6：`GH_REPO_PATH`/`ASSETS_REPOSITORY` 指向 vslight 仓库后，`11-update-use-github-release.patch` 与 `12-update-add-cooldown.patch` 直接复用，无需 DISABLE_UPDATE
- patch 编写约束：不得使用 macOS 专有条件编译规避问题，三平台 `npm run compile` 都要过
