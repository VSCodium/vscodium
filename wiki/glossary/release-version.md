---
slug: shadow-ide/glossary/release-version
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [release, versioning]
---

# Release Version

> The version string used in release assets and update metadata.

## Term

**Release version**

## Definition

`RELEASE_VERSION` is either provided explicitly or generated from the upstream VS Code tag plus a day/hour patch counter. Insider builds append `-insider`.

## Used in

- [[components/root-build-orchestration]] - exports and consumes `RELEASE_VERSION`.
- [[features/release-and-update-distribution]] - names assets and update metadata.
- [[workflows/update-service-metadata-publish]] - writes platform `latest.json`.

## Related terms

- [[glossary/upstream-commit]]
- [[glossary/quality]]

## Notes

`update_version.sh` transforms release versions into a product version form for update metadata.
