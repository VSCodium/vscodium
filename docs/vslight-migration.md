# 从 VSCodium / VS Code 迁移到 VSLight

VSLight 是独立产品：**不承诺原地迁移**。首次启动时它使用全新的数据目录，旧版
VSCodium/VS Code 的设置、扩展、键位不会自动出现。旧目录**原样保留、不会被修改或删除**，
可随时按下表手动搬迁。

## 1. 数据目录对照（macOS）

| 内容 | VSCodium | VSLight |
|---|---|---|
| 用户设置/键位/片段 | `~/Library/Application Support/VSCodium/User` | `~/Library/Application Support/VSLight/User` |
| 扩展 | `~/.vscode-oss/extensions` | `~/.vslight/extensions` |
| 深链协议 | `vscodium://` | `vslight://` |
| 命令行 | `codium` | `vslight` |

Linux：`~/.config/VSCodium` → `~/.config/VSLight`；Windows：`%APPDATA%\VSCodium` → `%APPDATA%\VSLight`。

## 2. 设置 / 键位 / 任务 / 片段（手动拷贝）

只需拷贝 `User` 目录下的以下条目（存在才拷）：

```bash
OLD="$HOME/Library/Application Support/VSCodium/User"
NEW="$HOME/Library/Application Support/VSLight/User"
mkdir -p "$NEW"
for f in settings.json keybindings.json tasks.json snippets; do
  [[ -e "$OLD/$f" ]] && cp -R "$OLD/$f" "$NEW/$f"
done
```

不要整目录拷贝 `User/`（其中的 `globalStorage`、`workspaceStorage`、`Cached*` 与新版本/新数据目录不兼容）。

## 3. 扩展（导出清单 → 重装）

不直接拷贝扩展目录，用清单重装（保证拿到与新版本匹配的构建）：

```bash
# 旧机/旧产品导出
codium --list-extensions > extensions.txt
# 新机重装（逐个从 open-vsx 安装）
cat extensions.txt | xargs -L 1 vslight --install-extension
```

注意：

- 依赖远程开发的扩展（Remote-SSH / Dev Containers / WSL / Tunnels 类）在 VSLight
  **不可用**——VSLight 不支持远程开发（`vscode-remote://` 会给出可读报错）。
- 调试器扩展（js-debug 等内置调试子系统已移除）安装后不会有调试入口。
- AI Chat 类扩展（Copilot Chat 等）无宿主入口。

## 4. 失效说明

- `codium` CLI 不再随 VSLight 提供；请使用 `vslight`。
- `vscodium://` 深链失效；系统需重新关联 `vslight://`。
- VSLight 不支持：`vslight tunnel`、远程服务器（reh）、调试（Debug）、AI Chat、Notebook。

## 5. 首启发现性

首次启动打开 Welcome 页，其中「迁移指引」链接指向本文件。设置同步（Settings Sync）
不参与主路径；账号认证类扩展仅按需被动触发。
