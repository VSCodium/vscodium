# Cursor ING Agent Instructions

## Design Studio Integration (Phase 1)

Cursor ING includes a Design Studio for generating prototypes and design artifacts.

### Layers
1. **.agents/vendor/open-design/**: Read-only vendor source for design skills and systems.
2. **.agents/skills/design/**: Curated design skills adapted for Cursor ING.
3. **extensions/cursor-ing-design-studio/**: IDE integration layer and sidecar adapter.

### Agent Workflow for Design
- When a user asks for a "design", "prototype", "landing page", or "UI concept":
  - Use the Design Studio skill registry (`.agents/skills/design/`) to identify the best fit.
  - Formulate a structured prompt for the design sidecar.
  - Trigger the generation via the Design Studio extension (`cursorIng.openDesignStudio`).
  - Guide the user through the artifact preview (`cursorIng.openArtifactPreview`) and export options.

### Guidelines
- Always preserve Open Design attribution (Apache 2.0).
- Do not modify vendor files directly.
- Ensure all generated artifacts are stored in `.cursor-ing/design-projects/`.
- Keep generation actions auditable via logs.
