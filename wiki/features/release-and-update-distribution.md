---
slug: shadow-ide/feature/release-and-update-distribution
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/github-actions-pipelines, shadow-ide/component/stores-and-package-managers, shadow-ide/component/upstream-version-metadata]
actions: [shadow-ide/action/run-release-pipeline]
workflows: [shadow-ide/workflow/upstream-release-publish, shadow-ide/workflow/update-service-metadata-publish]
tags: [release, updates, github]
---

# Release And Update Distribution

> Release scripts publish checksummed artifacts and update metadata so clients and package channels can find the latest build.

## Purpose

This feature connects build outputs to users: GitHub releases host assets, and update metadata describes platform-specific latest versions.

## User-visible behavior

Users download release assets directly or receive update metadata depending on build configuration. If updates are disabled, update-disable patching changes the runtime behavior.

## Components used

- [[components/root-build-orchestration]]
- [[components/github-actions-pipelines]]
- [[components/stores-and-package-managers]]
- [[components/upstream-version-metadata]]

## Actions exposed

- [[actions/run-release-pipeline]]

## Related workflows

- [[workflows/upstream-release-publish]]
- [[workflows/update-service-metadata-publish]]

## Open questions

None at this time.

## Notes for the assistant

Never run release or update commands casually. They require credentials and can create, upload, delete, or overwrite external release/update state.
