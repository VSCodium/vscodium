---
slug: shadow-ide/workflow/knowledge-base-maintenance
project_slug: shadow-ide
kind: workflow
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
features: [shadow-ide/feature/knowledge-base-read-side-access]
components: [shadow-ide/component/wiki-mcp-server]
actions: [shadow-ide/action/query-wiki-mcp]
tags: [kbmap, wiki, maintenance]
---

# Knowledge Base Maintenance

> Keep the Shadow-IDE wiki synchronized with source, build, packaging, and release behavior.

## Trigger

Any source, workflow, script, patch, docs, or wiki change that alters project behavior should trigger a knowledge-base maintenance pass.

## Steps

1. **Identify changed area** - Map changed files to component/feature/workflow pages. (Component: [[components/wiki-mcp-server]])
2. **Update pages** - Edit specific wiki pages, not just the index. (Component: [[components/wiki-mcp-server]])
3. **Regenerate manifest** - Run the kbmap manifest generator. (Component: [[components/wiki-mcp-server]])
4. **Verify first-map/health checks** - Run first mapping verification or mapstatus as appropriate. (Component: [[components/wiki-mcp-server]])
5. **Use MCP only for reads** - Keep execution actions separate from the read-only wiki server. (Action: [[actions/query-wiki-mcp]])

## Decision points

- If source behavior changed, update component and feature pages.
- If only docs wording changed, update docs-related pages if project behavior or guidance changed.
- If links were added, regenerate and check the manifest.

## Failure modes

- Stale manifest -> MCP retrieval misses or mislinks pages.
- Broken wikilinks -> graph retrieval quality degrades.
- Source/wiki drift -> future agents make decisions on old behavior.

## Components touched

- [[components/wiki-mcp-server]]

## Related features

- [[features/knowledge-base-read-side-access]]

## Open questions

None at this time.
