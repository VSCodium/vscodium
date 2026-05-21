# Cursor ING - Phase 1 Documentation

## What is Cursor ING?

Cursor ING is a **privacy-first, open-source, Cursor-inspired AI IDE** built on top of [VSCodium](https://vscodium.com/).

It provides:
- AI composer/chat inside the IDE
- Multi-agent team (planner, coder, reviewer, security, browser)
- Provider abstraction supporting multiple AI backends
- Structured plans with review and approval
- Activity log (audit trail) for all agent actions
- Diff preview with explicit approval before writes
- No telemetry, no tracking, no proprietary assets

## UI Specification

The Cursor ING UI is **IDE-shell-first**, not dashboard-first.
The web preview simulates a VS Code/VSCodium/Cursor-style IDE workspace:

| Zone | Element |
|------|---------|
| Top | Title bar with active file and Cursor ING branding |
| Left (48px) | Activity bar: Explorer, Search, SCM, Debug, Extensions, Agents |
| Left (240px) | Sidebar: file explorer tree or agent roster panel |
| Center top | Editor tab bar |
| Center | Main editor area: Welcome, plan document, or diff view |
| Right (360px) | AI Composer panel (chat with mock provider) |
| Bottom | Terminal / Activity Log / Problems panel |
| Bottom (22px) | Status bar: branch, agents, provider, no-telemetry, version |

Agent roster = IDE side panel. Plan viewer = editor tab. Activity log = bottom output panel.
Diff preview = code diff editor. Composer = integrated AI coding assistant panel.

## Plan Storage (Locked)

| Directory | Purpose | Contents |
|-----------|---------|----------|
| `.cursor-ing/plans/` | Runtime execution plans (single source of truth) | `.plan.json` files |
| `.agents/brain/` | Durable memory | assumptions, ADRs, glossary, maps, runbooks |

Plans are NOT duplicated in `.agents/brain/`. See ADR 002.

## Phase 1 Scope (Locked)

| Component | Status |
|-----------|--------|
| Repo audit | Done |
| AGENTS.md | Done |
| .agents/ scaffold | Done (3-layer harness, 53+ checks) |
| .cursor-ing/ workspace state | Done |
| Extension skeleton | Done (TypeScript) |
| Mock/local provider | Done (no API key) |
| Mock agent roster | Done (5 agents) |
| Plan model + viewer | Done (.plan.json format) |
| Activity log model | Done |
| Diff-preview scaffold | Done |
| IDE-shell preview | Done |
| Validation script | Done |
| Documentation | Done |

**Not in Phase 1**: real provider integration, working diff apply, agent orchestration, browser automation, voice input, cross-platform release builds.

Cross-platform release (Windows/macOS/Linux builds, CI matrix, signing) is **future documentation only**, not Phase 1 implementation.

## Project Structure

```
/app/                              # VSCodium repo root
+-- AGENTS.md                      # Canonical agent instruction file
+-- CURSOR-ING.md                  # This documentation
+-- .cursor-ing/                   # Workspace state (runtime)
|   +-- README.md
|   +-- plans/                     # Runtime plans (single source of truth)
|       +-- auth-module.plan.json
+-- .agents/                       # Agent harness (three-layer)
|   +-- registry.json
|   +-- validate.sh
|   +-- model-adapters/            # claude, codex, kimi, qwen, gemini
|   +-- vendor/                    # Read-only OSS references
|   +-- skills/                    # code-review, plan-and-execute, diff-apply
|   +-- agents/                    # planner, coder, reviewer, security, browser
|   +-- brain/                     # Durable memory (NOT plans)
|       +-- memory.md, glossary.md, assumptions.md
|       +-- adr/                   # 001-extension-first, 002-plan-storage
|       +-- maps/architecture.md
|       +-- runbooks/phase1-setup.md
+-- extensions/cursor-ing-ai/      # VS Code extension skeleton
+-- extensions/cursor-ing-design-studio/ # Design Studio extension
+-- extensions/cursor-ing-artifacts/     # Artifact Preview extension      # VS Code extension skeleton
|   +-- package.json, tsconfig.json
|   +-- src/
|       +-- extension.ts
|       +-- providers/ (types, registry, mock-provider)
|       +-- agents/ (types, roster)
|       +-- plans/ (types, plan-viewer)
|       +-- activity/ (activity-log)
|       +-- diff/ (diff-preview)
|       +-- composer/ (composer-panel)
+-- backend/server.py              # Preview API (mock data)
+-- frontend/src/                  # IDE-shell preview (React)
```

## How to Run

### Validation
```bash
chmod +x .agents/validate.sh
./.agents/validate.sh
```

### IDE Preview
Backend (FastAPI port 8001) + Frontend (React port 3000) — managed by supervisor.

### Extension Development (requires full VSCodium build env)
```bash
cd extensions/cursor-ing-ai
npm install
npm run compile
```

## How to Test

1. **Validation**: `.agents/validate.sh` checks all scaffold files exist
2. **API**: `curl /api/health`, `/api/agents`, `/api/plans`, `/api/activity`, `/api/diff`, `/api/providers`
3. **Composer**: `POST /api/composer/chat` with `{"message":"plan authentication"}`
4. **IDE Preview**: Verify IDE layout renders with all zones (title, activity bar, sidebar, editor, composer, bottom panel, status bar)

## Known Limitations

1. **Mock provider only** — no real AI responses
2. **Extension not buildable** — requires full VSCodium build environment
3. **Diff preview is read-only** — approve/reject buttons are scaffolds
4. **No agent orchestration** — agents are defined but don't execute
5. **Browser agent is placeholder** — no automation
6. **No voice input** — not Phase 1
7. **No streaming** — mock returns complete responses
8. **Cross-platform release** — future documentation only, not implemented

## Legal

- All code in `extensions/cursor-ing-ai/` is original, MIT-licensed
- No Cursor proprietary code, assets, or UI copied
- No Microsoft telemetry or tracking
- VSCodium's MIT license preserved
- Vendor references are inspiration-only pending license review

## Next Phase (Phase 2)

1. Real provider integration (OpenAI, Anthropic, Ollama)
2. Functional AI composer chat with streaming
3. Working diff application with file writes
4. Terminal command approval flow
5. Editor decorations for agent visualization

## Design Studio & Artifacts

Cursor ING includes a dedicated "Design Studio" for prompt-first UI and artifact generation, adapted from Open Design.

### Architecture
- **Design Studio**: Extension providing a generation panel with skill and design system selection.
- **Artifact Preview**: Extension providing a sandboxed webview for rendering and exporting generated HTML.
- **Design Sidecar**: Isolated runtime (mocked in Phase 1) for generation logic.

### Integration Model
1. **Prompt-first**: User describes the UI in the Design Studio panel.
2. **Skill-driven**: Agent selects appropriate design skill (landing-page, dashboard, etc.).
3. **System-aligned**: User/Agent selects a design system (minimal, apple, vercel).
4. **Sandboxed**: Generated artifacts are previewed safely and stored in `.cursor-ing/design-projects/`.
