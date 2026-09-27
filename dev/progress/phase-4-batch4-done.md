# Phase 4 批 4（95 testing/welcome/issue/profiles）完工记录

- 提交：`95-light-remove-testing-welcome.patch`（三次 DI 链修正迭代）
- 验收：全量构建 EXIT 0；patch 无失败；无 .rej

## 断言证据

| 断言 | 证据 |
|---|---|
| 对应入口不存在 | testing/welcome(gettingStarted+walkthrough+agentSessions)/issue reporter(Help 菜单命令)/profiles UI 的 contribution import 已摘 |
| gettingStarted.ts 兼容 | 文件保留在磁盘，`prepare_vscode.sh:250` announcements sed 正常（构建日志无 sed 错误） |
| 应用可启动 | renderer.log Render performance baseline=1；无 DI 错误（仅已记录 tunnelHost 超时） |
| dirs.ts 检查 | 本批无扩展剪枝，dirs.ts 无变化 |
| 装机 JS | 26.9MB → 26.3MB |

## 保留决策（计划内核实项）

- **merge editor 保留**：Git 扩展硬依赖（`git.openMergeEditor` 命令、`mergeEditor.acceptMerge`
  提交流程、`git.mergeEditor` 设置、TabInputTextMerge API）——计划要求的「删除前核实」结论为不可删。
- **speech 保留**：`ISpeechService` 无自有 UI，是保留功能（编辑器听写/终端语音/无障碍信号）的
  引擎注册；删除会破坏保留面。
- **viewsWelcome/newFile 保留**：承载保留视图（Explorer 等）的空态内容与「New File」入口。
- **onboarding 保留**：vscodium 自建首启面（80/81 号 patch 产物），首启迁移指引的落点。
- **remoteUserDataProfiles 保留**：保留的扩展管理服务注入它（DI）。

## DI 链修正沉淀（批 6 参考）

issue 服务链三层：`IWorkbenchIssueService → IIssueFormService → IGitHubUploadService`。
新建 `issue.service.contribution.ts` 一次注册三件套（链终于 githubUploadService，仅依赖
log/nativeHost）。**方法论**：保留服务时必须先展平其构造注入闭包。
