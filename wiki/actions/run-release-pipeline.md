---
slug: shadow-ide/action/run-release-pipeline
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
executable: true
endpoint: "./release.sh && ./update_version.sh"
endpoint_kind: cli
auth_required: true
auth_via: GitHub token env vars
confirmation_required: true
idempotent: false
side_effects: [local_execution, filesystem_write, network, external_write]
feature: shadow-ide/feature/release-and-update-distribution
dry_run_supported: false
dry_run_param:
test_mode_supported: false
test_mode_param:
live_execution_requires_approval: true
tags: [release, github, updates]
---

# Run Release Pipeline

> Publishes release assets and update metadata using credentialed GitHub operations.

## Description

`release.sh` creates or edits a GitHub release and uploads assets/checksums. `update_version.sh` writes latest-version metadata to the configured versions repository. These operations are externally visible and credentialed.

## Endpoint

CLI sequence: `./release.sh` and `./update_version.sh`

## Parameters

### Required

| Name | Type | Description |
|------|------|-------------|
| `GITHUB_TOKEN` or equivalent | env | Token for release/version writes. |
| `ASSETS_REPOSITORY` | env | Release asset repository. |
| `VERSIONS_REPOSITORY` | env | Update metadata repository. |
| `RELEASE_VERSION` | env | Version being published. |
| `BUILD_SOURCEVERSION` | env | Build source hash for update metadata. |

### Optional

| Name | Type | Description |
|------|------|-------------|
| `FORCE_UPDATE` | env | Force update metadata write. |

## Side effects

- Creates/edits GitHub releases.
- Uploads, deletes, and re-uploads release assets during retry paths.
- Clones, commits, and pushes to a versions repository.

## Safety gates

- Live execution requires explicit operator approval and credentials.
- No dry-run mode exists.
- Use CI publish workflows rather than ad hoc local execution for production releases.

## Errors

- Missing token -> script exits without release/update.
- Upload failure -> retry path may still fail.
- Missing checksum -> update metadata cannot be generated.

## Linked feature

[[features/release-and-update-distribution]]

## Notes for the assistant

Do not dispatch automatically. Summarize expected external changes and ask for confirmation first.
