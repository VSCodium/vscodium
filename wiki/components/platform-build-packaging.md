---
slug: shadow-ide/component/platform-build-packaging
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "build/"
features: [shadow-ide/feature/cross-platform-build-and-packaging, shadow-ide/feature/release-and-update-distribution]
workflows: [shadow-ide/workflow/upstream-release-publish]
tags: [linux, macos, windows, packaging]
---

# Platform Build Packaging

> Platform directories package prepared VS Code output into releaseable Linux, macOS, Windows, CLI, and REH artifacts.

## Purpose

This component handles platform-specific build constraints, package formats, architecture quirks, and staging files.

## Source Location

`build/linux/`, `build/osx/`, `build/windows/`, plus top-level `prepare_assets.sh`.

## Key Files

| File | Purpose |
|------|---------|
| `build/linux/package_bin.sh` | Repackages compiled Linux source per target architecture. |
| `build/linux/prepare_assets.sh` | Creates Linux release assets. |
| `build/linux/appimage/build.sh` | AppImage packaging. |
| `build/windows/package.sh` | Windows package build after compile artifact download. |
| `build/windows/prepare_assets.sh` | Windows release assets. |
| `build/windows/msi/*.sh` | MSI build variants. |
| `build/osx/prepare_assets.sh` | macOS zip/dmg/signing preparation. |

## How It Works

CI compiles a reusable `vscode.tar.gz` artifact for Linux/Windows, then architecture-specific packaging jobs unpack it and rebuild native pieces as needed. macOS builds directly on macOS runners. `prepare_assets.sh` delegates platform-specific asset preparation and then packages CLI/REH outputs.

## Error Handling

Scripts abort on failure. Linux architecture-specific electron/ripgrep files guard unusual targets such as ppc64le, riscv64, and loong64. Windows signing and MSI steps can fail independently of base build.

## Dependencies

### Depends On

- [[components/root-build-orchestration]]
- [[components/assets-icons-and-branding]]
- [[integrations/electron-and-node-build-assets]]
- [[integrations/signpath-and-codesigning]]

### Used By

- [[components/github-actions-pipelines]]
- [[features/cross-platform-build-and-packaging]]

## Data Flow

Prepared `vscode/` -> platform gulp packaging -> `VSCode-*` directories -> asset scripts -> checksummed release files.

## API / Interface

Main entry points: `./build/linux/package_bin.sh`, `./build/windows/package.sh`, `./prepare_assets.sh`, and platform `prepare_assets.sh` files.

## Open Questions

None at this time.

## Related Pages

- [[features/cross-platform-build-and-packaging]]
- [[workflows/upstream-release-publish]]
- [[glossary/reh]]
- [[index]]
