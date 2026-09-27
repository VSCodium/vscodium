# vslight 发布清单（Phase 6 落点）

## 决策记录（沿用计划默认）

- **决策 8（平台交付范围）：B —— 只发 macOS**。决策 7 加注：三平台仅保证可构建
  （patch 不含平台专有条件），本期验收范围 = macOS arm64；上游升级时跑最低验证点
  （linux/windows 各一次可构建验证）。
- **决策 9（sourcemap）：不当 KPI**。体积收益记账口径 = 不产 reh+CLI、摘 sessions/agentHost
  入口、摘 debug/notebook 等 contribution；验收用装机 JS 字节。
- **决策 10（纯本地边界）**：① 断网可完成主路径（编辑/文件/搜索/Git/终端）；
  ② 外发连接仅 open-vsx 与自建更新源（当前更新源关闭，仅剩 open-vsx）；
  ③ 无账号/设置同步参与主路径（认证扩展仅按需被动触发）。
- 版本号：跟随上游 `1.135.x` + vslight 构建序号（当前 `1.135.06493`）。

## 发布物清单（macOS）

| 物 | 状态 |
|---|---|
| `VSLight-macos-arm64-<ver>.zip`（或 dmg） | 构建产出（prepare_assets.sh，`-p` 开关） |
| `vslight-cli-...` / `vslight-reh-...` | **不发布**（CLI/reh 已裁） |
| checksums（sha1/sha256） | prepare_checksums.sh 产出 |
| release notes | 落点：GitHub releases 页面（`vslight/vslight`） |
| 迁移说明 | 落点：docs/vslight-migration.md + release notes 首段链接 |
| versions feed `latest.json` | 待 feed 仓（docs/vslight-update-feed.md） |

## 首次发布前置（阻塞项）

1. **图标**：旧 VSCodium 图标源已删除，当前为**统一占位标**（蓝底白 V，见
   `docs/vslight-icons.md`）——旧品牌零残留，可发布但视觉为过渡态；正式设计按
   icons 文档流程替换（含 letterpress 底纹四变体）。验收 = Dock/关于框/底纹目视。
2. **vslight GitHub org/仓**：发布仓 + versions 仓 + secrets/docker 镜像/AUR/snap/winget
   标识的新归属（当前 workflow 中保留 VSCodium 外部标识，见 Phase 2 残留清单）。
3. 签名/公证：macOS 分发签名与自更新可用性专项（docs/vslight-update-feed.md §3）。

## CI 范围（决策 B 落地）

- `ci-build-macos.yml`：保留完整触发。
- `ci-build-linux.yml` / `ci-build-windows.yml`：降为 `workflow_dispatch` 手动触发
  （保证可构建能力，不纳入发布验收）。
- publish-* workflows：随 vslight org 基础设施启用（当前保留但外部标识未迁移）。
