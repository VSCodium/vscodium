---
slug: shadow-ide/component/github-actions-pipelines
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: ".github/workflows/"
features: [shadow-ide/feature/cross-platform-build-and-packaging, shadow-ide/feature/release-and-update-distribution]
workflows: [shadow-ide/workflow/upstream-release-publish, shadow-ide/workflow/update-service-metadata-publish]
tags: [github-actions, ci, release]
---

# GitHub Actions Pipelines

> GitHub workflow files run CI checks and publish stable/insider artifacts across platforms.

## Purpose

The workflows are the production automation layer. They decide whether to build, set platform env, run compile/package jobs, sign artifacts, publish releases, and update versions metadata.

## Source Location

`.github/workflows/`

## Key Files

| File | Purpose |
|------|---------|
| `publish-stable-linux.yml` | Stable Linux release and REH flow. |
| `publish-stable-macos.yml` | Stable macOS x64/arm64 release flow. |
| `publish-stable-windows.yml` | Stable Windows x64/arm64 release and signing flow. |
| `publish-insider-*.yml` | Insider equivalents. |
| `ci-build-*.yml` | CI build checks. |
| `lint-zizmor.yml` | Workflow security/static linting. |

## How It Works

Workflows set product/build env, check out the repo, set up Node/Python/Rust/toolchain dependencies, run root scripts, pass artifacts between jobs, and publish outputs. Most external writes happen in publish workflows, not PR CI.

## Error Handling

`check_tags.sh` can stop a workflow early when assets already exist. Packaging failures fail their job. Windows signing waits for SignPath and can time out after manual approval windows.

## Dependencies

### Depends On

- [[components/root-build-orchestration]]
- [[components/platform-build-packaging]]
- [[integrations/github-releases-and-actions]]
- [[integrations/signpath-and-codesigning]]

### Used By

- [[features/release-and-update-distribution]]
- [[workflows/upstream-release-publish]]

## Data Flow

Workflow dispatch -> check job -> compile job -> package/sign/release jobs -> versions update.

## API / Interface

Triggered by `workflow_dispatch` and repository dispatch events such as `publish-stable` or insider equivalents.

## Open Questions

None at this time.

## Related Pages

- [[architecture/overview]]
- [[features/release-and-update-distribution]]
- [[integrations/github-releases-and-actions]]
- [[index]]
