# Design Studio Integration Runbook

## Overview
This runbook covers the Phase 1 integration of Open Design into Cursor ING as an IDE-native capability.

## Architecture
- **Extensions**: Located in `extensions/`.
  - `cursor-ing-design-studio`: Main UI and generation logic. Uses `cursorIng.openDesignStudio` command.
  - `cursor-ing-artifacts`: Sandboxed preview and export. Uses `cursorIng.openArtifactPreview` command.
- **Sidecar**: Reserved space in `cursor-ing/sidecars/open-design/`.
- **Output**: Generated artifacts go to `.cursor-ing/design-projects/`.

## Changed/Added Files
- `extensions/cursor-ing-design-studio/`: Skeleton, package.json, tsconfig.json, src/
- `extensions/cursor-ing-artifacts/`: Skeleton, package.json, tsconfig.json, src/
- `.cursor-ing/design-projects/`: Workspace storage.
- `cursor-ing/sidecars/open-design/`: Sidecar placeholder.
- `.agents/skills/design/`: Curated design skills (JSON).
- `dev/validate-design-studio.sh`: Validation script.
- `AGENTS.md`: Updated agent instructions.
- `CURSOR-ING.md`: Updated architecture docs.

## Known Limitations
- Mock sidecar only: No real AI generation in Phase 1.
- UI Scaffolds: Webview buttons do not trigger external logic.
- Environment: Requires VSCodium environment to compile and run.

## Validation
Run `./dev/validate-design-studio.sh` to verify the scaffold.
