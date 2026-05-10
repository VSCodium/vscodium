---
slug: shadow-ide/feature/developer-local-build-flow
project_slug: shadow-ide
kind: feature
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/root-build-orchestration, shadow-ide/component/documentation-site]
actions: [shadow-ide/action/run-dev-build]
workflows: [shadow-ide/workflow/local-development-build, shadow-ide/workflow/patch-refresh-after-upstream-change]
tags: [developer, local-build, patching]
---

# Developer Local Build Flow

> Developers can run local source fetch, prepare, build, package, and patch-repair flows.

## Purpose

Local builds let maintainers validate changes before publishing or debugging CI-only failures.

## User-visible behavior

This is developer-facing. The entry point is `./dev/build.sh`, with flags for insider/latest/package/skip phases.

## Components used

- [[components/root-build-orchestration]]
- [[components/documentation-site]]

## Actions exposed

- [[actions/run-dev-build]]

## Related workflows

- [[workflows/local-development-build]]
- [[workflows/patch-refresh-after-upstream-change]]

## Open questions

None at this time.

## Notes for the assistant

Local builds are heavy, networked, and can delete generated `vscode*` / `VSCode*` directories. Confirm intent and inspect current worktree state before running.
