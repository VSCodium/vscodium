# ADR 002: Plan Storage Location

## Status
Accepted

## Context
Plans could be stored in `.agents/brain/plans/` (inside the agent harness) or in `.cursor-ing/plans/` (workspace-level state). Storing in both creates duplication and ambiguity.

## Decision
- **`.cursor-ing/plans/`** is the single source of truth for runtime execution plans.
- **`.agents/brain/`** holds only durable memory: assumptions, ADRs, glossary, maps, runbooks.
- Plans are NOT stored in `.agents/brain/`.

## Rationale
- Plans are mutable runtime state; brain is durable knowledge.
- Separating concerns prevents confusion about which version of a plan is canonical.
- `.cursor-ing/` is workspace-scoped and may be gitignored; `.agents/` is project-level and committed.

## Consequences
- All plan read/write operations target `.cursor-ing/plans/`.
- Brain documents may reference plan IDs but do not contain plan data.
- The validation script checks both directories exist but does not expect plans in brain.

## Date
Phase 1 correction, January 2026
