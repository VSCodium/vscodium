# vslight 更新源（versions feed）契约

> 状态：**待基础设施**（需要 GitHub `vslight` org 下的 `versions` 仓与 `vslight` 发布仓）。
> 在 feed 就绪前，构建以 `DISABLE_UPDATE=yes` 兜底（dev/build.sh），更新服务完全关闭
> （main.log 可见 `updates are disabled as there is no update URL`）。
> feed 就绪后：移除 `DISABLE_UPDATE`，`prepare_vscode.sh` 已指向
> `https://raw.githubusercontent.com/vslight/versions/refs/heads/master`。

## 1. 目录布局（`vslight/versions` 仓）

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
- `prepare_vscode.sh` 已设置 `updateUrl=https://raw.githubusercontent.com/vslight/versions/refs/heads/master`、
  `downloadUrl=https://github.com/vslight/vslight/releases`（DISABLE_UPDATE 移除后生效）。
- macOS 注意（F-05）：`updateService.darwin.ts:143` 无条件 `autoUpdater.setFeedURL`；
  adhoc 签名下 Squirrel.Mac 自更新**很可能不可用**（需正式签名+公证），首版建议保持
  「检查更新→跳转 releases 页手动下载」语义，签名专项另立。

## 4. 验收（feed 就绪后执行）

「从上一版本检查更新 → 下载 → 安装成功」真实走通一次（Phase 6 任务③），记录落盘。
