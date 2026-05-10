---
slug: shadow-ide/component/assets-icons-and-branding
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "icons/, src/*/resources/"
features: [shadow-ide/feature/product-branding-and-assets]
workflows: [shadow-ide/workflow/local-development-build, shadow-ide/workflow/upstream-release-publish]
tags: [icons, branding, assets]
---

# Assets Icons And Branding

> Source and generated image resources provide app icons, file-type icons, server favicons, Windows installer bitmaps, and workbench media.

## Purpose

Branding resources make the built editor recognizable on each platform. They must match product identifiers from [[components/vscode-overlay-and-product-metadata]].

## Source Location

`icons/`, `src/stable/resources/`, `src/insider/resources/`, and `build/windows/msi/resources/`.

## Key Files

| File | Purpose |
|------|---------|
| `icons/build_icons.sh` | Generates macOS, Linux, Windows, server, and workbench media assets. |
| `icons/stable/*.svg` | Stable source SVG icons. |
| `icons/insider/*.svg` | Insider source SVG icons. |
| `src/*/resources/*` | Platform resources copied into upstream checkout. |
| `build/windows/msi/resources/*` | Windows MSI banner/dialog images. |

## How It Works

`icons/build_icons.sh` uses ImageMagick, `rsvg-convert`, `png2icns`, `icotool`, and related tools to create platform assets only when destination files are missing. It can target stable or insider quality and can use prefixes for generated output paths.

## Error Handling

The script exits if required image tools are missing. Generated assets are cached by existence, so deleting a destination is the usual way to force regeneration.

## Dependencies

### Depends On

- [[components/vscode-overlay-and-product-metadata]]

### Used By

- [[components/platform-build-packaging]]
- [[features/product-branding-and-assets]]

## Data Flow

Source SVG/PNG -> icon generator -> `src/<quality>/resources` and MSI resources -> overlay copy -> platform packages.

## API / Interface

CLI: `./icons/build_icons.sh` with optional `-i` for insider and env overrides such as `COLOR`, `SRC_PREFIX`, and `VSCODE_PREFIX`.

## Open Questions

None at this time.

## Related Pages

- [[actions/generate-icons]]
- [[features/product-branding-and-assets]]
- [[glossary/quality]]
- [[index]]
