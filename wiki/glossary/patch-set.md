---
slug: shadow-ide/glossary/patch-set
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [patches, upstream]
---

# Patch Set

> Ordered `.patch` files applied to upstream VS Code after overlays are copied.

## Term

**Patch set**

## Definition

The patch set is the collection of files under `patches/` that encode product-specific source changes against upstream VS Code. Patches may contain placeholders that `utils.sh` substitutes before applying.

## Used in

- [[components/patch-set]] - owns patch application details.
- [[workflows/patch-refresh-after-upstream-change]] - repairs patch drift.
- [[decisions/track-upstream-vscode-by-scripted-overlay]] - uses patches as the fork strategy.

## Related terms

- [[glossary/overlay]]
- [[glossary/upstream-commit]]

## Notes

Patch order is effectively filename/order plus shared/quality/platform/user directory order in `prepare_vscode.sh`.
