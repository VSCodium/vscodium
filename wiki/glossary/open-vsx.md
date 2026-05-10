---
slug: shadow-ide/glossary/open-vsx
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [extensions, open-vsx]
---

# Open VSX

> Open extension registry used as the default gallery for non-Microsoft VS Code distributions.

## Term

**Open VSX**

## Definition

Open VSX is the extension registry configured by default in the product metadata. It provides extension discovery/install endpoints compatible with VS Code-like clients.

## Used in

- [[features/extension-marketplace-control]] - describes extension behavior.
- [[integrations/open-vsx-registry]] - documents endpoints.
- [[decisions/use-open-vsx-gallery-by-default]] - records why it is default.

## Related terms

- [[glossary/quality]]

## Notes

Users may still need alternate installation paths for extensions not published to Open VSX.
