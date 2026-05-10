# Install `wiki-shadow-ide` MCP server

The kbmap bootstrap installed a read-side MCP server template at `mcp-server/`. It exposes this project's wiki to any MCP-aware host (Claude Desktop, Claude Code, Cursor, custom clients).

## One-time setup

```bash
cd /Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/mcp-server
npm install
npm run build
```

## Host configurations

Pick one based on your MCP host. The server reads the `WIKI_PATH` env var to know where the wiki lives.

### Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or the Windows equivalent. Add inside `mcpServers`:

```json
{
  "mcpServers": {
    "wiki-shadow-ide": {
      "command": "node",
      "args": ["/Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/mcp-server/dist/index.js"],
      "env": { "WIKI_PATH": "/Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/wiki" }
    }
  }
}
```

Restart Claude Desktop. New sessions will see the wiki-mcp tools.

### Claude Code

Add to `~/.claude/mcp_servers.json` (or the project's `.claude/settings.json` under `mcpServers`):

```json
{
  "wiki-shadow-ide": {
    "command": "node",
    "args": ["/Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/mcp-server/dist/index.js"],
    "env": { "WIKI_PATH": "/Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/wiki" }
  }
}
```

### Cursor

In Cursor settings → MCP servers:

```json
{
  "wiki-shadow-ide": {
    "command": "node",
    "args": ["/Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/mcp-server/dist/index.js"],
    "env": { "WIKI_PATH": "/Users/ari_mac_mini/projects/editor/Shadow-IDE/Shadow-IDE/wiki" }
  }
}
```

## Verify

In a fresh agent session, ask: "What tools does `wiki-shadow-ide` expose?" The agent should list read tools such as `get_page`, `search_wiki`, `list_by_kind`, `get_feature`, `get_component`, `get_workflow`, `describe_action`, `recent_changes`, `get_manifest`, `graph_neighbors`, and `retrieve_context`.

## What about the write-side dispatcher?

The wiki-mcp server is **read-only**. It can describe actions (`describe_action(slug)`) but never executes them. To actually run actions on a user's behalf, you implement a separate `app-actions-mcp` server in your app's repo. See `codebase-map/examples/reference-dispatcher.ts` for a starting template.

The split exists because:
- read-side is safe to install in any MCP host (no auth, no side effects, federates cleanly across projects);
- write-side has app-runtime concerns (auth, idempotency, audit) that are inappropriate for a generic documentation server.

## What about editing project source?

Read-only MCP does not mean every agent session is read-only. Project-level work
permissions are defined in `wiki/work-modes.md`:
- `qa-readonly`: read KB/source evidence only; no edits.
- `agent-dev-readwrite`: an AI coding agent may edit/debug/build within the
  requested scope, run verification, and then ingest KB updates.
