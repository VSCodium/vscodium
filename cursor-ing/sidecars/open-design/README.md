# Open Design Sidecar

This directory is reserved for the Open Design daemon/sidecar runtime.

## Interface
The sidecar must implement the standard Open Design contract:
- start/stop
- status
- generate artifact
- list skills/systems
- read project

## Status
Phase 1: Using mock adapter in `extensions/cursor-ing-design-studio/src/sidecar-adapter.ts`.
Phase 2: Integration of real Open Design daemon here.
