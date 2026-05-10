# wiki-mcp — Read-Side MCP Server for kbmap Wikis

A reference implementation of an **MCP server** that exposes a kbmap wiki to any MCP-aware host (Claude Desktop, Claude Code, Cursor, custom clients). Read-only by design.

> **Read-side vs. write-side:** This server is read-only. It exposes pages, manifest entries, search, and action *contracts* — but never executes anything. The write-side `app-actions-mcp` server (which actually dispatches actions on a user's behalf) is per-app code that lives in each app's own repo. See [[examples/reference-dispatcher.ts]] for a sketch of what the write-side looks like, and the README's "Read-side vs write-side MCP" section for the design rationale.

> **Read-only MCP is not the same as read-only project work.** A QA tester in
> `qa-readonly` mode should only investigate and cite evidence. An AI coding
> agent in `agent-dev-readwrite` mode may still edit project source through its
> normal filesystem tools, then run verification and ingest KB updates. This
> server remains read-only in both cases.

This server is designed to be installed in any project that has been bootstrapped with `bootstrap.sh`. After bootstrap, an `mcp-server/` directory appears at the project root with this code; running `npm install && npm run build` and pointing your MCP host at it makes the project's wiki queryable.

## What it exposes

### Tools

Tool name | Inputs | Returns | Purpose
---|---|---|---
`get_page` | `slug` | full page (frontmatter + markdown) | Fetch any wiki page by slug
`search_wiki` | `query`, optional `kind`, optional `audience` | ranked list of matching page summaries | Lexical search across slugs, metadata, and page bodies with filters
`list_by_kind` | `kind` | list of page summaries of that kind | Enumerate all features / actions / etc.
`get_feature` | `slug` | feature page + its resolved action contracts | Common pattern: "what is this feature and what can the agent do for it?"
`get_component` | `slug` | component page + its dependencies and dependents | Common pattern: "tell me about this component"
`get_workflow` | `slug` | workflow page + linked features | Walk through a multi-step user journey
`describe_action` | `slug` | action page (the contract — endpoint, auth, side_effects) | What CAN this action do? (Describing only — never executing.)
`recent_changes` | `since` (date) | pages whose `last_updated >= since` | "What's new?"
`get_manifest` | _none_ | the full `wiki/manifest.json` | Bulk index for clients that want everything
`graph_neighbors` | `slug`, optional `depth`, optional `edge_types` | graph node, neighboring nodes, evidence-backed edges, and chunks | Low-level graph traversal over generated graph artifacts
`retrieve_context` | `query`, optional `mode`, optional `project_slug`, optional `scope`, optional `limits` | ranked evidence, citations, graph paths, missing evidence, and confidence | Agent-facing exact graph/chunk retrieval over wiki and code graph artifacts

See [[retrieve-context-contract]] for the full contract. The current
implementation is an MVP over exact graph/chunk matching plus graph expansion.
It is intentionally vendor-neutral and does not expose embedding provider
details; semantic retrieval can be added later behind the same output shape.

### Resources

MCP clients that prefer resource reads can also enumerate and read:

Resource URI | Returns
---|---
`wiki://manifest` | the full `wiki/manifest.json` as `application/json`
`wiki://page/<encoded-slug>` | a wiki page's raw Markdown as `text/markdown`

Resources are read-only and mirror the same manifest-backed pages exposed by
the tools.

## Quick start

```bash
# 1. Bootstrap your project (one time)
bash codebase-map/bootstrap.sh ~/Projects/my-app

# 2. Install MCP server deps and build
cd ~/Projects/my-app/mcp-server
npm install
npm run build

# 3. Register with your MCP host (Claude Desktop example)
# In ~/Library/Application Support/Claude/claude_desktop_config.json:
{
  "mcpServers": {
    "wiki-my-app": {
      "command": "node",
      "args": ["/Users/you/Projects/my-app/mcp-server/dist/index.js"],
      "env": {
        "WIKI_PATH": "/Users/you/Projects/my-app/wiki"
      }
    }
  }
}
```

For Cursor and Claude Code, see `MCP-INSTALL.md` (generated during T23 by bootstrap.sh).

## Configuration

The server reads one environment variable:

- `WIKI_PATH` — absolute path to the project's `wiki/` directory. If unset, defaults to `../wiki` relative to the server's location (which is correct after bootstrap.sh installs it at `[PROJECT_ROOT]/mcp-server/`).

## Manifest version compatibility

The server hardcodes `MANIFEST_VERSION_SUPPORTED = 1`. If it reads a `wiki/manifest.json` with a higher `manifest_version`, it refuses to start with a clear error pointing at the upgrade docs.

## Why read-only?

Conflating read and write is structurally bad:

1. **Different lifecycles.** A documentation server runs anywhere (laptop, CI, anyone's MCP host) without consequence. A dispatcher runs in your app's runtime with auth, idempotency, and side effects.
2. **Different threat models.** A read-only MCP server is safe to point at any host. A dispatcher exposed to arbitrary hosts is a security disaster.
3. **Federation.** Read-side composes naturally — query 5 projects, get 5 manifests back, merge. Write-side never federates.

The design separation is enforced here: this server has no concept of "execute". It can `describe_action(slug)` to tell an agent what an action would do. The actual execution is the per-app `app-actions-mcp` server's responsibility.

For project source-code work, use the installed `wiki/work-modes.md` policy:

- `qa-readonly` — read KB/source evidence and answer; no edits.
- `agent-dev-readwrite` — read KB first, edit/debug/build within scope, verify,
  then run ingest so the KB reflects the code change.

## Status

This is a reference implementation. T22 ships the basic server. Production hardening (caching, file-watching for live updates, auth on the MCP transport) is post-launch.
