---
slug: shadow-ide/glossary/reh
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [reh, remote]
---

# REH

> Remote Extension Host artifacts used by VS Code-family remote development scenarios.

## Term

**REH**

Also known as: remote extension host.

## Definition

REH artifacts package the remote extension host portion of the editor. The build can also create REH-web artifacts when enabled.

## Used in

- [[components/platform-build-packaging]] - packages REH outputs.
- [[features/cross-platform-build-and-packaging]] - includes REH in artifact matrix.
- [[workflows/upstream-release-publish]] - may publish REH tarballs.

## Related terms

- [[glossary/release-version]]
- [[glossary/quality]]

## Notes

`SHOULD_BUILD_REH` and `SHOULD_BUILD_REH_WEB` gate these outputs.
