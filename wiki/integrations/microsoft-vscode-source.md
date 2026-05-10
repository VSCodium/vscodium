---
slug: shadow-ide/integration/microsoft-vscode-source
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
vendor: Microsoft
protocol: https
auth_via: public git and public update API
features: [shadow-ide/feature/upstream-vscode-synchronization]
components: [shadow-ide/component/upstream-version-metadata, shadow-ide/component/root-build-orchestration]
tags: [vscode, upstream, git]
---

# Microsoft VS Code Source

> Microsoft provides the upstream VS Code Git repository and update API consumed by this build system.

## Vendor

Microsoft - upstream owner of the VS Code source tree that Shadow-IDE builds from.

## Protocol

HTTPS Git and HTTPS update API.

## Auth

Public read access for Git fetches and update API calls.

## Endpoints used

- Git remote: `https://github.com/Microsoft/vscode.git`
- Update API pattern: `https://update.code.visualstudio.com/api/update/darwin/<quality>/0000000000000000000000000000000000000000`

## What it enables

- [[features/upstream-vscode-synchronization]]

## Failure modes

- Tag/commit unavailable -> source fetch fails.
- API shape changes -> `get_repo.sh` parsing fails.
- Upstream source moves code -> local patches may fail.

## Components

- [[components/upstream-version-metadata]]
- [[components/root-build-orchestration]]

## Open questions

None at this time.
