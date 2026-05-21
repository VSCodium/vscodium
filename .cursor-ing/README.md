# .cursor-ing/ - Cursor ING Workspace State

This directory holds **runtime project state** for Cursor ING.

## Structure

```
.cursor-ing/
  plans/           <- Runtime execution plans (the single source of truth for plans)
  state/           <- Future: workspace-level agent state, session data
  config/          <- Future: per-project Cursor ING configuration
```

## Rules

1. **Plans live here.** `.cursor-ing/plans/` is the only place runtime plans are stored.
2. **Do NOT duplicate plans** in `.agents/brain/`. The brain holds durable memory, assumptions, ADRs, glossary, and maps -- not runtime plans.
3. Plans are `.plan.json` files following the `cursor-ing-plan-v1` schema.
4. This directory is workspace-scoped and may be gitignored for private projects.

## Separation of Concerns

| Directory | Purpose | Lifecycle |
|-----------|---------|-----------|
| `.cursor-ing/plans/` | Runtime execution plans | Per-session, mutable |
| `.agents/brain/` | Durable memory, assumptions, ADRs, glossary, maps, runbooks | Long-lived, append-only |
| `.agents/skills/` | Reusable agent skills | Curated, versioned |
| `.agents/agents/` | Agent role definitions | Stable |
| `.agents/vendor/` | Read-only OSS references | Pulled from upstream |
