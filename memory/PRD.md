# Cursor ING - PRD

## Product Identity
- **Name**: Cursor ING
- **Goal**: Privacy-first, open-source, Cursor-inspired AI IDE + Web Portal on VSCodium
- **License**: MIT-compatible

## Two Connected Surfaces

### Surface 1: Cursor ING IDE (Dark)
AI-first coding workspace showing real coding scenario:
- Code editor with `session.ts` open, syntax highlighting, line numbers
- Inline agent edit proposals (Accept/Reject/Dismiss) from Coder agent
- AI Composer panel (right) with multi-agent conversation (Planner plan, Reviewer risk flag)
- Activity Bar, Explorer sidebar, Bottom panel (Activity/Terminal/Problems), Status Bar
- Status: branch, 3 agents active, mock-v1, No Telemetry, v0.1.0

### Surface 2: Cursor ING Web Portal (Light)
Companion control-plane for agent management:
- New Agent prompt box with provider/team selectors + Start Agent button
- Setup Checklist (GitHub, repo, provider, plugins, first task)
- Plugins marketplace (Code Review, TypeScript Fixer, Doc Generator, Test Writer)
- Automations (PR Review on Push, Security Scan Nightly, Stale Branch Cleanup)
- Integrations (GitHub connected, GitLab pending, Mock Provider active)
- Bugbot, Shared Canvases, Members, Usage (future)

## Plan Storage (Locked)
- `.cursor-ing/plans/` = runtime plans (single source of truth)
- `.agents/brain/` = durable memory only

## Iterations
1. Scaffolding (AGENTS.md, .agents/, extension skeleton, mock provider)
2. IDE-native UI (VS Code-style shell, replaced dashboard)
3. Spec corrections (plan storage lock, validation 59 checks)
4. **Product rewrite**: Two surfaces (IDE + Web Portal), real coding scenario, inline agent edits

## Testing: All iterations 100% pass
- Backend: 16/16 tests passed
- Frontend: All IDE + Web Portal tests passed
- Validation: 59/59 scaffold checks

## Next: Phase 2
1. Real AI provider integration
2. Streaming composer chat
3. Working diff apply
4. Agent orchestration execution
5. Browser-use panel scaffold
