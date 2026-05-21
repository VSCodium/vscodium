# AGENTS.md - Cursor ING Canonical Instruction File
# This is the shared instruction file for ALL LLMs and coding agents.
# Model-specific adapters live in .agents/model-adapters/

## Product Identity

- **Name**: Cursor ING
- **Base**: VSCodium (open-source VS Code without Microsoft telemetry)
- **Goal**: Privacy-first, open-source, Cursor-inspired AI IDE
- **License**: MIT-compatible

## Architecture

Cursor ING extends VSCodium through VS Code extensions, not core patches.
The primary integration point is the `extensions/cursor-ing-ai/` extension.

### Extension Entry Point
- `extensions/cursor-ing-ai/src/extension.ts`
- Registers commands, webview panels, sidebar views

### Provider Abstraction
- `src/providers/types.ts` - Provider interface
- `src/providers/registry.ts` - Provider registry/factory
- `src/providers/mock-provider.ts` - Deterministic mock (no API key needed)
- Future: OpenAI, Anthropic, Ollama, OpenRouter adapters

### Agent System
- `src/agents/types.ts` - Agent roles, statuses, permissions
- `src/agents/roster.ts` - Agent roster with planner/coder/reviewer/security/browser
- Each agent has: role, status, avatar, permissions, tool access

### Plan Model
- `src/plans/types.ts` - Plan file format (.plan.json)
- `src/plans/plan-viewer.ts` - Plan viewer/editor scaffold
- Plans have steps, statuses, annotations, approval states

### Plan Storage (Locked)
- **`.cursor-ing/plans/`** = runtime execution plans (single source of truth)
- **`.agents/brain/`** = durable memory, assumptions, ADRs, glossary, maps, runbooks
- Do NOT duplicate plan state in both places. See ADR 002.

### Activity Log
- `src/activity/activity-log.ts` - Structured audit trail
- Logs: file reads, edits, commands, browser actions, handoffs

### Diff Preview
- `src/diff/diff-preview.ts` - Diff preview with approval controls
- Shows before/after, requires explicit approval before writes

## Agent Harness (.agents/)

Three-layer structure:
1. **Vendor** (.agents/vendor/) - Read-only open-source references
2. **Skills** (.agents/skills/) - Curated reusable skills
3. **Domain** (.agents/agents/ + .agents/brain/) - Cursor ING-specific

## Workspace State (.cursor-ing/)

- `.cursor-ing/plans/` - Runtime execution plans (single source of truth)
- `.cursor-ing/` may hold future per-project config and session state
- Plans are NOT stored in `.agents/brain/`. Brain holds durable knowledge only.

## Rules for All Agents

1. Read before write. Inspect files before modifying.
2. Prefer extensions over core patches.
3. Keep upstream VSCodium mergeability.
4. No telemetry. No secrets. No proprietary assets.
5. Explicit approval required for: file writes, shell commands, browser actions, network calls.
6. All actions must be logged to the activity log.
7. Never claim a feature is implemented unless code exists.
8. Mark placeholders clearly with `[PLACEHOLDER]` or `[TODO]`.

## Model-Specific Adapters

Model-specific instructions are NOT the primary instruction file.
They are adapters that translate AGENTS.md conventions:
- `.agents/model-adapters/claude.md`
- `.agents/model-adapters/codex.md`
- `.agents/model-adapters/kimi.md`
- `.agents/model-adapters/qwen-code.md`
- `.agents/model-adapters/gemini-code.md`

## Development Phases

### Phase 1 (Current)
- Repo audit
- AGENTS.md + .agents/ scaffold
- Extension skeleton with mock provider
- Agent roster, plan model, activity log, diff preview
- Validation script
- Documentation

### Phase 2 (Next)
- Real provider integration (OpenAI, Anthropic, Ollama)
- Functional AI composer chat
- Working diff application
- Terminal command approval flow

### Phase 3 (Future)
- Multi-agent orchestration
- Browser-use panel
- Voice input (Ctrl+Shift+Space)
- Legal/document workflow pack

### Phase 7+ (Future Documentation Only)
- Cross-platform build/release (Windows, macOS, Linux)
- CI matrix, signing, notarization
- Not a Phase 1 implementation target

## UI Specification

The Cursor ING preview and production UI must be **IDE-shell-first**, not dashboard-first.
Any web preview must simulate a VS Code/VSCodium/Cursor-style IDE workspace:
- Top title/menu/command area
- Left activity bar (Explorer, Search, Source Control, Run, Extensions, Agents)
- Left sidebar (file explorer or agent roster)
- Editor tab bar
- Main editor area (code, plan document, diff view)
- Right AI composer/agent panel
- Bottom terminal/output/activity log panel
- Bottom status bar

Do not use SaaS dashboard navigation, admin tables, or standalone dashboard pages.

## Design Studio Integration (Phase 1)

Cursor ING includes a Design Studio for generating prototypes and design artifacts.

### Layers
1. **.agents/vendor/open-design/**: Read-only vendor source for design skills and systems.
2. **.agents/skills/design/**: Curated design skills adapted for Cursor ING.
3. **extensions/cursor-ing-design-studio/**: IDE integration layer and sidecar adapter.

### Agent Workflow for Design
- When a user asks for a "design", "prototype", "landing page", or "UI concept":
  - Use the Design Studio skill registry to identify the best fit.
  - Formulate a structured prompt for the design sidecar.
  - Trigger the generation via the Design Studio extension.
  - Guide the user through the artifact preview and export options.

### Guidelines
- Always preserve Open Design attribution (Apache 2.0).
- Do not modify vendor files.
- Ensure all generated artifacts are stored in `.cursor-ing/design-projects/`.
