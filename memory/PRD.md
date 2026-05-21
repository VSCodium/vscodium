# Cursor ING - PRD (Product Requirements Document)

## Product Identity
- **Name**: Cursor ING
- **Base**: VSCodium (open-source VS Code without Microsoft telemetry)
- **Goal**: Privacy-first, open-source, Cursor-inspired AI IDE
- **License**: MIT-compatible

## Original Problem Statement
Build Cursor ING on top of the VSCodium repository. The UI must be IDE-native (VS Code/Cursor-style), not a dashboard. Phase 1: scaffold architecture with AGENTS.md, .agents/ harness, extension skeleton, mock provider, agent roster, plan model, activity log, diff preview, and IDE-native web preview.

## User Persona
- Software engineers wanting AI-assisted coding without giving up privacy
- Teams needing auditable, reversible AI actions in their IDE
- Open-source advocates wanting a Cursor alternative on VSCodium

## Core Requirements (Static)
1. No telemetry, no tracking, no proprietary assets
2. Extension-first architecture (no core VSCodium patches)
3. Provider abstraction supporting multiple AI backends
4. Multi-agent team with visible statuses and permissions
5. Explicit approval for file writes, commands, browser actions
6. Structured plans with review and approval workflow
7. Activity log as audit trail
8. Diff preview with trust/reversibility controls
9. IDE-native UI (not SaaS dashboard)

## What's Been Implemented

### Iteration 1 (Jan 2026) - Phase 1 Scaffolding
- Repo audit: VSCodium build pipeline, patches, product.json analyzed
- AGENTS.md + .agents/ three-layer harness (53 validation checks)
- Extension skeleton: extensions/cursor-ing-ai/ (TypeScript)
- Mock provider, agent roster, plan model, activity log, diff preview
- Initial dashboard preview (replaced in iteration 2)

### Iteration 2 (Jan 2026) - IDE-Native UI Overhaul
- Complete UI rewrite: dashboard -> VS Code/Cursor-style IDE shell
- TitleBar: Shows active file and "Cursor ING" branding
- ActivityBar: 6 nav icons (Explorer, Search, SCM, Debug, Extensions, Agents) + Composer toggle
- Sidebar: File explorer tree with .agents/, plans, extensions OR Agent roster with status dots
- Editor Area: Tabbed editor with Welcome page, Plan editor (line numbers, risk badges), Diff editor (red/green lines)
- Composer Panel: Right-side AI chat panel with mock-v1 provider
- Bottom Panel: Activity Log (18 entries), Terminal, Problems tabs
- Status Bar: Branch, agent status, provider model, "No Telemetry", version
- Deep navy theme (#0B1120 base, #05A0F0 accent)

### Testing
- Iteration 1: Backend 16/16, Frontend 100%
- Iteration 2: Backend 16/16, Frontend 100% (all IDE layout tests passed)
- Validation: 53/53 scaffold checks

## Architecture
```
TitleBar
+------+--------+-----------------------+------------------+
| Act  | Side   | Editor Area           | AI Composer      |
| Bar  | bar    | (Welcome/Plan/Diff    | (Chat + Mock     |
| Icons| (Tree/ |  with tabs)           |  Provider)       |
|      |  Agents|                       |                  |
+------+--------+-----------------------+------------------+
|      | Bottom Panel (Activity Log / Terminal / Problems)  |
+------+--------+-----------------------+------------------+
StatusBar: main | 3 agents active | mock-v1 | No Telemetry
```

## Prioritized Backlog

### P0 - Next
1. Real AI provider integration (OpenAI/Anthropic via Emergent key)
2. Functional composer chat with streaming
3. Working diff application with file writes
4. Terminal command approval flow
5. Extension TypeScript compilation + VSIX

### P1
1. Editor decorations (Clicky-style agent visualization)
2. Browser-use panel scaffold
3. Multi-agent orchestration
4. Plannotator annotations
5. Voice input architecture

### P2
1. Domain packs (legal/document review)
2. Ollama local model support
3. Cross-platform build pipeline
4. oh-my-claudecode interview loop

## Next Tasks
1. Wire real AI provider into composer
2. Enable streaming responses
3. Implement diff apply with file writes
4. Add editor decorations for agent activity
5. TypeScript compilation of extension skeleton
