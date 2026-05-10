---
slug: shadow-ide/integration/signpath-and-codesigning
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
vendor: SignPath, Apple code signing
protocol: https
auth_via: GitHub Actions secrets and signing certificates
features: [shadow-ide/feature/cross-platform-build-and-packaging, shadow-ide/feature/release-and-update-distribution]
components: [shadow-ide/component/github-actions-pipelines, shadow-ide/component/platform-build-packaging]
tags: [signing, windows, macos]
---

# SignPath And Codesigning

> Windows and macOS release assets use external signing credentials and services.

## Vendor

SignPath signs Windows artifacts. macOS asset preparation uses certificate secrets and keychain cleanup.

## Protocol

HTTPS service calls and local certificate/keychain operations in CI.

## Auth

GitHub Actions secrets: SignPath API token/configuration and macOS certificate IDs/passwords/P12 data/team ID.

## Endpoints used

- `signpath/github-action-submit-signing-request` in Windows workflows.
- macOS certificate env consumed by `prepare_assets.sh` and `build/osx/prepare_assets.sh`.

## What it enables

- [[features/cross-platform-build-and-packaging]]
- [[features/release-and-update-distribution]]

## Failure modes

- Missing signing secret -> signing step fails.
- Manual approval not completed -> Windows signing times out.
- Keychain cleanup failure -> runner hygiene issue after macOS build.

## Components

- [[components/github-actions-pipelines]]
- [[components/platform-build-packaging]]

## Open questions

None at this time.
