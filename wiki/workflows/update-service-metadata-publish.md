---
slug: shadow-ide/workflow/update-service-metadata-publish
project_slug: shadow-ide
kind: workflow
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
features: [shadow-ide/feature/release-and-update-distribution]
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/github-actions-pipelines, shadow-ide/component/upstream-version-metadata]
actions: [shadow-ide/action/run-release-pipeline]
tags: [updates, versions, metadata]
---

# Update Service Metadata Publish

> Publish `latest.json` metadata for platform update checks after release assets exist.

## Trigger

`update_version.sh` runs after `release.sh` in publish workflows or when `FORCE_UPDATE=true`.

## Steps

1. **Verify build intent and credentials** - Script exits if no build/update should occur or credentials are missing. (Component: [[components/root-build-orchestration]])
2. **Resolve version context** - Ensure `RELEASE_VERSION`, `BUILD_SOURCEVERSION`, and asset names are available. (Component: [[components/upstream-version-metadata]])
3. **Clone versions repo** - Clone `VERSIONS_REPOSITORY`. (Integration: [[integrations/github-releases-and-actions]])
4. **Generate platform JSON** - Create `latest.json` with asset URL, version, productVersion, hashes, and timestamp. (Component: [[components/root-build-orchestration]])
5. **Commit and push** - Push changed metadata to the versions repository. (Integration: [[integrations/github-releases-and-actions]])

## Decision points

- If `CURRENT_VERSION` already equals `RELEASE_VERSION`, skip unless forced.
- Asset names differ by OS, architecture, quality, and package type.

## Failure modes

- Missing asset/checksum -> script downloads or fails if unavailable.
- Push race -> script pulls and retries.
- Bad release version format -> script exits before writing metadata.

## Components touched

- [[components/root-build-orchestration]]
- [[components/github-actions-pipelines]]
- [[components/upstream-version-metadata]]

## Related features

- [[features/release-and-update-distribution]]

## Open questions

None at this time.
