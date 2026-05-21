# ADR 001: Extension-First Architecture

## Status
Accepted

## Context
Cursor ING needs to add AI capabilities to VSCodium. Two approaches:
1. Modify Electron/VS Code core source
2. Build as VS Code extensions

## Decision
Use VS Code extensions as the primary integration mechanism.

## Rationale
- **Upstream mergeability**: Extensions don't conflict with VSCodium patches
- **Standard APIs**: VS Code extension APIs are well-documented and stable
- **Distribution**: Extensions can be installed independently via VSIX or marketplace
- **Isolation**: Extension failures don't crash the IDE
- **Development speed**: Faster iteration than core patches

## Consequences
- Some features may be limited by extension API capabilities
- Deep IDE integration (e.g., custom editor chrome) may require future core patches
- Agent system runs in extension host process, not main process
- Webview panels for UI (not native IDE chrome)

## Alternatives Considered
- Core fork: Higher capability but breaks upstream mergeability
- Electron plugin: Non-standard, poor VS Code API access
- Language Server Protocol: Good for code intelligence, insufficient for UI

## Date
Phase 1, January 2026
