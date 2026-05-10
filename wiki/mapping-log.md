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

## Maintenance rule

After any source, build-script, workflow, patch, or product metadata change, update the affected page(s), regenerate `wiki/manifest.json`, and rerun kbmap verification. See [[workflows/knowledge-base-maintenance]].
