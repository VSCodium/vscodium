# remove∩patch 审计表（Phase 3/4 开工前置产物）

> 断言：**remove 集合 ∩ 晚于剪枝阶段执行的 patch 目标 = ∅**
>
> 机制依据（`prepare_vscode.sh`）：
> - L150：`patches/*.json`（apply_actions，rm -rf，路径缺失 exit 4）
> - L156-182：`patches/*.patch`、`patches/insider/`、`patches/$OS_NAME/`、`patches/user/`
> - **vslight light-prune 阶段插入在 L182 之后**（所有 patch 之后）→ 没有任何存量/新增
>   patch 在剪枝之后执行，主断言结构性成立。真正风险是**反向**：存量 patch/json 的目标
>   必须在其执行时点仍存在（剪枝在其后，天然满足）；以及 vslight 自身各剪枝批次之间、
>   剪枝与存量 `*.json`（52/80 号）的先后关系。

## 1. Phase 3 剪枝项 × 存量 patch 命中

| 拟删路径 | 存量命中 | 结论 |
|---|---|---|
| `extensions/vscode-test-resolver` | `00-brand-remove-branding.patch`（package.json、src/download.ts、src/extension.ts）；`build/npm/dirs.ts` 列表项 | patch 先应用→后整目录删，不冲突；dirs.ts 条目随 91 号 patch 删 |
| `extensions/tunnel-forwarding` | `40-cli-use-reh-archive.patch`（src/extension.ts L313-316）；`build/npm/dirs.ts` 列表项 | 同上，不冲突 |
| `src/vs/server` | `00-brand-remove-branding.patch`（server.cli.ts）、`00-remote-disable-client-validation.patch`（remoteExtensionHostAgentServer.ts、serverEnvironmentService.ts）、`00-remote-remove-missing-vsda.patch`（remoteExtensionHostAgentServer.ts） | 同上，不冲突 |
| `cli/` | `40-cli-use-reh-archive.patch`（serve_web.rs、constants.rs、options.rs、agent_host.rs、code_server.rs、paths.rs、update_service.rs 等） | 同上，不冲突；Phase 1 已 `SHOULD_BUILD_CLI=no`，此处只删源码 |

## 2. Phase 4 剪枝项 × 存量 patch 命中

| 批次 | 拟删/拟摘路径 | 存量命中 | 结论 |
|---|---|---|---|
| 1 sessions/agentHost | `src/vs/sessions`、`src/vs/platform/agentHost`（整目录） | `52-ext-copilot-remove-it.json`（agentHost 下 copilot/claude/codex 子路径，先执行，存在即删）；`53-ext-copilot-remove-it.patch`（agentHostOTelService.ts、agentHostContributions.ts、agentHostMain.ts、agentHostServerMain.ts、agentHostServices.ts、agentHostSessionTitleController.ts + dirs.ts） | 52 json 在其时点路径存在（light-prune 未跑）→ 正常；53 patch 正常应用；批次 1 在其后删剩余整目录。**不重复删 52 已删路径**（apply_actions 遇缺失 exit 4，light-prune 只 `rm -rf` 顶层目录，不逐子路径断言） |
| 2 Debug | `extensions/debug-*` 剪枝 + 摘 `contrib/debug` import | `00-brand-remove-branding.patch` 命中 `contrib/debug/browser/debugAdapterManager.ts`、`00-ui-custom-font.patch` 命中 contrib/debug 内 CSS | **contrib 源码不删目录、只摘 import**（UI 级移除），两 patch 目标仍在 → 不冲突；`extensions/debug-*` 目录在 dirs.ts 中无条目（实测 dirs.ts 无 debug 扩展），剪枝安全 |
| 3 Notebook | `extensions/ipynb`、`extensions/notebook-renderers` 剪枝 + 摘 `contrib/notebook` import | `00-brand-remove-branding.patch` 命中 `extensions/notebook-renderers/package.json`；`00-ui-custom-font.patch` 命中 contrib/notebook CSS；dirs.ts 有 `extensions/ipynb`、`extensions/notebook-renderers` | patch 先应用后剪枝不冲突；dirs.ts 两条目随本批 patch 删 |
| 4 testing/welcome/… | 摘 import（不删源码目录） | `00-ui-custom-font.patch` 命中 testing、welcomeAgentSessions CSS；`00-community-add-announcements.patch`、`81-ui-disable-onboarding.patch` 命中 welcomeGettingStarted；`80-ui-disable-onboarding.json` 删 welcomeGettingStarted 内容文件；`prepare_vscode.sh:250` sed `gettingStarted.ts` | 只摘 import 不删源文件 → 全部不冲突；**`gettingStarted.ts` 必须保留**（L250 sed 硬依赖），welcome 仅做入口摘除 |
| 5 policy-watcher | 移除 `@vscodium/policy-watcher` 原生模块 | `21-policy-use-custom-lib.patch` 命中该模块引用点 | 本批 patch 与 21 号的改动点需逐一核对（同一文件的相邻区域，预计可共存；若 hunk 重叠则本批 patch 基于 21 号之后的工作树生成，天然兼容） |
| 6 Chat | 摘 `contrib/chat`、`contrib/inlineChat` import | `00-brand-remove-branding.patch`、`00-copilot-fix-action-condition.patch`、`00-copilot-disable-terminal-suggest.patch`、`00-ui-custom-font.patch` 命中 chat/inlineChat 源文件 | 只摘 import 不删源文件 → 不冲突 |

## 3. 结构性风险记录

1. **`00-ui-custom-font.patch` 触碰面最大**（chat/debug/notebook/remote/testing/welcomeAgentSessions
   等 20 个 contrib 的 CSS）→ Phase 3/4 一律「摘 import + 保留源文件」，不删 contrib 目录，
   该 patch 持续可应用。
2. **`52-ext-copilot-remove-it.json` 在 patches/*.json 阶段执行（L150）**，早于一切 patch 与
   light-prune；其删除路径在批次 1 之前一直存在 → 无 exit 4 风险。若未来把 agentHost 整目录
   前移到 json 阶段删除，会与 52 号重复删除 → 禁止该前移。
3. **`prepare_vscode.sh:250`**（announcements sed）依赖
   `src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts` 存在 → 该文件永保留。
4. **`build/npm/dirs.ts`**：删 `extensions/{ipynb,notebook-renderers,tunnel-forwarding,vscode-test-resolver}`
   必须同步删 dirs.ts 条目（postinstall 会对缺失目录报错）；`src/vs/server` 对应的 `remote`、
   `remote/web` 条目同理（随 Phase 3 处理）。
5. **新增 vslight patch（91+）一律基于「全部存量 patch 已应用」的工作树生成**（dev/patch.sh
   工作流），天然与存量 patch 兼容。

## 4. 断言复核

- remove 集合 ∩ 剪枝后执行的 patch = ∅ —— **成立**（light-prune 位于 prepare_vscode.sh 末尾，
  其后仅有 npm install 与文本替换步骤，无 patch 执行点）。
- 存量 patch/json 目标在其执行时点存在 —— **成立**（剪枝全部后置）。
