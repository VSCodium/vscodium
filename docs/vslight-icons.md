# vslight 图标与底纹（当前为占位设计）

> 状态：**占位（placeholder）**。旧的 VSCodium 图标源已删除（`icons/*/codium_*.svg`），
> 正式设计就绪前，全量品牌位图/矢量资产使用统一占位标（蓝底白 V + 浅蓝模块）。
> 正式设计落地后本文件需同步更新。

## 当前占位资产（已全部替换，无旧品牌残留）

| 资产 | 位置 | 生成方式 |
|---|---|---|
| 主 SVG 源 | `icons/stable/vslight.svg`、`icons/insider/vslight.svg` | 手写（保留为设计参考起点） |
| macOS app + 文档图标（27×.icns） | `src/{stable,insider}/resources/darwin/*.icns` | `sips` 缩放 + `iconutil` |
| Windows 图标（.ico + 70/150 png） | `src/{stable,insider}/resources/win32/` | 纯 Python PNG-in-ICO |
| Linux 图标（code.png/code.svg） | `src/{stable,insider}/resources/linux/` | 同上 PNG + 主 SVG |
| workbench code-icon.svg | `src/{stable,insider}/src/vs/workbench/browser/media/` | 主 SVG |
| 编辑器底纹 letterpress ×4 | `src/{stable,insider}/src/vs/workbench/browser/parts/editor/media/` | 手写 V 字形低透明度 SVG（dark 0.3 / light 0.1 / hc 两色，沿用原透明度规范） |
| `icons/template_macos.png`、`corner_512.png` | icons/ | 占位 PNG（build_icons.sh 合成源） |

## 正式设计落地流程（替换占位时执行）

1. 将正式主 SVG 覆盖 `icons/stable/vslight.svg` 与 `icons/insider/vslight.svg`
   （insider 应有区分度变体；底纹图案同步设计 `letterpress-*.svg` 四变体）。
2. 装工具链：`brew install icnsutils imagemagick librsvg icoutils`
   （icns2png/png2icns/composite/icotool/rsvg-convert；build_icons.sh 全部需要）。
3. 删除生成物再跑脚本（`build_icons.sh` 对已存在的 code.icns 会整段跳过——先删旧）：
   `rm src/{stable,insider}/resources/darwin/code.icns && ./icons/build_icons.sh`
4. 验收：产物 mtime 更新 + Dock/关于框/编辑器底纹目视（Phase 7 UAT 项 4）。
