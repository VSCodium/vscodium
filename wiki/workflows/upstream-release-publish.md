---
slug: shadow-ide/workflow/upstream-release-publish
project_slug: shadow-ide
kind: workflow
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
features: [shadow-ide/feature/upstream-vscode-synchronization, shadow-ide/feature/cross-platform-build-and-packaging, shadow-ide/feature/release-and-update-distribution]
components: [shadow-ide/component/github-actions-pipelines, shadow-ide/component/root-build-orchestration, shadow-ide/component/platform-build-packaging, shadow-ide/component/stores-and-package-managers]
actions: [shadow-ide/action/run-release-pipeline]
tags: [release, ci, publish]
---

# Upstream Release Publish

> CI builds and publishes a stable or insider Shadow-IDE release from a selected upstream VS Code revision.

## Trigger

Manual `workflow_dispatch` or repository dispatch events such as `publish-stable` start platform release workflows.

## Steps

1. **Checkout repository** - Workflow checks out the configured branch. (Component: [[components/github-actions-pipelines]])
2. **Clone upstream** - `get_repo.sh` resolves and fetches source. (Component: [[components/upstream-version-metadata]])
3. **Check existing release** - `check_tags.sh` determines whether assets already exist. (Component: [[components/root-build-orchestration]])
4. **Compile base editor** - Platform workflows run `build.sh` or compile reusable artifacts. (Component: [[components/platform-build-packaging]])
5. **Package per platform/arch** - Matrix jobs build Linux, macOS, Windows, CLI, and optional REH assets. (Component: [[components/platform-build-packaging]])
6. **Sign where required** - Windows uses SignPath; macOS uses certificate env in asset preparation. (Integration: [[integrations/signpath-and-codesigning]])
7. **Prepare checksums** - Release assets receive `.sha1` and `.sha256`. (Component: [[components/root-build-orchestration]])
8. **Publish release** - `release.sh` creates/uploads GitHub release assets. (Integration: [[integrations/github-releases-and-actions]])
9. **Update metadata** - `update_version.sh` updates the versions repository. (Workflow: [[workflows/update-service-metadata-publish]])

## Decision points

- If `SHOULD_BUILD` is not `yes`, jobs stop early.
- If architecture is disabled through workflow vars, that matrix item skips.
- If updates are disabled, update-related patching and package variants differ.

## Failure modes

- Upstream source unavailable -> checkout fails.
- Existing assets mismatch -> build may be skipped or forced depending on env.
- Signing approval timeout -> Windows release blocks.
- Release upload failure -> retry path may delete and re-upload assets.
- Versions repo push conflict -> script pulls and retries push.

## Components touched

- [[components/github-actions-pipelines]]
- [[components/root-build-orchestration]]
- [[components/platform-build-packaging]]
- [[components/stores-and-package-managers]]

## Related features

- [[features/upstream-vscode-synchronization]]
- [[features/cross-platform-build-and-packaging]]
- [[features/release-and-update-distribution]]

## Open questions

None at this time.
