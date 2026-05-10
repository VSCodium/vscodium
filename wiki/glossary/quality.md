---
slug: shadow-ide/glossary/quality
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [quality, stable, insider]
---

# Quality

> Build track, usually `stable` or `insider`, that selects overlays, version behavior, and release routes.

## Term

**Quality**

## Definition

In this repo, quality is the `VSCODE_QUALITY` value. It chooses `src/stable` versus `src/insider`, stable versus insider release names, and quality-specific patches/workflows.

## Used in

- [[components/upstream-version-metadata]] - has one pin per quality.
- [[components/vscode-overlay-and-product-metadata]] - copies quality-specific overlays.
- [[workflows/upstream-release-publish]] - stable and insider workflows differ by quality.

## Related terms

- [[glossary/upstream-commit]]
- [[glossary/release-version]]

## Notes

Default local developer builds use stable unless `./dev/build.sh -i` is passed.
