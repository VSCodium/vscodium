---
slug: shadow-ide/decision/use-open-vsx-gallery-by-default
project_slug: shadow-ide
kind: decision
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
decision_status: accepted
superseded_by:
components: [shadow-ide/component/vscode-overlay-and-product-metadata, shadow-ide/component/documentation-site]
tags: [extensions, open-vsx, marketplace]
---

# Use Open VSX Gallery By Default

> We configure the distribution to use Open VSX extension-gallery endpoints by default.

## Status

**Accepted** - active in `prepare_vscode.sh` product metadata mutation.

## Context

Microsoft Marketplace terms restrict use of Marketplace offerings to Microsoft Visual Studio products and services. A VS Code-derived distribution needs a default extension source compatible with non-Microsoft builds.

## Decision

Set the default `extensionsGallery` metadata to Open VSX endpoints and document marketplace trade-offs in `docs/extensions.md`.

## Consequences

### Positive

- Default gallery is aligned with non-Microsoft distribution needs.
- Users get a discoverable extension flow without manual configuration.

### Negative

- Some extensions available in Microsoft Marketplace may be missing from Open VSX.
- Some proprietary extensions may not work in non-Microsoft products.

### Neutral / accepted trade-offs

- Users can configure alternative galleries, but support guidance should respect marketplace terms.

## Alternatives considered

- Use Microsoft Marketplace endpoints - rejected on terms-of-use grounds.
- No default marketplace - rejected because extension search/install is a core user expectation.

## Related

- [[components/vscode-overlay-and-product-metadata]]
- [[components/documentation-site]]
- [[integrations/open-vsx-registry]]

## Open questions

None at this time.
