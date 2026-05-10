---
slug: shadow-ide/feature/agents-window
project_slug: shadow-ide
kind: feature
audience: [user, agent, dev]
version: 1
mapped_date: 2026-05-10
last_updated: 2026-05-10
status: complete
components: [shadow-ide/component/shadowide-extensions-bundling]
actions: [shadow-ide/action/open-agents-window]
workflows: []
tags: [agents, kanban, cline, ui]
---

# Agents Window

> A graphical, in-IDE dashboard for managing parallel coding agents — Cline's Kanban embedded inside ShadowIDE.

## Purpose

Cline ships with a Kanban-style task board (`cline` / `kanban` CLIs) that runs as a local web app. Outside ShadowIDE, you'd run `cline` from a terminal and it would open the board in your default browser. The Agents Window makes that board a native part of ShadowIDE so you don't need a separate browser tab to see what your agents are doing — and so future ShadowIDE-specific bridges (open-file-from-card, surface terminal output, theme matching) have a clear UI surface to attach to.

## User-visible behavior

You open the Agents Window by running **Shadow Agents: Open Agents Window** from the command palette (`Cmd+Shift+P` on macOS). ShadowIDE shows a "Starting ShadowIDE Agents…" notification while it spawns the local kanban server, then opens a new editor tab labeled **Shadow Agents** containing the Kanban board.

Inside the board you can:

- Create new tasks with prompts; each task gets its own git worktree, isolated from your main checkout.
- Pick which agent runs the task (`cline`, `claude`, `codex`, `gemini`, `opencode`, etc.).
- Drag cards across columns: Backlog → In Progress → Review → Done.
- Watch tool calls, plans, and outputs stream in per card.
- Review diffs and merge work back when satisfied.

Closing the editor tab kills the kanban subprocess. Reopening the command starts a fresh server.

### When kanban isn't installed

The MVP requires the `kanban` binary on `PATH`. If it's missing, the notification turns into an error message: *"kanban binary not found. Install it with `npm install -g kanban` and reopen the Agents Window."* A future iteration will bundle the binary inside the extension so this prerequisite goes away.

## Components used

- [[components/shadowide-extensions-bundling]]

## Actions exposed

- [[actions/open-agents-window]]

## Related workflows

None at this time.

## Open questions

- Whether to bundle the `kanban` binary inside the `shadowide-agents` extension (~57 MB) so the install prerequisite disappears. Decision pending dogfood feedback.
- Whether to swap the iframe-embedded `kanban` web UI for a custom React webview that talks the same tRPC contract — see [[integrations/cline-kanban]] for the upstream API surface.

## Notes for the assistant

If a user asks "where are my running agents" or "how do I run more than one task at a time" or anything matching "Cursor Agents Window" — point them at this feature. If they ask why the command says "kanban binary not found", run `npm install -g kanban` for them only with explicit approval; otherwise just print the install command and let them decide.

Do NOT confuse this with the Cline VS Code extension's chat sidebar (the robot icon in the activity bar). Those are two different UIs: the chat sidebar is a single-task chat panel; the Agents Window is the multi-task Kanban dashboard.
