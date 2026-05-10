---
slug: shadow-ide/integration/github-releases-and-actions
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
vendor: GitHub
protocol: https
auth_via: GITHUB_TOKEN, GH_TOKEN, or stronger repository token in CI secrets
features: [shadow-ide/feature/cross-platform-build-and-packaging, shadow-ide/feature/release-and-update-distribution]
components: [shadow-ide/component/github-actions-pipelines, shadow-ide/component/root-build-orchestration]
tags: [github-actions, releases, artifacts]
---

# GitHub Releases And Actions

> GitHub hosts CI workflows, build artifacts, release assets, and update metadata pushes.

## Vendor

GitHub - repository hosting, Actions runner execution, release asset hosting, artifacts, and repository dispatch.

## Protocol

HTTPS APIs and Git over HTTPS.

## Auth

CI uses `GITHUB_TOKEN`, `GH_TOKEN`, `GH_ENTERPRISE_TOKEN`, or stronger repository tokens. Release and versions writes require write credentials.

## Endpoints used

- GitHub Actions workflow runtime.
- `gh release view/create/edit/upload/download`.
- Git clone/push for `VERSIONS_REPOSITORY`.
- GitHub REST release API via `curl` in `check_tags.sh`.

## What it enables

- [[features/cross-platform-build-and-packaging]]
- [[features/release-and-update-distribution]]

## Failure modes

- Missing token -> release/update scripts exit early.
- Rate limit or API error -> release checks fail.
- Artifact upload/download failure -> packaging job cannot proceed.
- Push race -> versions update retries after pull.

## Components

- [[components/github-actions-pipelines]]
- [[components/root-build-orchestration]]

## Open questions

None at this time.
