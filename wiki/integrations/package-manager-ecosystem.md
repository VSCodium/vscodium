---
slug: shadow-ide/integration/package-manager-ecosystem
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
vendor: Snapcraft, WinGet, package managers
protocol: https
auth_via: store-specific credentials outside the core scripts
features: [shadow-ide/feature/release-and-update-distribution]
components: [shadow-ide/component/stores-and-package-managers, shadow-ide/component/platform-build-packaging]
tags: [snapcraft, winget, package-managers]
---

# Package Manager Ecosystem

> External package-manager channels consume release assets and store metadata.

## Vendor

Snapcraft, WinGet, AppImage consumers, deb/rpm repositories, Homebrew/Chocolatey/Scoop-style package channels, and related ecosystems.

## Protocol

HTTPS release asset downloads and store-specific publication protocols.

## Auth

Publication credentials are store-specific and not fully represented in this repo.

## Endpoints used

- Snapcraft YAML under `stores/snapcraft`.
- WinGet version helper under `stores/winget`.
- GitHub release asset URLs produced by [[components/root-build-orchestration]].

## What it enables

- [[features/release-and-update-distribution]]

## Failure modes

- Store metadata lags release assets -> users see outdated package versions.
- Asset naming drift -> store manifests point at missing files.
- Store-specific review failure -> GitHub release exists but package channel is delayed.

## Components

- [[components/stores-and-package-managers]]
- [[components/platform-build-packaging]]

## Open questions

None at this time.
