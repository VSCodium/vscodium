---
slug: shadow-ide/overview/index
project_slug: shadow-ide
kind: overview
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [index, navigation, shadow-ide]
---

# Index - Shadow-IDE Knowledge Base

> Master navigation for the Shadow-IDE kbmap. This wiki maps the current repository as a VS Code/VSCodium-derived build, branding, patching, packaging, and release system.

## Overview

- [[project-discovery]] - What Shadow-IDE is in this repository, what is present, and what still needs care.
- [[code-structure]] - Folder tree, file inventory, and ownership map.
- [[mapping-log]] - Chronological record of this knowledge-base adoption and first mapping pass.

## Architecture

- [[architecture/overview]] - Build and release architecture from upstream VS Code source to published artifacts.
- [[architecture/tech-stack]] - Languages, tools, services, CI runners, and package formats.
- [[decisions/adopt-kbmap-in-repo]] - ADR for keeping kbmap files inside Shadow-IDE.
- [[decisions/track-upstream-vscode-by-scripted-overlay]] - ADR for the scripted overlay/patch model.
- [[decisions/use-open-vsx-gallery-by-default]] - ADR for default extension-gallery behavior.

## Features

- [[features/upstream-vscode-synchronization]] - Select, clone, and pin upstream VS Code source revisions.
- [[features/product-branding-and-assets]] - Apply product identity, icon overlays, and platform resources.
- [[features/telemetry-and-service-hardening]] - Remove telemetry and unwanted Microsoft service hooks.
- [[features/extension-marketplace-control]] - Configure extension gallery, proposed API, and extension policy behavior.
- [[features/cross-platform-build-and-packaging]] - Build Linux, macOS, Windows, CLI, and remote-extension-host artifacts.
- [[features/release-and-update-distribution]] - Publish assets and update metadata.
- [[features/developer-local-build-flow]] - Run local development builds and patch repair workflows.
- [[features/knowledge-base-read-side-access]] - Query this wiki through the generated read-only MCP server.

## Components

- [[components/root-build-orchestration]] - Top-level scripts that fetch, prepare, build, package, release, and update versions.
- [[components/upstream-version-metadata]] - `upstream/*.json` and version derivation.
- [[components/vscode-overlay-and-product-metadata]] - `src/`, `product.json`, announcements, and product mutation.
- [[components/patch-set]] - Repository patch inventory and patch application rules.
- [[components/platform-build-packaging]] - `build/linux`, `build/osx`, and `build/windows`.
- [[components/github-actions-pipelines]] - Publish, CI, lint, stale, and moderation workflows.
- [[components/assets-icons-and-branding]] - `icons/`, generated resources, and store assets.
- [[components/documentation-site]] - `docs/` and user/operator documentation.
- [[components/font-size-generator]] - TypeScript helper for UI font-size patch generation.
- [[components/stores-and-package-managers]] - Snapcraft, WinGet, MSI, AppImage, deb/rpm, tar, zip, and dmg metadata.
- [[components/wiki-mcp-server]] - Installed read-only MCP server for this knowledge base.

## Workflows

- [[workflows/local-development-build]] - Run a local Shadow-IDE/VSCodium build.
- [[workflows/upstream-release-publish]] - Publish a stable/insider release from upstream selection to release assets.
- [[workflows/patch-refresh-after-upstream-change]] - Repair patches when upstream VS Code changes.
- [[workflows/update-service-metadata-publish]] - Update the versions repository used by update checks.
- [[workflows/knowledge-base-maintenance]] - Keep this wiki synchronized after repo changes.

## Integrations

- [[integrations/microsoft-vscode-source]] - Upstream source repository and update API.
- [[integrations/github-releases-and-actions]] - GitHub Actions, releases, artifacts, and repository dispatch.
- [[integrations/open-vsx-registry]] - Default extension gallery and extension-control feed.
- [[integrations/electron-and-node-build-assets]] - Electron, Node, npm, Playwright, ffmpeg, and platform build assets.
- [[integrations/signpath-and-codesigning]] - Windows SignPath and macOS certificate signing.
- [[integrations/package-manager-ecosystem]] - External package manager metadata and stores.

## Actions

- [[actions/run-dev-build]] - CLI contract for `./dev/build.sh`.
- [[actions/run-upstream-fetch]] - CLI contract for `./get_repo.sh`.
- [[actions/run-release-pipeline]] - CLI contract for `./release.sh`.
- [[actions/generate-icons]] - CLI contract for `./icons/build_icons.sh`.
- [[actions/query-wiki-mcp]] - Read-only MCP query contract for this wiki.

## Glossary

- [[glossary/quality]] - Stable vs insider build track.
- [[glossary/upstream-commit]] - The selected VS Code source revision.
- [[glossary/release-version]] - Shadow-IDE/VSCodium release version derived from upstream plus build time.
- [[glossary/reh]] - Remote extension host artifacts.
- [[glossary/overlay]] - Files copied over upstream VS Code before patching.
- [[glossary/patch-set]] - Repository patches applied to upstream VS Code.
- [[glossary/open-vsx]] - Open VSX extension registry.

## Mapping Status

| Section | Status |
|---------|--------|
| Bootstrap install | complete |
| Folder tree | complete |
| File inventory | complete |
| Tech stack | complete |
| Architecture diagram | complete |
| Component pages | complete |
| Feature pages | complete |
| Workflow pages | complete |
| Integration pages | complete |
| Action contracts | complete |
| Decisions | complete |
| Glossary | complete |
| Manifest generation | complete |

## Notes

The repository remote is `https://github.com/arimacmini1/Shadow-IDE.git`, but many tracked files still name VSCodium as the default product identity. Where that matters, pages call out the current state and the expected Shadow-IDE branding handoff explicitly.
