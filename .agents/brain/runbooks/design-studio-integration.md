# Design Studio Integration Runbook

## Overview
This runbook covers the integration of Open Design into Cursor ING as an IDE-native capability.

## Architecture
- **Extensions**: Located in `extensions/`.
  - `cursor-ing-design-studio`: Main UI and generation logic.
  - `cursor-ing-artifacts`: Sandboxed preview and export.
- **Sidecar**: Reserved space in `cursor-ing/sidecars/open-design/`.
- **Output**: Generated artifacts go to `.cursor-ing/design-projects/`.

## Development
- Use `npm run compile` in extension directories to build.
- Mock provider is implemented in `sidecar-adapter.ts`.
- Real daemon integration will replace the `MockDesignSidecar`.

## Validation
Run `./dev/validate-design-studio.sh` to verify the scaffold.
