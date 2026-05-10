---
slug: shadow-ide/component/wiki-mcp-server
project_slug: shadow-ide
kind: component
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
source_path: "mcp-server/"
features: [shadow-ide/feature/knowledge-base-read-side-access]
workflows: [shadow-ide/workflow/knowledge-base-maintenance]
tags: [mcp, knowledge-base, read-only]
---

# Wiki MCP Server

> The generated read-only MCP server exposes this wiki to MCP-aware hosts.

## Purpose

The server lets agents query the Shadow-IDE knowledge base by page, kind, feature, component, workflow, graph neighbor, or retrieval context without executing app/build actions.

## Source Location

`mcp-server/`, `MCP-INSTALL.md`, and `wiki/manifest.json`.

## Key Files

| File | Purpose |
|------|---------|
| `mcp-server/src/index.ts` | MCP server entry point. |
| `mcp-server/src/graph.ts` | Graph/manifest helpers. |
| `mcp-server/src/retrieve.ts` | Retrieval-context implementation. |
| `MCP-INSTALL.md` | Host setup instructions. |
| `wiki/manifest.json` | Generated page index consumed by tools. |

## How It Works

After `npm install` and `npm run build` in `mcp-server/`, hosts can launch `dist/index.js` with `WIKI_PATH` pointing at this repo's `wiki/`. The server is read-only and does not dispatch build or release actions.

## Error Handling

Missing or stale `wiki/manifest.json` reduces retrieval quality. Regenerate the manifest after wiki edits.

## Dependencies

### Depends On

- [[workflows/knowledge-base-maintenance]]

### Used By

- [[actions/query-wiki-mcp]]
- [[features/knowledge-base-read-side-access]]

## Data Flow

Markdown pages -> `wiki/manifest.json` -> MCP tools -> agent answers.

## API / Interface

Read tools include page lookup, search, list by kind, feature/component/workflow lookup, recent changes, manifest, graph neighbors, and retrieval context.

## Open Questions

None at this time.

## Related Pages

- [[actions/query-wiki-mcp]]
- [[features/knowledge-base-read-side-access]]
- [[index]]
