---
slug: shadow-ide/integration/open-vsx-registry
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
vendor: Eclipse Open VSX
protocol: https
auth_via: public extension gallery endpoints for client reads
features: [shadow-ide/feature/extension-marketplace-control]
components: [shadow-ide/component/vscode-overlay-and-product-metadata, shadow-ide/component/documentation-site]
tags: [extensions, marketplace, open-vsx]
---

# Open VSX Registry

> Open VSX provides the default extension-gallery endpoints for the distribution.

## Vendor

Eclipse Open VSX - open extension registry compatible with VS Code extension-gallery APIs.

## Protocol

HTTPS.

## Auth

Public client reads. Publishing to Open VSX is outside this repo's build pipeline.

## Endpoints used

- `https://open-vsx.org/vscode/gallery`
- `https://open-vsx.org/vscode/item`
- `https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest`
- `https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json`

## What it enables

- [[features/extension-marketplace-control]]

## Failure modes

- Extension missing from Open VSX -> users need a documented alternative.
- Registry outage -> extension search/install degrades.
- Product metadata drift -> client may point at the wrong gallery.

## Components

- [[components/vscode-overlay-and-product-metadata]]
- [[components/documentation-site]]

## Open questions

None at this time.
