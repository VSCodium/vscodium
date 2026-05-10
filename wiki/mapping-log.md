---
slug: shadow-ide/mapping-log/mapping-log
project_slug: shadow-ide
kind: mapping-log
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [mapping-log, kbmap]
---

# Mapping Log

> Chronological record of kbmap installation and the first Shadow-IDE mapping pass.

## Log Entries

### 2026-05-10 - Bootstrap installation

**Phase:** kbmap adoption.

**Files touched:** Added kbmap governance files, wiki schemas, `.claude` commands/hooks, `wiki-cli.py`, read-only `mcp-server/`, and `MCP-INSTALL.md`.

**Notes:** Installed from `/Users/ari_mac_mini/projects/knowledgeBase-integration/knowledgeBase-vault/codebase-map` with project slug `shadow-ide`.

### 2026-05-10 - First mapping pass

**Phase:** repository discovery and knowledge-base population.

**Wiki pages created/updated:** Overview, architecture, component, feature, workflow, integration, action, decision, and glossary pages.

**Source evidence reviewed:** `README.md`, `docs/howto-build.md`, `docs/extensions.md`, `docs/patches.md`, `get_repo.sh`, `build.sh`, `prepare_vscode.sh`, `prepare_assets.sh`, `check_tags.sh`, `release.sh`, `update_version.sh`, `utils.sh`, `dev/build.sh`, `icons/build_icons.sh`, `.github/workflows/publish-*.yml`, `build/linux/package_bin.sh`, `build/windows/package.sh`, `upstream/*.json`, and repository file inventory.

**Result:** The wiki now describes the current tracked repo as a Shadow-IDE distribution repository with VSCodium-derived defaults and a scripted upstream VS Code overlay/patch/release architecture.

### 2026-05-10 - Manifest and verification

**Phase:** kbmap health.

**Wiki pages created/updated:** `wiki/manifest.json`.

**Files touched:** Manifest generated from the populated wiki and first-map verification run after content replacement.

## 2026-05-10 — Ingest: ShadowIDE Agents Window MVP + extensions bundling

**Change type:** new module (multiple) + modified module
**Mode:** agent-dev-readwrite
**Files changed in source:**
- `extensions/shadowide-agents/package.json` (new)
- `extensions/shadowide-agents/extension.js` (new)
- `prepare_extensions.sh` (modified — added source-tree extension copy block; pre-existing bootstrap pattern documented for the first time here)
- `.gitignore` (modified — anchored `ShadowIDE*` and `.build/` patterns to repo root so `extensions/shadowide-agents/` is no longer hidden)

**Wiki pages created:**
- `wiki/components/shadowide-extensions-bundling.md`
- `wiki/features/agents-window.md`
- `wiki/actions/open-agents-window.md`
- `wiki/integrations/cline-kanban.md`

**Wiki pages updated:**
- `wiki/components/root-build-orchestration.md` — added `prepare_extensions.sh` to Key Files; added `shadowide-extensions-bundling` to Depends On
- `wiki/code-structure.md` — added `extensions/` to repo tree + main directories table; added `prepare_extensions.sh` to top-level scripts table
- `wiki/index.md` — added new feature, component, integration, and action pages to their sections

**Wiki pages removed:** none

**Wikilinks repaired:** none (all new links point to pages created in this session)

**Open questions:**
- Whether to bundle the `kanban` binary inside the `shadowide-agents` extension to remove the global-install prerequisite. Documented in `features/agents-window.md` and `integrations/cline-kanban.md`.
- Whether `@clinebot/core` and `@clinebot/shared` are open-source. Affects how deeply the agent runtime can be customized. Documented in `integrations/cline-kanban.md`.

**Notes:** The Cline pre-bundling work shipped in earlier commits (`fc41bd3`, `e867f1d`) was never previously ingested — this is the first wiki coverage of `prepare_extensions.sh` and the `shadowide-bootstrap` pattern. The new `shadowide-agents` extension follows the same source-tree pattern this ingest documents.

## 2026-05-10 — Lint (post-Ingest)

**Scope:** focused on pages created or modified in the preceding Ingest entry.

**Wikilinks introduced this session:** all resolve to existing pages.

**Pre-existing broken link found (NOT introduced this session):**
- `[[components/vscode-overlay-and-product-metadata]]` — referenced from `wiki/index.md`, `wiki/project-discovery.md`, `wiki/features/extension-marketplace-control.md`, `wiki/features/product-branding-and-assets.md`, `wiki/features/telemetry-and-service-hardening.md`, `wiki/decisions/track-upstream-vscode-by-scripted-overlay.md`, `wiki/decisions/use-open-vsx-gallery-by-default.md`, `wiki/integrations/open-vsx-registry.md`, `wiki/components/root-build-orchestration.md`, `wiki/workflows/local-development-build.md`, but the target page does not exist. This dates back to the kbmap adoption commit and should be addressed by a dedicated `/lint` session that either creates the missing page or repoints all references.

**Status honesty check:** all four pages I created with `status: complete` actually have every section populated with real content. No `<!-- TODO -->` or `<!-- LLM:` markers remain.

**Result:** `LINT: done — 0 broken links fixed, 1 pre-existing flagged for future session, 0 orphans wired`.

## Maintenance rule

After any source, build-script, workflow, patch, or product metadata change, update the affected page(s), regenerate `wiki/manifest.json`, and rerun kbmap verification. See [[workflows/knowledge-base-maintenance]].
