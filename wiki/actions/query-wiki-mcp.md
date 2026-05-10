---
slug: shadow-ide/action/query-wiki-mcp
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
executable: true
endpoint: "mcp_tool:retrieve_context"
endpoint_kind: mcp_tool
auth_required: false
auth_via:
confirmation_required: false
idempotent: true
side_effects: [none]
feature: shadow-ide/feature/knowledge-base-read-side-access
dry_run_supported: true
dry_run_param: read-only by design
test_mode_supported: true
test_mode_param: local wiki fixture
live_execution_requires_approval: false
tags: [mcp, wiki, read-only]
---

# Query Wiki MCP

> Retrieves Shadow-IDE wiki context through the read-only MCP server.

## Description

The kbmap MCP server exposes read tools for pages, search, graph, manifest, and retrieval context. It never edits source, writes releases, or dispatches build commands.

## Endpoint

MCP tool: `retrieve_context` and related read-only wiki tools.

## Parameters

### Required

| Name | Type | Description |
|------|------|-------------|
| `query` | string | User or agent retrieval request. |

### Optional

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Narrow to component, feature, workflow, action, etc. |

## Side effects

None - read-only operation.

## Safety gates

- Read-only by design.
- Safe to use without confirmation.
- Requires `WIKI_PATH` to point at this repo's `wiki/`.

## Errors

- Missing manifest -> retrieval may fail or return incomplete results.
- Broken wikilinks -> graph neighbors may be incomplete.

## Linked feature

[[features/knowledge-base-read-side-access]]

## Notes for the assistant

Use this before editing unfamiliar areas. For command execution, rely on normal coding-agent tools and the action pages as safety contracts.
