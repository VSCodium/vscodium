---
slug: shadow-ide/component/upstream-version-metadata
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "upstream/"
features: [shadow-ide/feature/upstream-vscode-synchronization, shadow-ide/feature/release-and-update-distribution]
workflows: [shadow-ide/workflow/upstream-release-publish]
tags: [upstream, versioning, vscode]
---

# Upstream Version Metadata

> Stable and insider JSON pins define which VS Code source revision Shadow-IDE builds.

## Purpose

The upstream metadata prevents release builds from floating unexpectedly. It also gives `get_repo.sh` a deterministic commit when `VSCODE_LATEST` is not enabled.

## Source Location

`upstream/`

## Key Files

| File | Purpose |
|------|---------|
| `upstream/stable.json` | Stable VS Code tag/commit pin. |
| `upstream/insider.json` | Insider VS Code tag/commit pin. |

## How It Works

When `RELEASE_VERSION` is absent and `VSCODE_LATEST` is not `yes`, `get_repo.sh` reads the matching quality file. If latest mode is enabled, it calls the VS Code update API and may update the upstream JSON during local dev builds.

## Error Handling

If a requested explicit `RELEASE_VERSION` cannot be matched to the upstream pin, `get_repo.sh` exits with an error. If a tag cannot be found or parsed, it also aborts.

## Dependencies

### Depends On

- [[integrations/microsoft-vscode-source]]

### Used By

- [[components/root-build-orchestration]]
- [[components/github-actions-pipelines]]

## Data Flow

`upstream/<quality>.json` -> `get_repo.sh` -> exported `MS_TAG`/`MS_COMMIT`/`RELEASE_VERSION`.

## API / Interface

JSON fields: `tag` and `commit`.

## Open Questions

None at this time.

## Related Pages

- [[glossary/upstream-commit]]
- [[glossary/release-version]]
- [[project-discovery]]
- [[index]]
