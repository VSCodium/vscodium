---
slug: shadow-ide/action/run-dev-build
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
executable: true
endpoint: "./dev/build.sh [flags]"
endpoint_kind: cli
auth_required: false
auth_via:
confirmation_required: true
idempotent: false
side_effects: [local_execution, filesystem_write, network]
feature: shadow-ide/feature/developer-local-build-flow
dry_run_supported: false
dry_run_param:
test_mode_supported: false
test_mode_param:
live_execution_requires_approval: true
tags: [build, cli, local]
---

# Run Dev Build

> Runs the local development build helper for stable/insider, pinned/latest, build/package, and skip modes.

## Description

`./dev/build.sh` orchestrates local source cleanup/fetch, environment export, build, and optional asset preparation. It can delete generated `vscode*` and `VSCode*` directories, run networked dependency installs, and produce large outputs.

## Endpoint

CLI: `./dev/build.sh [flags]`

## Parameters

### Required

None.

### Optional

| Name | Type | Description |
|------|------|-------------|
| `-i` | flag | Build insider quality. |
| `-l` | flag | Use latest upstream VS Code. |
| `-o` | flag | Skip build step. |
| `-p` | flag | Generate packages/assets/installers. |
| `-s` | flag | Skip source fetch and reuse existing source/build env. |

## Side effects

- Deletes and recreates generated build directories in normal source mode.
- Fetches upstream source and installs dependencies.
- Writes `dev/build.env`, build outputs, and optionally assets/checksums.

## Safety gates

- Live execution requires explicit operator approval.
- No dry-run mode exists.
- Inspect worktree status first and avoid running during unrelated local build work.

## Errors

- Missing dependency -> exits during setup/build.
- Patch failure -> exits during `prepare_vscode.sh`.
- npm/network failure -> exits after retries.

## Linked feature

[[features/developer-local-build-flow]]

## Notes for the assistant

Ask before running. For diagnosis, prefer reading logs and scripts first because this action is heavy.
