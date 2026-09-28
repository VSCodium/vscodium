# Phase 6 完工记录（含基础设施阻塞项）

- 日期：2026-09-27

## 四任务核对（F-05）

| 任务 | 状态 | 证据/落点 |
|---|---|---|
| ① 更新 URL 改写指向 vslight | ✅ 完成（Phase 2） | `prepare_vscode.sh` updateUrl/downloadUrl → `vslight/versions`、`vslight/vslight[-insiders]/releases`；`build_cli.sh:15`、`dev/cli.sh` 同步；与 `GH_REPO_PATH` 无关的字面量均已改写 |
| ② versions feed 仓与字段契约 | ✅ 已上线（2026-09-28） | feed = `rockie/vslight` orphan 分支 `versions`（不建独立仓）；`stable/darwin/arm64/latest.json` 已播种并经 curl 验证；`updateUrl` 已指向该分支 |
| ③ 「检查更新→下载→安装」真实走通 | ✅ 2026-09-28 除最后点击外全程实证（见下） | 更新启用构建（e31cd72）main.log：`update#isLatestVersion() - found: 1.135.6493, current: 1.135.6493` + releaseDate 解析成功；冷却机制（`update.minReleaseAge` 默认 120h）工作正常。offer→download→install 需下一个 RELEASE_VERSION（get_repo.sh 的 TIME_PATCH 自动递增），届时 feed 推新 latest.json 即可 |
| ④ 首版兜底 | ✅ 已解除 | `DISABLE_UPDATE=yes` 已随 feed 上线移除（dev/build.sh） |

### 任务③ 验收实录（2026-09-28，release 1.135.06493 → 1.135.06523）

- 完整构建（fresh clone，TIME_PATCH 自动递增）→ 签名公证 → `gh release create 1.135.06523` →
  `dev/update-feed.sh 1.135.06523 2`（timestamp 回拨 2h 过冷却）→ 旧客户端（/tmp/vsl-old，06493）实测：
  ```
  update#doCheckForUpdates {url: .../versions/stable/darwin/arm64/latest.json, background: true}
  update#isLatestVersion() - found: 1.135.6523, current: 1.135.6493
  update#isLatestVersion() - releaseAge: 2, minReleaseAge: 1   ← 冷却通过
  update#setState downloading → downloaded → ready             ← 276MB 实网下载完成
  ```
  ShipIt 缓存（~/Library/Caches/com.vslight.ShipIt）已建。最后一步「Restart to Update」点击
  属标准 Squirrel.Mac 流程，由用户目视确认（本终端无 AX 权限）。
- 注：notarytool 的 `set -x` 回显会把 App 专用密码写入本地 build.log（`.gitignore:23` 已豁免，
  未入库；属本机文件，共享日志前注意）。

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
