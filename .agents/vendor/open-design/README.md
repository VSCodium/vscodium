# Open Design - Vendor Reference

**Source**: https://github.com/Biyocon/open-design (preferred fork)
**Upstream**: https://github.com/nexu-io/open-design
**License**: Apache 2.0 (compatible with Cursor ING MIT)
**Status**: Audited, adapter interfaces created, full port pending

## Audit Summary

### Repository Structure
- `apps/daemon/` — Node.js generation daemon (TypeScript, ~90 source files)
- `apps/desktop/` — Electron desktop app
- `apps/web/` — Web frontend
- `packages/contracts/` — Shared interfaces (TaskState, TaskStatus, JSON constraints)
- `packages/sidecar/` — Lightweight sidecar adapter
- `packages/platform/` — Platform abstraction
- `skills/` — 124 design skills (dashboard, landing-page, blog-post, etc.)
- `design-systems/` — 150 design systems (vercel, minimal, apple, airbnb, etc.)
- `prompt-templates/` — Image and video prompt templates
- `craft/` — Design quality guidelines (accessibility, animation, color, UX laws)

### Skill Format (SKILL.md frontmatter)
```yaml
name: dashboard
description: Admin/analytics dashboard in a single HTML file
triggers: ["dashboard", "admin panel", "analytics"]
od:
  mode: prototype
  platform: desktop
  scenario: operations
  preview:
    type: html
    entry: index.html
  design_system:
    requires: true
    sections: [color, typography, layout, components]
  craft:
    requires: [state-coverage, accessibility-baseline, laws-of-ux]
```

### Design System Format (DESIGN.md)
Markdown with structured sections: Visual Theme, Color (tokens), Typography, Spacing, Components.

### Key Contracts
- `TaskState`: queued | starting | running | succeeded | failed | cancelled
- `TaskStatus`: id, state, label, detail, timestamps
- `BoundedJsonConstraints`: depth, keys, array length, string length, bytes

### Reusable Parts for Cursor ING
1. **Skill metadata format** → `.agents/skills/design/`
2. **Design system metadata** → Design Studio selector
3. **Sidecar interface** → Mock adapter in Phase 1
4. **Task/TaskStatus types** → Extension contracts
5. **Craft guidelines** → Quality checks
6. **Artifact preview** → Sandboxed webview

## Rules
1. This directory is READ-ONLY. Do not edit files here.
2. Do not copy code without license review.
3. Use adapter interfaces; mark full integration as pending.
4. Preserve Apache 2.0 attribution in any derived code.
