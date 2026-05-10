---
slug: shadow-ide/action/generate-icons
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
executable: true
endpoint: "./icons/build_icons.sh [flags]"
endpoint_kind: cli
auth_required: false
auth_via:
confirmation_required: true
idempotent: true
side_effects: [local_execution, filesystem_write, network]
feature: shadow-ide/feature/product-branding-and-assets
dry_run_supported: false
dry_run_param:
test_mode_supported: false
test_mode_param:
live_execution_requires_approval: true
tags: [icons, branding, cli]
---

# Generate Icons

> Generates missing platform icon resources from source SVG/PNG assets.

## Description

`icons/build_icons.sh` creates macOS `.icns`, Linux PNG/XPM, Windows ICO/BMP/PNG, server icons, and workbench media for the selected quality. It may download upstream VSCodium icon assets if local loader functions are not overridden.

## Endpoint

CLI: `./icons/build_icons.sh [flags]`

## Parameters

### Required

None.

### Optional

| Name | Type | Description |
|------|------|-------------|
| `-i` | flag | Generate insider assets. |
| `COLOR` | env | Source color variant. |
| `SRC_PREFIX` | env | Output prefix. |
| `VSCODE_PREFIX` | env | Input source prefix. |

## Side effects

- Writes generated resources under `src/<quality>/resources`, workbench media, and MSI resources.
- May perform network downloads for icon source files.

## Safety gates

- Confirmation required if running in the tracked repo because it can create many binary assets.
- No dry-run mode exists.

## Errors

- Missing image tools -> exits.
- Missing upstream `vscode/resources` inputs -> type icon generation may be incomplete.

## Linked feature

[[features/product-branding-and-assets]]

## Notes for the assistant

Prefer targeted regeneration by deleting intended generated outputs first. Review binary file churn carefully.
