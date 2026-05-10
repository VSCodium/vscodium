---
slug: shadow-ide/feature/cross-platform-build-and-packaging
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/platform-build-packaging, shadow-ide/component/github-actions-pipelines, shadow-ide/component/stores-and-package-managers]
actions: [shadow-ide/action/run-dev-build]
workflows: [shadow-ide/workflow/local-development-build, shadow-ide/workflow/upstream-release-publish]
tags: [build, packaging, linux, macos, windows]
---

# Cross-platform Build And Packaging

> Shadow-IDE can produce platform artifacts for Linux, macOS, Windows, CLI, and remote extension hosts.

## Purpose

This feature turns prepared upstream source into installable or distributable outputs across the supported platform matrix.

## User-visible behavior

Users receive release assets such as zip, dmg, deb, rpm, AppImage, snap, tar.gz, exe, msi, CLI tarballs, and remote host tarballs depending on platform and architecture.

## Components used

- [[components/root-build-orchestration]]
- [[components/platform-build-packaging]]
- [[components/github-actions-pipelines]]
- [[components/stores-and-package-managers]]

## Actions exposed

- [[actions/run-dev-build]]

## Related workflows

- [[workflows/local-development-build]]
- [[workflows/upstream-release-publish]]

## Open questions

None at this time.

## Notes for the assistant

When a build fails, locate the phase first: upstream fetch, prepare/patch, dependency install, compile, platform package, signing, release upload, or versions update.
