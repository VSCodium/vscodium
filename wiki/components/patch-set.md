---
slug: shadow-ide/component/patch-set
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "patches/"
features: [shadow-ide/feature/telemetry-and-service-hardening, shadow-ide/feature/extension-marketplace-control, shadow-ide/feature/cross-platform-build-and-packaging]
workflows: [shadow-ide/workflow/patch-refresh-after-upstream-change, shadow-ide/workflow/upstream-release-publish]
tags: [patches, upstream, maintenance]
---

# Patch Set

> Ordered patch files encode Shadow-IDE/VSCodium behavior changes against upstream VS Code.

## Purpose

The patch set keeps this repo close to upstream while preserving product-specific behavior. It is the main place to change upstream code without maintaining a full forked source tree.

## Source Location

`patches/`

## Key Files

| File | Purpose |
|------|---------|
| `patches/*.patch` | Shared patches applied to every build. |
| `patches/insider/*.patch` | Insider-only patches. |
| `patches/linux/**/*.patch` | Linux and Linux-client-specific patches. |
| `patches/windows/*.patch` | Windows-specific patches. |
| `patches/osx/*.patch` | macOS-specific patches. |
| `patches/user/*.patch` | User-supplied local patches. |

## How It Works

`prepare_vscode.sh` calls `apply_patch` from `utils.sh`. `apply_patch` substitutes placeholders such as `!!APP_NAME!!`, `!!BINARY_NAME!!`, `!!GH_REPO_PATH!!`, and `!!RELEASE_VERSION!!`, then runs `git apply --ignore-whitespace` against the prepared upstream checkout.

## Error Handling

A failed patch aborts the build. The documented repair path is [[workflows/patch-refresh-after-upstream-change]], using `./dev/update_patches.sh` or `./dev/patch.sh <name>.patch`.

## Dependencies

### Depends On

- [[components/upstream-version-metadata]]
- [[components/root-build-orchestration]]

### Used By

- [[components/vscode-overlay-and-product-metadata]]
- [[features/telemetry-and-service-hardening]]
- [[features/extension-marketplace-control]]

## Data Flow

`patches/**/*.patch` -> placeholder substitution -> `git apply` -> prepared `vscode/` source.

## API / Interface

Patch files use standard Git patch format with optional repository placeholders handled by `utils.sh`.

## Open Questions

None at this time.

## Related Pages

- [[glossary/patch-set]]
- [[workflows/patch-refresh-after-upstream-change]]
- `docs/patches.md`
- [[index]]
