---
description: One-screen wiki health report — ingest freshness, stale pages, broken links, audience drift, schema drift, action endpoint staleness.
---

You are running `/mapstatus`. Produce a concise single-screen health snapshot of this project's wiki and any drift from the canonical kbmap kit. Report-only — do NOT modify any files.

If the canonical kbmap kit is available locally, prefer running the deterministic
read-only checker first and summarize its output:

```bash
python3 knowledgeBase-vault/codebase-map/scripts/mapstatus.py /absolute/path/to/project
```

Use the manual checks below for categories the script does not cover yet or when
the script is unavailable.

## What to inspect

1. **Pending ingest queue** (`.claude/pending-ingest.txt`)
   - File missing or empty → "✓ no pending changes"
   - Non-empty → count lines, list first 5 paths, total count

2. **Last ingest / lint** (`wiki/mapping-log.md`)
   - Find the most recent `Ingest:` entry — report its date and `INGEST: ...` contract line summary if present
   - Find the most recent `Lint:` entry — report its date and findings counts

3. **Stale component pages** (component-level)
   - For every `kind: component | feature | workflow | integration | action | decision` page, check `last_updated` frontmatter
   - Pages with `last_updated > 30 days ago` → list as stale candidates (max 10 listed; show total count)
   - Pages with `status: stub` for > 14 days → list as long-pending stubs (separate count)
   - Pages with `status: partial` (any age) → list as still-incomplete (separate count)

4. **Broken wikilinks**
   - Run: `grep -rho '\[\[[^]]*\]\]' wiki/ --include="*.md" | sort | uniq`
   - For each `[[target]]`, check whether `wiki/<target>.md` or `wiki/<target>/index.md` exists
   - Count broken links; list first 5

5. **Audience drift** (per `lint-schema.md` Phase L-0.5)
   - Pages with `audience: [all]` missing one of the three required section headers (`## For developers`, `## For users`, `## For agents`)
   - Pages with single-audience tagging (e.g. `audience: [dev, agent]`) that contain a foreign section header (e.g. `## For users`)
   - Count and list first 5 of each

6. **Action endpoint staleness** (per `lint-schema.md` rule 9)
   - For every `kind: action` page, read its `endpoint:` frontmatter
   - Read `wiki/.endpoints.json` — if it has a non-empty `endpoints:` list, check that every action's endpoint appears
   - Actions referencing endpoints not in `.endpoints.json` → list as stale (max 5)

7. **Schema drift** (per T14 and `wiki/.kbmap-versions.json`)
   - For every tracked schema file, recompute its current SHA256 and compare to `wiki/.kbmap-versions.json`
   - Drifted files (project-modified): count and list
   - Note: this only checks PROJECT-side drift here. To also check whether the canonical kit is ahead, the user must run `/kbmap-upgrade`.

8. **Manifest freshness** (per T16.5 / `wiki/manifest.json`)
   - Read `manifest.json` `generated_at` field
   - If older than the most recent `last_updated` of any wiki page → manifest is stale; recommend running `/lint`

9. **Bidirectional link integrity** (sample)
   - Pick 3 random `kind: action` pages
   - For each, check that `feature:` resolves AND that the linked feature page's `actions:` includes this action's slug
   - Report any asymmetric pairs found in this sample

## Output format

Single screen, ≤ 30 lines. Use this structure:

```
🗺️  kbmap status — <project_slug> (kbmap_version <version>)

⏱  Pending ingest:        <N files | clean>
📅  Last ingest:           <date> (INGEST: <contract line>)
📅  Last lint:             <date>

📄  Pages by status:       <stub: N> / <partial: M> / <complete: K> / total <T>
⏰  Stale (> 30d):         <N>  e.g. components/foo, features/bar, ...
📋  Long-pending stubs:    <N>
🔗  Broken wikilinks:      <N>  e.g. [[ghost-page]] in components/foo, ...
🎭  Audience drift:        <N>  (page X tagged [dev,agent] but has "## For users")
🎯  Action endpoint stale: <N>  (action X references endpoint Y not in .endpoints.json)
📦  Schema drift:          <N>  (run /kbmap-upgrade to inspect)
📊  Manifest:              <fresh | stale by Nh — run /lint to refresh>
🔁  Bidi link sample:      <N/N OK | M asymmetric>

💡 Recommendations:
   - Run /ingest if pending count > 0
   - Run /lint if any of: broken links / audience drift / endpoint stale / manifest stale
   - Run /kbmap-upgrade if schema drift > 0
```

Adjust emoji-free output if running in a non-emoji-friendly environment.

## Final contract line

Emit one of these as your final user-facing line:

- `MAPSTATUS: clean` — every check came back green.
- `MAPSTATUS: needs-attention — N issues across [list of categories]` — drift detected; the recommendations section pointed at fixes.
- `MAPSTATUS: failed — <reason>` — couldn't run checks (e.g., wiki/ missing, .kbmap-versions.json missing).

## Safety

- Read-only. Never write or modify any file.
- If any check requires a file that doesn't exist, report it as `not yet bootstrapped` and continue with the other checks rather than erroring out.
