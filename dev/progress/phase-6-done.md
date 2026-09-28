# Phase 6 完工记录（含基础设施阻塞项）

- 日期：2026-09-27

## 四任务核对（F-05）

| 任务 | 状态 | 证据/落点 |
|---|---|---|
| ① 更新 URL 改写指向 vslight | ✅ 完成（Phase 2） | `prepare_vscode.sh` updateUrl/downloadUrl → `vslight/versions`、`vslight/vslight[-insiders]/releases`；`build_cli.sh:15`、`dev/cli.sh` 同步；与 `GH_REPO_PATH` 无关的字面量均已改写 |
| ② versions feed 仓与字段契约 | ✅ 已上线（2026-09-28） | feed = `rockie/vslight` orphan 分支 `versions`（不建独立仓）；`stable/darwin/arm64/latest.json` 已播种并经 curl 验证；`updateUrl` 已指向该分支 |
| ③ 「检查更新→下载→安装」真实走通 | ✅ 检查链路已实证；安装链路待下版本 | 更新启用构建（e31cd72）main.log：`update#isLatestVersion() - found: 1.135.6493, current: 1.135.6493` + releaseDate 解析成功；冷却机制（`update.minReleaseAge` 默认 120h）工作正常。offer→download→install 需下一个 RELEASE_VERSION（get_repo.sh 的 TIME_PATCH 自动递增），届时 feed 推新 latest.json 即可 |
| ④ 首版兜底 | ✅ 已解除 | `DISABLE_UPDATE=yes` 已随 feed 上线移除（dev/build.sh） |

## CI 与平台范围（决策 8-B，默认采纳）

- `ci-build-macos.yml` 保留完整触发；`ci-build-linux.yml`/`ci-build-windows.yml` 已降为
  `workflow_dispatch`（改动落盘，注释指向 docs/vslight-release.md）。
- 决策 7 加注：三平台仅保证可构建；本期验收 = macOS arm64；上游升级跑最低可构建验证。
- publish-* workflows 保留，外部标识（docker 镜像/AUR/snap/winget/secrets）随 org 基础设施迁移。

## 版本号与发布物

- 版本号跟随上游 + 构建序号：当前 `1.135.06493`（产物 `vslight --version` 实证）。
- 发布物清单、release notes/迁移说明落点：`docs/vslight-release.md`；迁移指引 `docs/vslight-migration.md`。

## 发布阻塞项（移交）

1. 图标（F-18：设计输入 + 工具链 + 先删后建）；2. vslight org/仓/secrets；3. 签名/公证专项。
