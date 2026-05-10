---
description: Detect schema drift between this project's wiki and the canonical kbmap template; preview or apply safe kit updates.
argument-hint: [--preview|--apply]
---

You are running the `/kbmap-upgrade` workflow. Your job is to detect when this project's wiki contains schema/template files that have drifted from or fallen behind the canonical kbmap template kit, then use the deterministic preview/apply commands for safe updates.

## Context

When this project was bootstrapped, `bootstrap.sh` recorded the SHA256 hash of every tracked schema/template file in `wiki/.kbmap-versions.json`. The tracked files include:

- `_schema.md`
- `ingest-schema.md`, `lint-schema.md`, `query-schema.md`
- `frontmatter-schema.md`, `manifest-schema.md`
- `components/_mapping-template.md`
- `features/_mapping-template.md`
- `workflows/_mapping-template.md`
- `integrations/_mapping-template.md`
- `decisions/_mapping-template.md`
- `glossary/_mapping-template.md`
- `actions/_mapping-template.md`

These files are an external API contract for `wiki-mcp` and other consumers. Drift between this project and the canonical kit means consumers may behave inconsistently.

## Workflow

1. **Locate the template kit.**
   - Read `${KBMAP_PATH}` from `~/.kbmap` (a symlink or text file the user set during install) OR ask the user for the absolute path to their `codebase-map/` template kit.

2. **Run the deterministic read-only check first.**

   ```bash
   python3 ${KBMAP_PATH}/scripts/kbmap-upgrade-check.py ${PROJECT_ROOT} --kit-dir ${KBMAP_PATH}
   ```

   If `wiki/.kbmap-versions.json` is missing, this project predates the drift-tracking system. Tell the user, offer to create a fresh baseline with `bash ${KBMAP_PATH}/bootstrap.sh ${PROJECT_ROOT}` (which is idempotent and won't overwrite their wiki content), then stop.

3. **Classify each tracked file from the tool output.**
   - **CLEAN** — wiki copy matches recorded hash AND recorded hash matches canonical kit. No action needed.
   - **PROJECT-MODIFIED** — wiki copy differs from recorded hash; canonical kit still matches recorded. The user has edited their copy locally.
   - **KIT-AHEAD** — wiki copy matches recorded hash; canonical kit differs from recorded. The template was updated upstream since this project was bootstrapped, so there is a clean upgrade path available.
   - **DIVERGED** — wiki copy AND canonical kit both differ from recorded hash. This needs manual review.
   - **MISSING-INSTALLED** or **MISSING-KIT** — a tracked file is missing and needs manual repair.

4. **Report findings** in a concise table:

   ```
   File                                     | State            | Action
   -----------------------------------------|------------------|------------------
   _schema.md                               | CLEAN            | none
   ingest-schema.md                         | KIT-AHEAD        | upgrade
   features/_mapping-template.md            | PROJECT-MODIFIED | preserve / merge
   ...
   ```

5. **Preview safe updates before writing.**

   ```bash
   python3 ${KBMAP_PATH}/scripts/kbmap-upgrade-apply.py ${PROJECT_ROOT} --kit-dir ${KBMAP_PATH} --preview
   ```

   The preview must show which files are safe `KIT-AHEAD` updates and which files are blocked for manual review.

6. **Apply only safe updates if requested.**

   ```bash
   python3 ${KBMAP_PATH}/scripts/kbmap-upgrade-apply.py ${PROJECT_ROOT} --kit-dir ${KBMAP_PATH} --apply
   ```

   The apply command only writes `KIT-AHEAD` files, refuses dirty git worktrees by default, backs up replaced files under `wiki/.kbmap-upgrade-backups/`, and updates `wiki/.kbmap-versions.json`. It never applies `PROJECT-MODIFIED`, `DIVERGED`, `MISSING-INSTALLED`, or `MISSING-KIT` files.

7. **Manifest version check** (T10.6):
   - Read `${KBMAP_PATH}/manifest-schema.md` frontmatter `manifest_version`. Compare to this project's `wiki/manifest.json` `manifest_version`.
   - If the kit's manifest version is higher than the project's, prompt: "The template kit's manifest schema is at v[X], but this project's manifest is v[Y]. This is a breaking change for MCP consumers. Run `/lint` after this upgrade to regenerate `manifest.json` at the new version." Do NOT auto-regenerate — let the user trigger lint explicitly.

8. **Append a log entry** to `wiki/mapping-log.md` if files were applied:

   ```
   ## [DATE] — kbmap-upgrade

   **kbmap version:** [old] → [new]
   **Files upgraded:** [list]
   **Files preserved (project-modified):** [list]
   **Files diverged (manual resolution needed):** [list]
   **Manifest version:** [old] → [new] (regenerate via /lint)
   ```

9. **Emit the contract line** as your final user-facing line:
    - `KBMAP-UPGRADE: done — N files upgraded, M preserved, K diverged`
    - `KBMAP-UPGRADE: skipped — no drift detected`
    - `KBMAP-UPGRADE: failed — <error>`

## Safety

- NEVER modify any file inside `${KBMAP_PATH}` itself (the canonical kit).
- NEVER auto-resolve DIVERGED files — that requires user judgment.
- NEVER overwrite `wiki/.endpoints.json`, `wiki/manifest.json`, or any user-authored content (component pages, feature pages, etc.) — those are not tracked by the drift baseline.
- ALWAYS preserve a backup of any file you replace by copying it to `wiki/.kbmap-upgrade-backups/<timestamp>/<file>` before overwriting. The deterministic apply command does this for `KIT-AHEAD` files.
