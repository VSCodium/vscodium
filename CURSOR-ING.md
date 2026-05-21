# Cursor ING - Phase 1 Documentation

## What is Cursor ING?

Cursor ING is a **privacy-first, open-source, Cursor-inspired AI IDE** built on top of [VSCodium](https://vscodium.com/).

This artifact represents the **Phase 1 Integration Scaffold** for Open Design into Cursor ING. It focuses on architecture, extension skeletons, and mock providers.

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

## Project Structure

```
/app/                              # VSCodium repo root
+-- AGENTS.md                      # Canonical agent instruction file
+-- CURSOR-ING.md                  # This documentation
+-- .cursor-ing/                   # Workspace state (runtime)
|   +-- design-projects/           # Generated artifacts storage
+-- .agents/                       # Agent harness (three-layer)
|   +-- vendor/                    # Read-only OSS references
|   |   +-- open-design/           # Open Design source (read-only)
|   +-- skills/                    # Curated Cursor ING skills
|       +-- design/                # Design-specific skills (landing-page, dashboard)
+-- extensions/                    # IDE Extensions
|   +-- cursor-ing-design-studio/  # Main Design Studio UI & Sidecar Adapter
|   +-- cursor-ing-artifacts/     # Sandboxed Artifact Preview & Export
+-- cursor-ing/                    # Core Cursor ING components
|   +-- sidecars/                  # Isolated runtimes
|       +-- open-design/           # Placeholder for Open Design daemon
```

## How to Run Validation
```bash
chmod +x dev/validate-design-studio.sh
./dev/validate-design-studio.sh
```

## Known Limitations (Phase 1)
1. **Mock provider only**: No real AI generation.
2. **Scaffold only**: Extensions are skeletons and require a VSCodium environment to build and run.
3. **Local sidecar**: No external daemon integrated yet.
4. **Limited exports**: Export buttons are UI scaffolds without backend implementation.

## Legal
- Original Open Design attribution (Apache 2.0) preserved.
- Cursor ING modifications are MIT licensed.
- No telemetry, tracking, or hidden network calls.
