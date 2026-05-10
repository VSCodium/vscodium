---
slug: shadow-ide/glossary/overlay
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [overlay, source]
---

# Overlay

> Files copied from this repository into upstream VS Code before patching and building.

## Term

**Overlay**

## Definition

An overlay is a repository-owned file tree under `src/stable` or `src/insider` that is copied into the generated `vscode/` checkout. It carries resources and source files that should replace or add to upstream files before patches run.

## Used in

- [[components/vscode-overlay-and-product-metadata]] - applies overlays.
- [[architecture/overview]] - shows overlay in the build diagram.
- [[decisions/track-upstream-vscode-by-scripted-overlay]] - records the overlay strategy.

## Related terms

- [[glossary/patch-set]]
- [[glossary/quality]]

## Notes

Overlay files are durable source. Generated `vscode/` files are not.
