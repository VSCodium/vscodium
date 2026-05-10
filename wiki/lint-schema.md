---
type: schema
purpose: LLM instructions for wiki maintenance passes — staleness detection, cross-reference repair, accuracy verification
version: "1.0"
---

# Lint Schema — Wiki Maintenance Pass

You are auditing the wiki for drift. Code changes since the last mapping may have made some wiki pages inaccurate, incomplete, or disconnected. Your job is to find the gaps and fix them.

You are NOT ingesting a specific code change. You are reviewing the entire wiki (or a targeted subset) against the current source and applying all fixes in the same session.

---

## Safety Rules (Non-Negotiable)

1. **NEVER** modify, delete, or rename any source code file in the project.
2. **NEVER** modify any file inside `codebase-map/` — it is the template kit.
3. **NEVER** modify this schema file itself. It is a read-only instruction document copied from the template kit. If you accidentally edit it, restore it from the template kit's `lint-schema.md`.
4. **NEVER** execute code from the project (no `npm start`, no `python main.py`, etc.) unless the user explicitly asks.
5. **NEVER** install dependencies or run build commands.
6. **NEVER** create a `[[wikilink]]` to a page that does not exist.
7. You may **read** any file in the project. You may run read-only shell commands (`find`, `grep`, `wc`) to scan the wiki and source.
8. All wiki output goes to `OUTPUT_PATH`.

---

## Mode

All Lint sessions run in **Fix mode**: scan the wiki, then apply all fixes in the same session without waiting for confirmation.

Merge candidates are never merged automatically — flag them for the user to decide per case.

---

## Resuming an Interrupted Lint Session

If starting a new session on an in-progress Lint:
1. Read `wiki/mapping-log.md` — find the last Lint entry and which phase it completed
2. Resume from the earliest incomplete phase. Do not redo completed phases.

---

## Lint Workflow

Follow these phases in order. **Do not skip phases.**

---

### Phase L-0 — Orient

1. Read `wiki/index.md` to get the full list of wiki pages.
2. Read `wiki/_schema.md` for this project's wiki conventions.
3. Read `wiki/mapping-log.md` — note the date of the last Ingest or Lint entry. This tells you how long the wiki has gone without maintenance.
4. Confirm **scope** with the user:
   - **Full lint** — review every component and architecture page in the wiki
   - **Targeted lint** — review specific pages or components named by the user
5. State your plan to the user:
   > "Running a [full / targeted] lint. Last wiki update was [date]. I'll scan [N] pages and apply all fixes."

---

### Phase L-0.5 — Frontmatter Validation Scan (NEW in Phase III.5)

This phase runs before wikilink scanning because malformed frontmatter can cause false positives in later phases. Read [[frontmatter-schema]] for the full spec being validated.

For every page in the wiki:

1. **Required field check.** Every page must have `slug`, `project_slug`, `kind`, `audience`, `version`, `last_updated`, `mapped_date`, `status`. Missing field → `FRONTMATTER MISSING — [page] — [field]`.
2. **Slug grammar check.** `slug` must match `^[a-z0-9-]+/(component|feature|workflow|integration|decision|glossary|architecture|query-result|action|mapping-log|overview|schema)/[a-z0-9-]+$`. Otherwise → `FRONTMATTER BAD SLUG — [page] — [slug]`.
3. **Slug uniqueness.** No two pages may share a `slug`. Duplicate → `FRONTMATTER DUPLICATE SLUG — [slug] — [page-a], [page-b]`.
4. **Kind ↔ path consistency.** A page with `kind: action` must live in `wiki/actions/`; `kind: feature` in `wiki/features/`; etc. Mismatch → `FRONTMATTER KIND-PATH MISMATCH — [page] — kind: [kind], path: [path]`.
5. **Kind-specific required fields:**
   - `kind: action` MUST have `executable: true`, `endpoint` (non-empty string), `endpoint_kind`, `auth_required`, `confirmation_required`, `idempotent`, `feature` (non-empty slug).
   - `kind: integration` MUST have `vendor` (non-empty), `protocol` (from enum), at least one entry in `features:`.
   - `kind: decision` MUST have `decision_status` (from enum); if `decision_status: superseded`, `superseded_by` MUST be a real decision slug.
   - `kind: component` MUST have `source_path` (and the path must exist in source).
6. **Audience tag validity.** `audience` must be a non-empty subset of `[dev, user, agent]`, OR exactly `[all]`. If `audience: [all]`, the page MUST contain three section headers: `## For developers`, `## For users`, `## For agents`. Missing header → `AUDIENCE MISSING SECTION — [page] — [missing header]`. If audience is single-list (e.g. `[dev, agent]`), the page MUST NOT contain section headers for the OTHER audience (`## For users` would be drift). Mismatched → `AUDIENCE DRIFT — [page] — has [unexpected header] but audience is [list]`.
7. **Cross-reference resolution.** Every slug appearing in `components`, `features`, `actions`, `workflows`, `feature` (singular), `superseded_by` MUST resolve to an actual page in this wiki. Unresolved → `FRONTMATTER BAD XREF — [page] — [field]: [slug]`.
8. **Bidirectional feature ↔ action.** For every `kind: action` page with `feature: <X>`, the page at slug `<X>` MUST have `<this-action's-slug>` in its `actions:` list. Asymmetric → `BIDI MISSING — [feature-page] — actions: should include [action-slug]` OR vice versa.
9. **Action endpoint validity.** For every `kind: action` page, `endpoint` MUST match an entry in `wiki/.endpoints.json` (the per-project endpoint manifest). The manifest is maintained by the user / generated from the app's OpenAPI / MCP server introspection. Missing → `ACTION ENDPOINT STALE — [page] — endpoint [X] not in .endpoints.json`. If `wiki/.endpoints.json` does not exist yet, log a warning but do not fail — the user is still building it.
10. **`side_effects` controlled vocabulary.** For action pages, every entry in `side_effects` must be from the canonical list (see [[frontmatter-schema]]). Unknown value → `ACTION BAD SIDE_EFFECT — [page] — [value]`.
11. **Action safety gate metadata.** For action pages with any `side_effects` value other than `none`, validate `dry_run_supported`, `dry_run_param`, `test_mode_supported`, `test_mode_param`, and `live_execution_requires_approval`. Side-effecting actions must declare those fields, must set `live_execution_requires_approval: true`, and must include a `## Safety gates` section. If `dry_run_supported: true`, `dry_run_param` must be non-empty. If `test_mode_supported: true`, `test_mode_param` must be non-empty. Actions that do not yet have dry-run or test-mode support may pass only as policy-inspection-only contracts when their Safety gates section says they must not be executed by `app-actions-mcp` until a safe path exists. Actions with `side_effects: [none]` may omit dry-run/test-mode fields. Missing or inconsistent safety metadata → `ACTION SAFETY METADATA — [page] — [field/problem]`.
12. **Glossary scope check.** For every `kind: glossary` page, count inbound wikilinks (other wiki pages linking to it via `[[glossary/term]]` or via the term's slug). If fewer than 2 inbound links → `GLOSSARY ORPHAN — [page] — only [N] inbound links; consider removing or inlining`.

Collect all findings. Apply fixes in Phase L-6. Do not fix in this phase.

---

### Phase L-1 — Wikilink Integrity Scan

This is a mechanical pass. No fixes yet — just collect all broken links.

1. Run: `grep -r "\[\[" [OUTPUT_PATH] --include="*.md" -h | grep -o "\[\[[^\]]*\]\]" | sort | uniq`
   This gives you every unique wikilink target across the entire wiki.
2. For each unique target `[[target]]`, check whether `OUTPUT_PATH/target.md` exists.
3. Collect all broken wikilinks as:
   ```
   BROKEN WIKILINK — [[target]] — found in: [page1.md], [page2.md]
   ```
4. Do not fix anything yet. Move to the next phase.

---

### Phase L-2 — Staleness Scan

For each wiki page in scope, check whether the wiki's claims still match the source.

For each component page (`wiki/components/[name].md`):
1. Note the `mapped_date` in the frontmatter.
2. Read the corresponding source files listed in that page's `## Source Location` and `## Key Files` sections.
3. Check each section against the source:
   - **Purpose** — does the description still match what the code does?
   - **Source Location** — do the file paths still exist?
   - **Key Files** — do those files still exist and still play the roles described?
   - **How It Works** — does the logic description match the current implementation?
   - **Error Handling** — still accurate?
   - **Dependencies** — do the listed dependencies match the current imports/requirements?
   - **Data Flow** — does the Mermaid diagram still reflect the actual flow?
   - **API / Interface** — do function signatures, endpoints, or exports still match?
4. For every discrepancy found, record:
   ```
   STALE — [page.md] — [section] — [what the wiki says vs. what the source shows]
   ```

For architecture pages (`wiki/architecture/overview.md`, `wiki/architecture/tech-stack.md`):
- Check the Mermaid diagram in overview.md against the current high-level structure
- Check every row in tech-stack.md against the current package manifests / config files
- Record staleness in the same format

Do not fix anything yet.

---

### Phase L-3 — Cross-Reference Scan

Check that the wiki's dependency graph is accurate and complete.

For each component page in scope:
1. Read the `## Dependencies` section — specifically "Depends On" and "Used By" lists.
2. Read the corresponding source files and check actual imports, function calls, and usages.
3. Flag:
   ```
   CROSS-REF GAP — [page.md] — "Depends On" missing: [[missing-dep]]
   CROSS-REF GAP — [page.md] — "Used By" missing: [[missing-user]]
   CROSS-REF WRONG — [page.md] — lists [[wrong-dep]] but source does not import it
   ```
4. Also flag **orphan pages** — any wiki page not linked from any other wiki page (not just component pages). Run a full sweep:
   ```bash
   find [OUTPUT_PATH] -name "*.md" -not -path "*/.obsidian/*" -not -name "_mapping-template.md" | while read f; do
     name=$(basename "$f" .md)
     relpath="${f#[OUTPUT_PATH]/}"; relpath="${relpath%.md}"
     grep -rlq "\[\[$name\]\]\|\[\[$relpath\]\]" [OUTPUT_PATH] --include="*.md" 2>/dev/null \
       | grep -qv "^$f$" || echo "ORPHAN — $relpath — not linked from any other wiki page"
   done
   ```
   Record each result as: `ORPHAN — [relpath] — not linked from any other wiki page`

---

### Phase L-4 — Duplicate / Merge Candidates

Scan for pages that cover substantially overlapping ground.

Signs of duplicate/merge candidates:
- Two component pages that describe the same module under different names
- A component page and an architecture page that duplicate the same system description
- Pages that were both marked `status: stub` and never differentiated

For each candidate, record:
```
MERGE CANDIDATE — [[page-a]] and [[page-b]] — reason: [what overlaps]
```

This is a flag for the user to decide — never merge automatically.

---

### Phase L-5 — Compile Findings

Compile all findings from L-1 through L-4 into a single internal list. Do not stop to present a report or wait for confirmation. Proceed immediately to Phase L-6.

---

### Phase L-6 — Apply Fixes

Apply fixes in this order. Do not mix categories. Do not wait for confirmation between steps.

**1. Broken wikilinks (structural — fix first):**
For each broken wikilink:
- If the target page was renamed: update the link to the new name
- If the target page was deleted and has no replacement: remove the link from the source page (replace with plain text if needed)
- If the target page should exist but doesn't: add a `<!-- TODO: create [[target]] page -->` comment and leave the link intact — do not create the missing page during a lint session

**2. Cross-reference additions (links — fix second):**
For each CROSS-REF GAP:
- Add the missing `[[wikilink]]` to the appropriate section in the Dependencies page
- Only add links to pages that exist in the wiki

For each CROSS-REF WRONG:
- Remove the incorrect dependency link

For each ORPHAN:
- Find the most appropriate existing page(s) that should link to this orphan
- Add `[[orphan-name]]` to their Related Pages or Dependencies section
- Do not create new pages to link to orphans

**3. Do NOT fix stale pages during lint:**
Stale page content requires reading source files carefully and updating accurately — that is an Ingest session, not a lint fix. For each stale page, add a comment at the top:
```markdown
<!-- LINT: stale as of [DATE] — [brief description of what needs updating] -->
```
This flags it for the next Ingest session without making potentially wrong fixes.

**4. Do NOT fix merge candidates:**
Each merge candidate requires a judgment call about what to keep, what to rewrite, and which wikilinks to update. Defer all merges to a dedicated session with explicit user guidance.

**5. Frontmatter findings from Phase L-0.5:**

| Finding | How to fix |
|---------|-----------|
| `FRONTMATTER MISSING` | Add the missing field with a sane default (or `<!-- TODO -->` if it requires user input). Set status to `partial`. |
| `FRONTMATTER BAD SLUG` / `KIND-PATH MISMATCH` | Rename / move the page to align slug, kind, and path. **WARNING:** slug renames are an external API contract change — flag for user confirmation before applying. Do NOT auto-rename. |
| `FRONTMATTER DUPLICATE SLUG` | Flag for user — picking which slug wins requires judgment. |
| `FRONTMATTER BAD XREF` | Remove the dangling reference (after a heuristic check that the target genuinely doesn't exist) OR add a `<!-- TODO: create [[target]] page -->` note. |
| `BIDI MISSING` | Auto-fix: add the missing entry to the partner page's frontmatter list. |
| `ACTION ENDPOINT STALE` | Flag — only the user knows whether to update the action's endpoint or the `.endpoints.json` manifest. |
| `ACTION BAD SIDE_EFFECT` | Flag — controlled vocabulary changes require schema migration. |
| `ACTION SAFETY METADATA` | Flag — add dry-run/test-mode/live-approval frontmatter and a `## Safety gates` section before exposing the action through `app-actions-mcp`. |
| `AUDIENCE MISSING SECTION` / `AUDIENCE DRIFT` | If single-audience and drift is detected, REMOVE the foreign section. If `[all]` and section is missing, add a `<!-- TODO -->` stub for that audience. |
| `GLOSSARY ORPHAN` | Flag — leave the page in place; user decides whether to remove or wire it in. |
| `KIND-SPECIFIC FIELD MISSING` (e.g. action without `endpoint`) | Set the field with a `<!-- TODO -->` placeholder. Downgrade page status to `partial`. |

After all fixes, re-run the wikilink scan from Phase L-1 AND the frontmatter scan from Phase L-0.5 to verify no new issues were introduced.

---

### Phase L-6.5 — Manifest Regeneration (NEW in Phase III.5; T16.5)

After fixes are applied, regenerate `wiki/manifest.json` per [[manifest-schema]]:

Preferred deterministic command when the canonical kit is available:

```bash
python3 knowledgeBase-vault/codebase-map/scripts/generate-manifest.py /absolute/path/to/project --write
python3 knowledgeBase-vault/codebase-map/scripts/generate-manifest.py /absolute/path/to/project --check
```

1. Read every page in the wiki (excluding `_mapping-template.md` files and the `.obsidian/` config).
2. Extract frontmatter from each.
3. Build the manifest top-level object: `manifest_version: 1`, `generated_at` (UTC ISO8601), `project_slug` (from any page's frontmatter — they all match), `kbmap_version` (from the kit, written at bootstrap), `page_count`, `pages`.
4. For each page, build the entry per the manifest schema:
   - Universal fields: `slug`, `kind`, `audience`, `version`, `last_updated`, `mapped_date`, `status`, `path`.
   - `frontmatter_excerpt`: kind-specific subset (see [[manifest-schema]]).
   - `links_in`: every other page that wikilinks to this page (parse `[[slug]]` patterns).
   - `links_out`: every wikilink in this page's body.
5. Sort the `pages` array alphabetically by `slug`. Sort all list values within entries (`audience`, `links_in`, `links_out`, frontmatter list values) alphabetically.
6. Write the manifest atomically (write to `wiki/manifest.json.tmp`, then `mv`) so MCP consumers don't see a half-written file.
7. **Validation gate:** if any of these is true, abort the write and leave the prior manifest in place — emit `LINT: failed — manifest validation: [reason]`:
   - Any page failed Phase L-0.5 frontmatter validation.
   - Any cross-reference slug doesn't resolve (would result in dangling links_out / links_in).
   - `manifest_version` ≠ 1 (catches accidental schema regression).

8. **Determinism check:** if the lint run was triggered with no actual wiki changes since the last run, the new manifest should differ from the prior one ONLY in `generated_at`. Run `diff <(jq 'del(.generated_at)' wiki/manifest.json.prev) <(jq 'del(.generated_at)' wiki/manifest.json)` — if non-empty on an unchanged wiki, treat as a bug in this phase.

---

### Phase L-7 — Log

Append a lint session entry to `wiki/mapping-log.md`:

```markdown
## [DATE] — Lint: [full / targeted — scope description]

**Pages scanned:** [N]
**Frontmatter issues:** [N] (missing fields, bad slugs, kind-path mismatches, audience drift)
**Bidirectional link gaps:** [N] / auto-fixed: [N]
**Action endpoint stale:** [N] / flagged: [N] (user decision pending)
**Glossary orphans:** [N] / flagged: [N]
**Broken wikilinks found:** [N] / fixed: [N]
**Stale pages found:** [N] / flagged with comments: [N]
**Cross-reference gaps found:** [N] / fixed: [N]
**Orphan pages found:** [N] / wired in: [N]
**Merge candidates flagged:** [N] (not merged — user decision pending)
**Manifest regenerated:** yes / no (failed: [reason])
**Open items:** [list any issues deferred to future sessions, or "none"]
```

End the lint session with the contract line per [[wiki-prompts/lint]]:
- `LINT: done — [N] frontmatter fixes, [M] broken links fixed, [K] stale pages flagged, manifest regenerated`
- `LINT: skipped — [reason]` (e.g. wiki was clean)
- `LINT: failed — [error]` (e.g. manifest validation aborted the regen)

---

## Clarifying Questions

Ask when you encounter:
- A component page whose source location no longer exists — is the module renamed, deleted, or moved?
- Two pages that appear to cover the same thing — is one intentionally more specific?
- A dependency listed in the wiki but not found in the source — was it removed, or is it an indirect dependency?

Format:
```
**Question:** [X]
Context: [what you observed]
```

---

## Markdown Conventions

Follow all conventions in `wiki/_schema.md` for this project. Key reminders:
- Update `mapped_date` frontmatter on every page you modify
- Use `[[wikilinks]]` for internal links — only to pages that exist
- Mermaid for all diagrams
- File naming: kebab-case
