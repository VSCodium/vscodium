---
slug: shadow-ide/action/run-upstream-fetch
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
executable: true
endpoint: ". ./get_repo.sh"
endpoint_kind: cli
auth_required: false
auth_via:
confirmation_required: true
idempotent: false
side_effects: [local_execution, filesystem_write, network]
feature: shadow-ide/feature/upstream-vscode-synchronization
dry_run_supported: false
dry_run_param:
test_mode_supported: false
test_mode_param:
live_execution_requires_approval: true
tags: [upstream, git, cli]
---

# Run Upstream Fetch

> Resolves the VS Code tag/commit and fetches the upstream source into `vscode/`.

## Description

`get_repo.sh` initializes `vscode/`, adds the Microsoft VS Code remote, fetches the selected commit, checks it out, and exports version env values for downstream scripts.

## Endpoint

CLI: `. ./get_repo.sh`

## Parameters

### Required

| Name | Type | Description |
|------|------|-------------|
| `VSCODE_QUALITY` | env | `stable` or `insider`. |

### Optional

| Name | Type | Description |
|------|------|-------------|
| `RELEASE_VERSION` | env | Explicit release version to resolve. |
| `VSCODE_LATEST` | env | If `yes`, use the VS Code update API. |

## Side effects

- Creates or mutates `vscode/`.
- Performs Git network fetches.
- Exports version env vars in the current shell when sourced.

## Safety gates

- Confirmation required because it writes generated source.
- No dry-run mode exists.

## Errors

- Bad `RELEASE_VERSION` format -> exits.
- Unknown tag/commit -> exits.
- Network failure -> exits.

## Linked feature

[[features/upstream-vscode-synchronization]]

## Notes for the assistant

Prefer reading `upstream/*.json` for simple version questions. Run this only when actually preparing a build.
