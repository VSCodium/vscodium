---
slug: shadow-ide/feature/product-branding-and-assets
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/vscode-overlay-and-product-metadata, shadow-ide/component/assets-icons-and-branding, shadow-ide/component/font-size-generator]
actions: [shadow-ide/action/generate-icons]
workflows: [shadow-ide/workflow/local-development-build, shadow-ide/workflow/upstream-release-publish]
tags: [branding, icons, product]
---

# Product Branding And Assets

> Shadow-IDE can apply product identity, icons, file-type resources, server favicons, announcements, and package metadata.

## Purpose

Branding makes the upstream VS Code-derived product identify as the intended distribution. This includes product names, command names, protocols, data folders, app IDs, icons, and installer imagery.

## User-visible behavior

Users see product names in menus, install locations, app icons, update dialogs, package names, server resources, and file associations. The current tracked repo still contains many VSCodium defaults, so Shadow-IDE-specific branding should be completed as a coordinated change.

## Components used

- [[components/vscode-overlay-and-product-metadata]]
- [[components/assets-icons-and-branding]]
- [[components/font-size-generator]]

## Actions exposed

- [[actions/generate-icons]]

## Related workflows

- [[workflows/local-development-build]]
- [[workflows/upstream-release-publish]]

## Open questions

None at this time.

## Notes for the assistant

Do not treat product branding as a single string replacement. Audit scripts, workflows, docs, `product.json`, overlays, icons, package metadata, update metadata, and platform IDs together.
