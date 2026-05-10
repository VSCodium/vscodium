---
slug: shadow-ide/feature/extension-marketplace-control
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/vscode-overlay-and-product-metadata, shadow-ide/component/patch-set, shadow-ide/component/documentation-site]
actions: []
workflows: [shadow-ide/workflow/upstream-release-publish, shadow-ide/workflow/patch-refresh-after-upstream-change]
tags: [extensions, marketplace, open-vsx]
---

# Extension Marketplace Control

> The build controls extension-gallery endpoints, proposed API allowances, and extension compatibility behavior.

## Purpose

VS Code-compatible distributions cannot assume Microsoft Marketplace terms apply. This feature keeps extension sourcing and compatibility behavior explicit.

## User-visible behavior

Users search/install extensions through the configured gallery, currently Open VSX by default. Some Microsoft-only extensions may not work or may require documented workarounds.

## Components used

- [[components/vscode-overlay-and-product-metadata]]
- [[components/patch-set]]
- [[components/documentation-site]]

## Actions exposed

None.

## Related workflows

- [[workflows/upstream-release-publish]]
- [[workflows/patch-refresh-after-upstream-change]]

## Open questions

None at this time.

## Notes for the assistant

Use `docs/extensions.md` for user-facing explanations. Use `product.json`, `prepare_vscode.sh`, and patches such as `00-settings-gallery.patch`, `00-vsce-use-custom-lib.patch`, and extension policy/security patches for implementation details.
