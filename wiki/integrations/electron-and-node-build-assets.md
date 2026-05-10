---
slug: shadow-ide/integration/electron-and-node-build-assets
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
vendor: Electron, npm, Node.js, VS Code build assets
protocol: https
auth_via: public package/download endpoints
features: [shadow-ide/feature/cross-platform-build-and-packaging]
components: [shadow-ide/component/platform-build-packaging, shadow-ide/component/root-build-orchestration]
tags: [electron, node, npm, build-assets]
---

# Electron And Node Build Assets

> The build consumes Electron, npm packages, Node tooling, ffmpeg, and architecture-specific binaries.

## Vendor

Electron, npm registry, VS Code build dependencies, and architecture-specific Electron/ripgrep providers.

## Protocol

HTTPS downloads through npm, GitHub releases, and build scripts.

## Auth

Public downloads for normal build dependencies.

## Endpoints used

- npm package registry via `npm ci`.
- Electron release assets and checksums.
- Architecture-specific Electron providers configured under `build/linux/<arch>/electron.sh`.
- `@vscode/openssl-prebuilt` package in `build_cli.sh`.

## What it enables

- [[features/cross-platform-build-and-packaging]]

## Failure modes

- Dependency download failure -> npm retry loops may fail.
- Electron version mismatch -> Linux packaging can abort.
- Architecture-specific binary unavailable -> target architecture cannot package.

## Components

- [[components/platform-build-packaging]]
- [[components/root-build-orchestration]]

## Open questions

None at this time.
