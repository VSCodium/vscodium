---
slug: shadow-ide/integration/cline-kanban
project_slug: shadow-ide
kind: integration
audience: [dev, agent]
version: 1
mapped_date: 2026-05-10
last_updated: 2026-05-10
status: complete
vendor: Cline (cline.bot)
protocol: http
auth_via: none-at-runtime
features: [shadow-ide/feature/agents-window]
components: [shadow-ide/component/shadowide-extensions-bundling]
tags: [kanban, cline, agents, npm]
---

# Cline Kanban

> The `kanban` npm package — Cline's open-source agent task board, used as the embedded UI inside ShadowIDE's Agents Window.

## Vendor

Cline (cline.bot). Two relevant npm packages:

- `cline` (Apache-2.0) — the agent CLI, registers `cline --acp` for Agent Client Protocol mode.
- `kanban` (Apache-2.0, `github.com/cline/kanban`) — a Vite/React web app + Node tRPC server that orchestrates one or more ACP agents per task card. The board does the actual UI; `cline` is one of several agents it can drive.

The kanban server depends on `@clinebot/core` and `@clinebot/shared` — these are separately published npm packages whose source is not in either public repo at the time of writing.

## Protocol

HTTP over `127.0.0.1`. The kanban server binds to a chosen port (`--port auto` selects one) and serves both the React web UI and a tRPC RPC layer at that origin. The Agents Window webview connects via a same-origin iframe. No external network traffic originates from this integration; agent execution may make outbound calls (LLM APIs, MCP servers) but those are governed by per-agent configuration, not this integration.

## Auth

None at the transport layer in MVP — `kanban` defaults to no passcode. If we later run with passcode-gated mode, the launcher in `extensions/shadowide-agents/extension.js` will need to capture the token and inject it into the iframe URL.

## Endpoints used

- `kanban --no-open --port auto` — CLI invocation that starts the local server and prints the runtime URL on stdout in the form `http://127.0.0.1:NNNN/<workspace-name>`.
- The webview consumes the served HTML/JS/tRPC at that origin. We do not call tRPC directly today; the embedded UI handles all interaction.

## What it enables

- [[features/agents-window]] — the in-IDE Kanban dashboard.

## Failure modes

- **Binary not on PATH** — surfaced as an error notification with install instructions; webview never opens.
- **No URL printed within 10s** — we time out and show the partial stdout/stderr buffer for diagnosis.
- **Port conflict** — `--port auto` retries; if every probe fails, kanban exits non-zero before printing a URL.
- **Webview cannot reach loopback** — rare on macOS; would manifest as a blank panel. No workaround in MVP.
- **Upstream API churn** — the kanban project labels itself a research preview; tRPC contract may change between versions. Today this only matters if we move from iframe-embedding to a custom UI on the tRPC API.

## Components

- [[components/shadowide-extensions-bundling]] — wires the launcher extension into the build.

## Open questions

- Whether to bundle the `kanban` binary inside `shadowide-agents/` so the install prerequisite disappears (~57 MB extra in the `.app`).
- Whether `@clinebot/core` and `@clinebot/shared` are open-source. If not, deeper customization (forking the agent runtime) is blocked for us; only the UI shell can be swapped.
