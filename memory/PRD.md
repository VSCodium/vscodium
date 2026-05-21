# Cursor ING - PRD

## Product Identity
- **Name**: Cursor ING
- **Base**: VSCodium (open-source VS Code without Microsoft telemetry)
- **Goal**: Privacy-first, open-source, Cursor-inspired AI IDE
- **License**: MIT-compatible

## UI Specification (Locked)
IDE-shell-first, NOT dashboard-first. Web preview simulates VS Code/Cursor workspace:
- Title bar, Activity bar (6 icons), Sidebar (explorer/agents), Editor tabs, Editor area, Composer panel (right), Bottom panel (activity/terminal/problems), Status bar

## Plan Storage (Locked)
- `.cursor-ing/plans/` = runtime execution plans (single source of truth)
- `.agents/brain/` = durable memory, assumptions, ADRs, glossary, maps, runbooks
- No duplication. See ADR 002.

## Phase 1 Scope (Locked)
AGENTS.md, .agents scaffold, extension skeletons, mock/local provider, mock agent roster, plan model, activity log model, diff-preview scaffold, IDE-shell preview, validation script, documentation.
NOT in Phase 1: real providers, working diff apply, agent orchestration, browser automation, voice, cross-platform release.

## What's Been Implemented

### Iteration 1 - Scaffolding
- Repo audit, AGENTS.md, .agents/ 3-layer harness (53 checks)
- Extension skeleton, mock provider, agent roster, plan/activity/diff models

### Iteration 2 - IDE-Native UI
- Complete rewrite from dashboard to VS Code/Cursor-style IDE shell
- TitleBar, ActivityBar, Sidebar, EditorTabs, Editor Area, Composer, BottomPanel, StatusBar

### Iteration 3 - Spec Corrections
- Locked plan storage: .cursor-ing/plans/ (runtime) vs .agents/brain/ (durable memory)
- Added ADR 002, .cursor-ing/README.md, auth-module.plan.json
- Updated validation to 59 checks (includes plan storage rule enforcement)
- Updated sidebar explorer to show .cursor-ing/plans/ path
- Updated AGENTS.md and CURSOR-ING.md with UI spec and storage rules
- Cross-platform release marked as future documentation only

### Testing
- Iteration 1: Backend 16/16, Frontend 100%
- Iteration 2: Backend 16/16, Frontend 100%
- Iteration 3: Backend 16/16, Frontend 100%, Validation 59/59

## Backlog
### P0 - Phase 2
1. Real AI provider (OpenAI/Anthropic)
2. Streaming composer chat
3. Working diff apply
4. Terminal command approval
5. Extension TypeScript compilation

### P1 - Phase 3+
1. Editor decorations (Clicky-style agent visualization)
2. Browser-use panel
3. Multi-agent orchestration
4. Plannotator annotations
5. Voice input architecture

### P2 - Future
1. Domain packs (legal/document review)
2. Ollama local model support
3. Cross-platform release builds (Windows/macOS/Linux)
