---
slug: shadow-ide/component/font-size-generator
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "font-size/"
features: [shadow-ide/feature/product-branding-and-assets]
workflows: [shadow-ide/workflow/patch-refresh-after-upstream-change]
tags: [typescript, css, ui]
---

# Font Size Generator

> TypeScript tooling generates CSS/patch material for workbench font-size customization.

## Purpose

The `font-size/` package supports the large custom-font patch by deriving CSS changes across multiple VS Code workbench areas.

## Source Location

`font-size/`

## Key Files

| File | Purpose |
|------|---------|
| `font-size/generate-css.ts` | Main generator. |
| `font-size/package.json` | Node package metadata. |
| `font-size/tsconfig*.json` | TypeScript configuration. |
| `font-size/package-lock.json` | Locked dependencies. |

## How It Works

The generator defines target CSS files and selectors for workbench areas, then emits CSS values based on VS Code workbench font-size variables. The result supports `patches/00-ui-custom-font.patch`.

## Error Handling

TypeScript/build failures should be caught before patch changes are committed. Patch drift is handled through [[workflows/patch-refresh-after-upstream-change]].

## Dependencies

### Depends On

- [[components/patch-set]]

### Used By

- [[features/product-branding-and-assets]]

## Data Flow

Generator config -> CSS patch content -> `patches/00-ui-custom-font.patch` -> prepared upstream source.

## API / Interface

Node/TypeScript package under `font-size/`.

## Open Questions

None at this time.

## Related Pages

- [[components/patch-set]]
- [[features/product-branding-and-assets]]
- [[index]]
