# Cursor ING - PRD (Product Requirements Document)

## Product Identity
- **Name**: Cursor ING
- **Base**: VSCodium (open-source VS Code without Microsoft telemetry)
- **Goal**: Privacy-first, open-source, Cursor-inspired AI IDE
- **License**: MIT-compatible

## Original Problem Statement
Build Cursor ING on top of the VSCodium repository. Phase 1: scaffold architecture with AGENTS.md, .agents/ harness, extension skeleton, mock provider, agent roster, plan model, activity log, diff preview, documentation, and validation.

## User Persona
- Software engineers who want AI-assisted coding without giving up privacy
- Teams who need auditable, reversible AI actions in their IDE
- Open-source advocates who want a Cursor alternative on VSCodium

## Core Requirements (Static)
1. No telemetry, no tracking, no proprietary assets
2. Extension-first architecture (no core VSCodium patches)
3. Provider abstraction supporting multiple AI backends
4. Multi-agent team with visible statuses and permissions
5. Explicit approval for file writes, commands, and browser actions
6. Structured plans with review and approval workflow
7. Activity log as audit trail for all agent actions
8. Diff preview with trust/reversibility controls

## What's Been Implemented (Phase 1 - Jan 2026)

### Repo Scaffolding (Primary)
- [x] Repo audit: VSCodium build pipeline, patches, product.json, branding, CI analyzed
- [x] AGENTS.md: Canonical cross-model instruction file
- [x] .agents/ scaffold: 3-layer harness (vendor, skills, agents+brain)
  - registry.json, validate.sh
  - 5 model adapters (Claude, Codex, Kimi, Qwen, Gemini)
  - 3 skills (code-review, plan-and-execute, diff-apply)
  - 5 agent definitions (planner, coder, reviewer, security, browser)
  - Brain: memory, glossary, assumptions, ADR, architecture map, runbook
- [x] Extension skeleton: extensions/cursor-ing-ai/ (TypeScript)
  - Provider types, registry, mock provider
  - Agent types, roster with tree view
  - Plan types, plan viewer webview
  - Activity log with output channel and webview
  - Diff preview webview with approval UI
  - Composer panel webview
- [x] Documentation: CURSOR-ING.md
- [x] Validation: .agents/validate.sh (53 checks, all pass)

### Preview Dashboard (Secondary)
- [x] Backend: FastAPI serving mock data (8 API endpoints)
- [x] Frontend: React dashboard with 6 panels
  - Overview: Stats, acceptance criteria, architecture diagram, providers
  - Agent Roster: 5 agents with icons, statuses, last actions
  - Plan Viewer: 5-step plan with risk badges, file references
  - Activity Log: 18 entries in terminal-style audit format
  - Diff Preview: Red/green diff with approve/reject controls
  - Composer: Chat with mock provider, receives structured responses

### Testing
- Backend: 16/16 tests passed (100%)
- Frontend: All UI tests passed (100%)
- Validation: 53/53 checks passed

## Architecture
```
User Interface (Webview Panels)
  Composer | Agent Roster | Plan Viewer | Diff Preview
    |
Extension Host (TypeScript)
  extension.ts -> commands, webviews, tree views
    |
Agent Orchestrator
  Planner -> Coder -> Reviewer -> Security -> Browser
    |
Provider Abstraction
  MockProvider | [OpenAI] | [Anthropic] | [Ollama] | [OpenRouter]
    |
Activity Log / Audit Trail
    |
VSCodium / VS Code Runtime
```

## Prioritized Backlog

### P0 - Phase 2 (Next)
1. Real provider integration (OpenAI, Anthropic via Emergent key)
2. Functional AI composer chat with streaming
3. Working diff application with file writes
4. Terminal command approval flow
5. Extension compilation and VSIX packaging

### P1 - Phase 3
1. Multi-agent orchestration protocol
2. Agent-to-agent handoffs
3. Browser-use panel with safe adapter
4. Voice input (Ctrl+Shift+Space)
5. Plannotator-inspired annotation UI

### P2 - Phase 4+
1. OpenRouter/Ollama local model support
2. Kimi/Qwen/Gemini adapter implementations
3. Legal/document workflow pack
4. oh-my-claudecode deep interview loop
5. Full VSCodium build integration

## Next Tasks
1. Wire real AI provider (OpenAI-compatible) with Emergent LLM key
2. Enable streaming in composer panel
3. Implement diff apply (actual file writes with approval)
4. TypeScript compilation of extension skeleton
5. VSIX build and local extension testing
