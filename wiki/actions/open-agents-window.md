---
slug: shadow-ide/action/open-agents-window
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
mapped_date: 2026-05-10
last_updated: 2026-05-10
status: complete
executable: true
endpoint: "vscode.commands.executeCommand('shadowide.openAgentsWindow')"
endpoint_kind: local_function
auth_required: false
auth_via: ""
confirmation_required: false
idempotent: true
side_effects: [spawns-subprocess, opens-network-port]
feature: shadow-ide/feature/agents-window
dry_run_supported: false
dry_run_param: ""
test_mode_supported: false
test_mode_param: ""
live_execution_requires_approval: false
tags: [command, kanban, ui]
---

# Open Agents Window

> Opens the ShadowIDE Agents Window — spawns the local Cline `kanban` server and embeds it in a webview panel inside ShadowIDE.

## Description

Triggered when the user runs **Shadow Agents: Open Agents Window** from the command palette. Spawns `kanban --no-open --port auto` as a child process scoped to the current workspace folder, parses the runtime URL from stdout, and opens a `WebviewPanel` whose iframe loads that URL. Idempotent: a second invocation while the panel is open just reveals the existing tab.

## Endpoint

`vscode.commands.executeCommand('shadowide.openAgentsWindow')` — registered by the `shadowide-agents` built-in extension (`extensions/shadowide-agents/extension.js`).

## Parameters

### Required

None.

### Optional

None — the command takes no arguments. Working directory is inferred from the active workspace folder.

## Side effects

- Spawns a `kanban` Node child process bound to a local TCP port.
- Opens a network port on `127.0.0.1` (port chosen by `kanban --port auto`).
- Creates a webview panel in the editor area.
- Subsequent task creation inside the Kanban UI creates git worktrees, files, and commits — but those are dispatched by `kanban`, not by this action.

## Safety gates

- The action only invokes a local subprocess on `127.0.0.1`. No external network calls are made by ShadowIDE itself.
- `confirmation_required: false` because spawning a local agent dashboard has no destructive effect.
- Closing the webview panel kills the child process via `proc.kill()` in the panel's `onDidDispose` handler.
- Live execution does not require approval — this is a UI surface, not a deploy/release action.
- No dry-run / test-mode supported; the operation has no remote side effects to mock.

## Errors

- **kanban binary not found** — surfaced as an error notification with the install hint `npm install -g kanban`. Action exits without opening a panel.
- **kanban exits before printing URL** — surfaced as an error notification including stderr/stdout buffer for diagnosis.
- **10s timeout waiting for runtime URL** — surfaced as an error notification; user can retry.

## Linked feature

[[features/agents-window]]

## Notes for the assistant

This action is safe to dispatch directly when the user asks anything matching "open the agents window," "show me my agents," "open the kanban inside ShadowIDE," or "where is the agents dashboard." Do not require confirmation.

If the action fails with the missing-binary error, explain the install command (`npm install -g kanban`) and ask whether to run it. Do NOT install global npm packages without explicit user approval.

If the user asks for the same dashboard but is not running ShadowIDE, redirect them to the standalone `cline` / `kanban` CLI command — same UI, same data, just opens in their default browser instead of an in-IDE panel.
