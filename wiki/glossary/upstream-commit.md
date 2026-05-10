---
slug: shadow-ide/glossary/upstream-commit
project_slug: shadow-ide
kind: glossary
audience: [user, agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [upstream, commit, vscode]
---

# Upstream Commit

> The exact Microsoft VS Code commit that the distribution builds from.

## Term

**Upstream commit**

## Definition

The upstream commit is the `commit` field in `upstream/stable.json` or `upstream/insider.json`, or the commit discovered from the VS Code update API/latest tag flow. It is exported as `MS_COMMIT`.

## Used in

- [[project-discovery]] - lists the current stable/insider upstream commit.
- [[components/upstream-version-metadata]] - stores commit pins.
- [[workflows/upstream-release-publish]] - uses the commit in CI.

## Related terms

- [[glossary/quality]]
- [[glossary/release-version]]

## Notes

Patch failures often mean the upstream commit changed enough that patch context no longer matches.
