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

## Phase 1 Status

Phase 1 delivers **working scaffolds with mock data** that demonstrate the architecture:

| Component | Status | Notes |
|-----------|--------|-------|
| Repo audit | Done | VSCodium build pipeline, patches, product.json analyzed |
| AGENTS.md | Done | Canonical cross-model instruction file |
| .agents/ scaffold | Done | Three-layer harness: vendor, skills, agents+brain |
| Extension skeleton | Done | VS Code extension with TypeScript |
| Mock provider | Done | Deterministic responses, no API key needed |
| Agent roster | Done | 5 agents with roles, statuses, avatars |
| Plan file format | Done | .plan.json with steps, risk, annotations |
| Plan viewer | Done | Webview scaffold with plan display |
| Activity log | Done | Structured audit trail model |
| Diff preview | Done | Before/after with approval controls |
| Composer panel | Done | AI chat scaffold with mock provider |
| Validation script | Done | .agents/validate.sh checks all files |
| Preview dashboard | Done | Web UI for visualizing Phase 1 |
| Documentation | Done | This file |

## Project Structure

```
/app/                           # VSCodium repo root
├── AGENTS.md                   # Canonical instruction file
├── CURSOR-ING.md               # This documentation
├── .agents/                    # Agent harness (three-layer)
│   ├── registry.json           # Agent/skill/provider registry
│   ├── validate.sh             # Validation script
│   ├── model-adapters/         # Model-specific adapters
│   │   ├── claude.md
│   │   ├── codex.md
│   │   ├── kimi.md
│   │   ├── qwen-code.md
│   │   └── gemini-code.md
│   ├── vendor/                 # Read-only OSS references
│   │   └── README.md
│   ├── skills/                 # Reusable agent skills
│   │   ├── code-review.md
│   │   ├── plan-and-execute.md
│   │   └── diff-apply.md
│   ├── agents/                 # Agent role definitions
│   │   ├── planner.md
│   │   ├── coder.md
│   │   ├── reviewer.md
│   │   ├── security.md
│   │   └── browser.md
│   └── brain/                  # Memory, glossary, ADRs
│       ├── memory.md
│       ├── glossary.md
│       ├── assumptions.md
│       ├── adr/
│       │   └── 001-extension-first.md
│       ├── maps/
│       │   └── architecture.md
│       └── runbooks/
│           └── phase1-setup.md
├── extensions/
│   └── cursor-ing-ai/          # VS Code extension
│       ├── package.json         # Extension manifest
│       ├── tsconfig.json
│       └── src/
│           ├── extension.ts     # Entry point
│           ├── providers/
│           │   ├── types.ts     # Provider interface
│           │   ├── registry.ts  # Provider factory
│           │   └── mock-provider.ts
│           ├── agents/
│           │   ├── types.ts     # Agent types
│           │   └── roster.ts    # Agent roster
│           ├── plans/
│           │   ├── types.ts     # Plan format
│           │   └── plan-viewer.ts
│           ├── activity/
│           │   └── activity-log.ts
│           ├── diff/
│           │   └── diff-preview.ts
│           └── composer/
│               └── composer-panel.ts
├── backend/                    # Preview dashboard backend
│   └── server.py
└── frontend/                   # Preview dashboard frontend
    └── src/
```

## How to Run

### Validation Script
```bash
chmod +x .agents/validate.sh
./.agents/validate.sh
```

### Preview Dashboard
The preview dashboard visualizes Phase 1 components in a web browser:
- Backend: FastAPI at port 8001
- Frontend: React at port 3000
- Access via the preview URL

### Extension Development (requires full VSCodium build env)
```bash
cd extensions/cursor-ing-ai
npm install
npm run compile
```

## How to Test

1. **Validation**: Run `.agents/validate.sh` - checks all required files exist and are valid
2. **Preview Dashboard**: Open the web UI and verify all panels render
3. **API**: `curl /api/health`, `/api/agents`, `/api/plans`, `/api/activity`, `/api/diff`, `/api/providers`
4. **Mock Provider**: `POST /api/composer/chat` with a message

## Known Limitations

1. **Mock provider only** - No real AI responses in Phase 1
2. **Extension not buildable** - Requires full VSCodium build environment (Electron, node-gyp, etc.)
3. **Diff preview is read-only** - Approve/reject buttons are scaffolds
4. **No real agent orchestration** - Agents are defined but don't execute autonomously
5. **Browser agent is placeholder** - No browser automation implemented
6. **No voice input** - Ctrl+Shift+Space not implemented
7. **No streaming** - Mock provider returns complete responses
8. **Dashboard is preview** - Real UI will be IDE webview panels

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
5. Agent-to-agent handoff protocol
6. Extension compilation and VSIX packaging
