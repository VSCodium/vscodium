# vslight 图标与底纹

> 状态：**正式设计已上线（2026-09-28）**。设计源 `icons/app-icon.svg`
> （浅色圆角底 + 代码尖括号 + 蓝色闪电，「light」双关）。旧的 VSCodium 图标源
> 与过渡占位标已全部移除，无品牌残留。

## 资产链（全部由设计源生成）

| 资产 | 位置 | 生成方式 |
|---|---|---|
| 主 SVG（已剥离 C2PA 元数据，3KB） | `icons/{stable,insider}/vslight.svg` | `icons/app-icon.svg` 去 metadata |
| macOS app + 文档图标（27×.icns） | `src/{stable,insider}/resources/darwin/*.icns` | `rsvg-convert` 多尺寸 + `iconutil` |
| Windows 图标（.ico + 70/150 png） | `src/{stable,insider}/resources/win32/` | rsvg + 纯 Python PNG-in-ICO |
| Linux 图标（code.png/code.svg） | `src/{stable,insider}/resources/linux/` | rsvg 1024 + 主 SVG |
| workbench code-icon.svg | `src/{stable,insider}/src/vs/workbench/browser/media/` | 主 SVG |
| 编辑器底纹 letterpress ×4 | `src/{stable,insider}/src/vs/workbench/browser/parts/editor/media/` | 设计稿闪电路径，单色低透明度（dark 0.3 / light 0.1 / hcDark #3C3C3C / hcLight #B2B2B2），40x40 |
| `icons/template_macos.png`、各仓 png/ico | icons/ | rsvg 1024 / 纯 Python ICO |

## 工具链

- `rsvg-convert`（`brew install librsvg`，已装）——SVG 栅格化
- `iconutil`（macOS 自带）——icns 打包
- `sips`（macOS 自带）——缩放
- 纯 Python ICO 写入（无需 icoutils）
- `icons/build_icons.sh` 全量流程另需 `icns2png/png2icns/composite/icotool`
  （`brew install icnsutils imagemagick icoutils`），日常替换用上面的精简链即可

## 再生成流程（设计修订时）

1. 更新 `icons/app-icon.svg`，剥离 metadata 覆盖 `icons/{stable,insider}/vslight.svg`
2. rsvg 出 1024/512/256/128/64/48/32/24/16 + 150/70 → iconutil 打 icns → python 打 ICO
3. 覆盖上表全部槽位（先删旧 `code.icns` 再生成，build_icons.sh 对已存在文件会整段跳过）
4. 全量构建验收：产物 icns sha 对比 + Dock/关于框/编辑器底纹目视
