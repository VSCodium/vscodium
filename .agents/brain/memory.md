# Brain: Memory

Working memory for Cursor ING agents. Updated during sessions.

## Session Context
- Current phase: Phase 1 (scaffold)
- Last audit: VSCodium repo structure, build pipeline, patches, product.json
- Active agents: None (Phase 1 = scaffold only)

## Key Decisions
1. Extension-first architecture (no core patches)
2. Mock provider for Phase 1 (no API keys)
3. Three-layer .agents/ harness
4. TypeScript for extension code
5. Activity log as structured audit trail

## Open Questions
- [ ] Browser automation library selection (Playwright adapter?)
- [ ] Voice input implementation approach
- [ ] Multi-agent orchestration protocol
- [ ] Local model hosting strategy (Ollama integration)

## File Map (Key Files)
- `/AGENTS.md` - Canonical instruction file
- `/extensions/cursor-ing-ai/` - Main extension
- `/.agents/` - Agent harness
- `/CURSOR-ING.md` - Documentation
