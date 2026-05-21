# Architecture Map - Cursor ING

## System Layers

```
+----------------------------------------------------------+
|                    User Interface                         |
|  Composer Panel | Agent Roster | Plan Viewer | Diff View  |
+----------------------------------------------------------+
|                Extension Host (TypeScript)                 |
|  extension.ts -> commands, webview providers, tree views   |
+----------------------------------------------------------+
|                 Agent Orchestrator                         |
|  Planner -> Coder -> Reviewer -> Security -> Browser      |
+----------------------------------------------------------+
|                 Provider Abstraction                       |
|  MockProvider | OpenAI | Anthropic | Ollama | OpenRouter   |
+----------------------------------------------------------+
|                 Activity Log / Audit Trail                 |
|  Every action logged: reads, writes, commands, browsing    |
+----------------------------------------------------------+
|                 Plan Model / State                         |
|  .plan.json files with steps, statuses, approvals          |
+----------------------------------------------------------+
|               VSCodium / VS Code Runtime                   |
|  Electron | Extension APIs | File System | Terminal        |
+----------------------------------------------------------+
```

## Data Flow

1. User types in Composer -> Provider generates response
2. Planner creates plan from response -> User approves
3. Coder executes approved steps -> Generates diffs
4. Reviewer validates diffs -> Approves/rejects
5. Security scans all changes -> Flags issues
6. Approved diffs applied to workspace
7. All actions logged to Activity Log

## Key Integration Points

| Component | VS Code API | Status |
|-----------|-------------|--------|
| Composer Panel | `WebviewViewProvider` | Phase 1 scaffold |
| Agent Roster | `TreeDataProvider` or Webview | Phase 1 scaffold |
| Plan Viewer | `WebviewPanel` | Phase 1 scaffold |
| Diff Preview | `TextDocumentContentProvider` + diff editor | Phase 1 scaffold |
| Activity Log | Output Channel or Webview | Phase 1 scaffold |
| Terminal Approval | `Terminal` API | Phase 2 |
| File Watcher | `FileSystemWatcher` | Phase 2 |
