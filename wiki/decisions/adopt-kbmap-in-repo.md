---
slug: shadow-ide/decision/adopt-kbmap-in-repo
project_slug: shadow-ide
kind: decision
audience: [dev, agent]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
decision_status: accepted
superseded_by:
components: [shadow-ide/component/wiki-mcp-server]
tags: [kbmap, knowledge-base, adr]
---

# Adopt kbmap In Repo

> We keep a durable kbmap knowledge base inside Shadow-IDE so future agents and developers can retrieve project context locally.

## Status

**Accepted** - adopted 2026-05-10.

## Context

Shadow-IDE is a build/distribution repository with many cross-cutting scripts, patches, workflows, and platform-specific behaviors. Context is easy to lose between sessions, especially when product branding and upstream patch drift interact.

## Decision

Install kbmap into this repository and maintain `wiki/`, `mcp-server/`, `MCP-INSTALL.md`, `.claude/commands`, and governance files as project-owned assets.

## Consequences

### Positive

- Agents can answer project questions from local documentation.
- Source changes can be paired with wiki updates.
- The manifest gives a deterministic retrieval surface.

### Negative

- More files exist in the repo and must be maintained.

### Neutral / accepted trade-offs

- The MCP server is read-only; executable actions remain separate contracts.

## Alternatives considered

- External-only wiki - rejected because the repo should carry its own working memory.
- No knowledge base - rejected because the build/release surface is too broad for reliable ad hoc rediscovery.

## Related

- [[components/wiki-mcp-server]]
- [[features/knowledge-base-read-side-access]]

## Open questions

None at this time.
