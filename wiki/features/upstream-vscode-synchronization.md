---
slug: shadow-ide/feature/upstream-vscode-synchronization
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/upstream-version-metadata]
actions: [shadow-ide/action/run-upstream-fetch]
workflows: [shadow-ide/workflow/upstream-release-publish, shadow-ide/workflow/local-development-build]
tags: [upstream, vscode, release]
---

# Upstream VS Code Synchronization

> Shadow-IDE can select and fetch the exact upstream VS Code commit used for a build.

## Purpose

This feature gives the project reproducible upstream input. A build operator can use a pinned stable/insider revision or ask the scripts to discover the latest upstream revision.

## User-visible behavior

For users, this appears as Shadow-IDE tracking a recognizable VS Code version. For developers, the entry point is `get_repo.sh` through local build or CI workflows.

## Components used

- [[components/root-build-orchestration]]
- [[components/upstream-version-metadata]]

## Actions exposed

- [[actions/run-upstream-fetch]]

## Related workflows

- [[workflows/upstream-release-publish]]
- [[workflows/local-development-build]]

## Open questions

None at this time.

## Notes for the assistant

When a user asks "what VS Code version is this based on?", cite `upstream/stable.json` or `upstream/insider.json` and [[glossary/upstream-commit]].
