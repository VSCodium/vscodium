---
slug: shadow-ide/component/documentation-site
project_slug: shadow-ide
kind: component
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "docs/"
features: [shadow-ide/feature/developer-local-build-flow, shadow-ide/feature/extension-marketplace-control, shadow-ide/feature/telemetry-and-service-hardening]
workflows: [shadow-ide/workflow/local-development-build, shadow-ide/workflow/patch-refresh-after-upstream-change]
tags: [docs, support, operator-guide]
---

# Documentation Site

> Markdown docs explain installation, migration, usage, build, extensions, telemetry, troubleshooting, and patch behavior.

## Purpose

The docs directory is the human-facing reference surface for users, contributors, and build operators.

## Source Location

`docs/`

## Key Files

| File | Purpose |
|------|---------|
| `docs/index.md` | Documentation landing page. |
| `docs/howto-build.md` | Dependencies and build instructions. |
| `docs/extensions.md` | Extension gallery behavior and marketplace guidance. |
| `docs/telemetry.md` | Telemetry posture and settings. |
| `docs/patches.md` | Patch-specific documentation. |
| `docs/troubleshooting.md` | Known user/operator failure cases. |

## How It Works

Docs are simple Markdown files, usually linked from `README.md` and release/support flows. They should be updated when build behavior, product defaults, or user-visible marketplace/security policies change.

## Error Handling

There is no docs build step in the current repo. Broken links are handled by review and wiki maintenance rather than a dedicated docs linter.

## Dependencies

### Depends On

- [[components/root-build-orchestration]]
- [[components/patch-set]]

### Used By

- [[features/developer-local-build-flow]]
- [[features/extension-marketplace-control]]

## Data Flow

Source behavior -> documentation updates -> user/operator guidance.

## API / Interface

Markdown links from `README.md` and direct file reads.

## Open Questions

None at this time.

## Related Pages

- [[features/developer-local-build-flow]]
- [[workflows/patch-refresh-after-upstream-change]]
- [[index]]
