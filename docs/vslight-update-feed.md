# vslight 更新源（versions feed）契约

> 状态：**已上线（2026-09-28）**。feed 托管在 `rockie/vslight` 仓的 **orphan 分支 `versions`**
> （与代码历史隔离，效果等同独立仓，无需单独建仓/扩 token）。
> `updateUrl = https://raw.githubusercontent.com/rockie/vslight/refs/heads/versions`；
> 客户端请求 `${updateUrl}/<quality>/<platform>/<arch>/latest.json`。
> 首个 latest.json（1.135.06493，darwin/arm64）已播种并经 curl 验证；
> `dev/seed-versions-feed.sh` 可复用于后续播种/格式参考。
> 构建已移除 `DISABLE_UPDATE=yes`（更新检查开启）。

## 1. 目录布局（`versions` 分支）

由 `update_version.sh` 在发布流程中生成：

```
<quality>/<platform>/<arch>/latest.json
# 例：stable/darwin/arm64/latest.json、stable/linux/x64/latest.json、stable/win32/x64/latest.json
```

## 2. latest.json 字段契约

| 字段 | 含义 | 来源 |
|---|---|---|
| `url` | 该平台安装包下载地址 | `${ASSETS_REPOSITORY}/releases/download/${RELEASE_VERSION}/${ASSET_NAME}` |
| `name` | 发布版本号（如 `1.135.06493`） | `RELEASE_VERSION`；**更新器据此判断新旧** |
| `version` | 构建 commit | `BUILD_SOURCEVERSION` |
| `productVersion` | 上游产品版本（如 `1.135.0`） | `transformVersion ${RELEASE_VERSION}` |
| `sha1hash` | 安装包 sha1 | `<asset>.sha1` |
| `sha256hash` | 安装包 sha256 | `<asset>.sha256` |
| `timestamp` | 毫秒时间戳 | `Date.now()`；**`12-update-add-cooldown.patch` 的更新冷却依赖此字段，缺失则冷却失效** |

七字段均不得为空（`update_version.sh` 有空值守卫）。

## 3. 客户端行为（1.135 核实）

- 更新检查：`updateService` 定时 GET `<updateUrl>/<quality>/<platform>/<arch>/latest.json`。
- `prepare_vscode.sh` 已设置 `updateUrl=https://raw.githubusercontent.com/rockie/versions/refs/heads/master`、
  `downloadUrl=https://github.com/rockie/vslight/releases`（DISABLE_UPDATE 移除后生效）。
- macOS 注意（F-05）：`updateService.darwin.ts:143` 无条件 `autoUpdater.setFeedURL`；
  adhoc 签名下 Squirrel.Mac 自更新**很可能不可用**（需正式签名+公证），首版建议保持
  「检查更新→跳转 releases 页手动下载」语义，签名专项另立。

## 4. 验收（feed 就绪后执行）

「从上一版本检查更新 → 下载 → 安装成功」真实走通一次（Phase 6 任务③），记录落盘。
