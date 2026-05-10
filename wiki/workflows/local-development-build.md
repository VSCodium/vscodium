---
slug: shadow-ide/workflow/local-development-build
project_slug: shadow-ide
kind: workflow
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
features: [shadow-ide/feature/developer-local-build-flow, shadow-ide/feature/upstream-vscode-synchronization, shadow-ide/feature/cross-platform-build-and-packaging]
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/vscode-overlay-and-product-metadata, shadow-ide/component/patch-set, shadow-ide/component/platform-build-packaging]
actions: [shadow-ide/action/run-dev-build, shadow-ide/action/run-upstream-fetch]
tags: [local-build, developer]
---

# Local Development Build

> Developer runs a local build to validate the current repository against upstream VS Code.

## Trigger

A maintainer needs to test source preparation, patch application, build output, or platform packaging locally.

## Steps

1. **Prepare environment** - Install dependencies from `docs/howto-build.md`. (Component: [[components/documentation-site]])
2. **Choose flags** - Select stable/insider, latest/pinned, skip-source, skip-build, or package generation options. (Component: [[components/root-build-orchestration]])
3. **Fetch upstream** - `./dev/build.sh` calls `get_repo.sh` unless source is skipped. (Component: [[components/upstream-version-metadata]])
4. **Prepare source** - `build.sh` calls `prepare_vscode.sh` to overlay, patch, install dependencies, and clean telemetry. (Component: [[components/vscode-overlay-and-product-metadata]])
5. **Build editor** - Upstream gulp tasks create platform outputs. (Component: [[components/platform-build-packaging]])
6. **Optionally package assets** - `-p` runs `prepare_assets.sh`. (Component: [[components/platform-build-packaging]])

## Decision points

- If `-i` is set, use insider quality; otherwise stable.
- If `-l` is set, use latest upstream; otherwise pinned `upstream/*.json`.
- If a patch fails, switch to [[workflows/patch-refresh-after-upstream-change]].

## Failure modes

- Missing toolchain -> build stops before or during dependency install.
- Patch drift -> `git apply` fails in `prepare_vscode.sh`.
- npm/network failure -> retry loops may exhaust.
- Platform packaging prerequisites missing -> package step fails after base build.

## Components touched

- [[components/root-build-orchestration]]
- [[components/vscode-overlay-and-product-metadata]]
- [[components/patch-set]]
- [[components/platform-build-packaging]]

## Related features

- [[features/developer-local-build-flow]]
- [[features/upstream-vscode-synchronization]]
- [[features/cross-platform-build-and-packaging]]

## Open questions

None at this time.
