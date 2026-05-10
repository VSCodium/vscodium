---
slug: shadow-ide/component/stores-and-package-managers
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "stores/"
features: [shadow-ide/feature/cross-platform-build-and-packaging, shadow-ide/feature/release-and-update-distribution]
workflows: [shadow-ide/workflow/upstream-release-publish]
tags: [snapcraft, winget, packages]
---

# Stores And Package Managers

> Store metadata and packaging helper scripts support Snapcraft, WinGet, and external package-manager distribution.

## Purpose

This component holds packaging metadata outside the core platform build scripts. It helps releases appear in package-manager ecosystems after artifacts are built.

## Source Location

`stores/`

## Key Files

| File | Purpose |
|------|---------|
| `stores/snapcraft/stable/snap/snapcraft.yaml` | Stable snap package metadata. |
| `stores/snapcraft/insider/snap/snapcraft.yaml` | Insider snap package metadata. |
| `stores/snapcraft/*/snap/hooks/configure` | Snap configure hooks. |
| `stores/winget/check_version.sh` | WinGet version check helper. |
| `stores/snapcraft/check_version.sh` | Snapcraft version check helper. |

## How It Works

Snapcraft metadata points package generation at generated release assets. WinGet helpers check version publication state. These files complement release assets rather than replacing `release.sh`.

## Error Handling

Store publishing failures are separate from GitHub release upload. Version check scripts should be run before updating external store metadata.

## Dependencies

### Depends On

- [[components/platform-build-packaging]]
- [[integrations/package-manager-ecosystem]]

### Used By

- [[features/release-and-update-distribution]]

## Data Flow

Release assets -> store metadata/version checks -> external package manager publication.

## API / Interface

Shell scripts and store-specific YAML/hook files.

## Open Questions

None at this time.

## Related Pages

- [[integrations/package-manager-ecosystem]]
- [[features/release-and-update-distribution]]
- [[index]]
