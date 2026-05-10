---
slug: shadow-ide/feature/telemetry-and-service-hardening
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/patch-set, shadow-ide/component/vscode-overlay-and-product-metadata, shadow-ide/component/documentation-site]
actions: []
workflows: [shadow-ide/workflow/upstream-release-publish, shadow-ide/workflow/patch-refresh-after-upstream-change]
tags: [telemetry, privacy, services]
---

# Telemetry And Service Hardening

> The build removes or disables telemetry and selected Microsoft service integrations from the upstream editor distribution.

## Purpose

This feature supports a free/libre distribution posture and reduces dependence on Microsoft-hosted proprietary service hooks.

## User-visible behavior

Users should receive an editor build with telemetry disabled and certain cloud/update/recommendation behaviors removed or redirected. Documentation in `docs/telemetry.md` explains relevant settings and expectations.

## Components used

- [[components/patch-set]]
- [[components/vscode-overlay-and-product-metadata]]
- [[components/documentation-site]]

## Actions exposed

None.

## Related workflows

- [[workflows/upstream-release-publish]]
- [[workflows/patch-refresh-after-upstream-change]]

## Open questions

None at this time.

## Notes for the assistant

When troubleshooting telemetry or Microsoft service behavior, inspect both `undo_telemetry.sh` and patches such as `00-telemetry-disable.patch`, `00-cloud-remove.patch`, and remote/tunnel patches.
