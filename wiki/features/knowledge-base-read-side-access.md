---
slug: shadow-ide/feature/knowledge-base-read-side-access
project_slug: shadow-ide
kind: feature
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
components: [shadow-ide/component/wiki-mcp-server]
actions: [shadow-ide/action/query-wiki-mcp]
workflows: [shadow-ide/workflow/knowledge-base-maintenance]
tags: [kbmap, mcp, wiki]
---

# Knowledge Base Read-side Access

> Agents can query this Markdown wiki through a read-only MCP server and deterministic manifest.

## Purpose

This feature makes project knowledge durable and discoverable across sessions. It helps future agents answer questions and modify the repo with better context.

## User-visible behavior

Developers can read `wiki/` directly or install the generated MCP server using `MCP-INSTALL.md`. The MCP server exposes read tools only.

## Components used

- [[components/wiki-mcp-server]]

## Actions exposed

- [[actions/query-wiki-mcp]]

## Related workflows

- [[workflows/knowledge-base-maintenance]]

## Open questions

None at this time.

## Notes for the assistant

After changing source or wiki pages, regenerate the manifest and keep related component/feature/workflow pages synchronized.
