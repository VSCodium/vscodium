---
type: schema
purpose: LLM instructions for ingesting code changes into the wiki
version: "1.0"
---

# Ingest Schema — Wiki Update on Code Change

You are a wiki maintainer. A code change has occurred in this project. Your job is to integrate it into the wiki accurately, cross-reference it, and leave the wiki more complete than you found it.

You are NOT doing a full re-map. You are making surgical, targeted updates based on what actually changed. Read carefully. Write only what needs to change.

Ingest is required after source changes made under `human-dev-readwrite` or
`agent-dev-readwrite`. Ingest itself is a KB-maintenance workflow: it may update
wiki pages, index pages, manifests, and mapping logs, but it must never edit
project source code.

---

## Safety Rules (Non-Negotiable)

1. **NEVER** modify, delete, or rename any source code file in the project.
2. **NEVER** modify any file inside `codebase-map/` — it is the template kit.
3. **NEVER** modify this schema file itself. It is a read-only instruction document copied from the template kit. If you accidentally edit it, restore it from the template kit's `ingest-schema.md`.
4. **NEVER** execute code from the project (no `npm start`, no `python main.py`, etc.) unless the user explicitly asks.
5. **NEVER** install dependencies or run build commands.
6. **NEVER** create a `[[wikilink]]` to a page that does not exist. Only link to pages that are already in the wiki or that you are creating in this session.
7. You may **read** any file in the project. You may run read-only shell commands (`find`, `grep`, `wc`) to verify counts or locate files.
8. All wiki output goes to `OUTPUT_PATH` (the wiki directory). Check `wiki/index.md` or the mapping-log if you need to confirm the exact path.
9. If the source change was made by an AI coding agent in `agent-dev-readwrite`, verify the wiki updates cover every behavior the agent changed before declaring ingest complete.

---

## Execution Discipline (Required)

These rules prevent structural drift. Follow them exactly.

### Read before writing

For any component page you are about to update, **read the current wiki page first** before reading the changed source files. This gives you a baseline — you can see what the wiki already claims, and then check whether the source still supports those claims. Do not write based on source alone.

### Update surgically

Only change sections that are genuinely affected by the code change. Do not rewrite pages from scratch unless the component was fundamentally redesigned. A function signature change is not a reason to rewrite the entire "How It Works" section.

### Templates are structural contracts

The `components/_mapping-template.md` defines the required section order for component pages. When creating a new component page:
1. Read `wiki/components/_mapping-template.md`
2. Copy its full content to the new page path
3. Fill in each section in order
4. Never remove a `##` section, reorder sections, or add new `##` headings
5. Component-specific detail goes as `###` sub-sections under `## How It Works`

### Wikilinks must resolve

Every `[[wikilink]]` you write must point to a page that already exists or that you are creating in this session. If you are unsure whether a page exists, check the file system before linking.

### Status must be honest

- `stub` — Minimal or no real content, placeholder comments present
- `partial` — Some sections filled in, but `<!-- TODO -->` comments or empty tables remain
- `complete` — Every section has real content. No TODOs, no empty tables, no placeholder comments.

If you touch a section in a `complete` page and leave any TODO behind, you must downgrade its status to `partial`. If you filled a TODO that was previously blocking completion, you may promote the status — but verify every section first.

---

## Resuming an Interrupted Ingest Session

If starting a new session on an in-progress Ingest:
1. Read `wiki/mapping-log.md` — find the last Ingest entry and which phase it completed
2. Read `wiki/index.md` to orient yourself
3. Resume from the earliest incomplete phase. Do not redo completed work.

---

## Ingest Workflow

Follow these phases in order. **Do not skip phases.**

---

### Phase I-0 — Orient

1. Read `wiki/index.md` to orient yourself in the wiki structure.
2. Read `wiki/_schema.md` for this project's wiki conventions.
3. Read `wiki/mapping-log.md` to see the current state of the wiki and when it was last updated.
4. Ask the user (if not already provided): **What changed?** You need to know:
   - What is the change type?
     - **New module** — a new file, directory, or logical component was added
     - **Modified module** — an existing component was changed (refactor, new feature, bug fix, API change)
     - **Deleted module** — a component was removed or merged into another
     - **Architectural change** — the overall system structure, data flow, or tech stack changed
     - **Dependency change** — a dependency was added, removed, or upgraded
   - What files or directories are involved?
   - Is there a diff, commit message, or PR description available?
5. Confirm your understanding of the change with the user before proceeding to triage.

---

### Phase I-1 — Triage

Based on what the user described, identify every wiki page that needs to change. Read [[frontmatter-schema]] for the full set of page kinds and how they cross-reference each other.

**Critical multi-audience rule:** when source code changes affect user-visible behavior — a UI change, a new endpoint, a workflow alteration — you MUST update the corresponding `features/`, `workflows/`, and `actions/` pages in addition to the technical `components/` page. The wiki serves three audiences (developer, end user via in-app assistant, AI agents via MCP) and a code change with only a component-page update silently breaks the user-facing layer.

**Agent read/write rule:** when an AI agent edited source under
`agent-dev-readwrite`, treat the agent's changed-file list as the minimum scope,
not the full truth. Re-read linked feature, workflow, action, integration, and
architecture pages to catch behavior changes that span beyond the edited files.

For each change type:

**New module / new code:**
- New component page: `wiki/components/[name].md`
- Existing component pages that should link to the new one (depends-on / depended-upon)
- **If the new code is user-visible:** new feature page at `wiki/features/[name].md` AND any new actions exposed at `wiki/actions/[name].md`. Set bidirectional links: feature's `actions:` ↔ action's `feature:`.
- **If a new external dependency is introduced:** new integration page at `wiki/integrations/[name].md`.
- **If the change implies a multi-step user journey:** new or updated workflow page at `wiki/workflows/[name].md`.
- `wiki/index.md` — add new pages to the appropriate section
- `wiki/mapping-log.md` — append entry
- Architecture pages if the new module changes the system structure

**Modified module:**
- Read the existing component page for the changed module
- List every section that the change may affect: Purpose / Source Location / Key Files / How It Works / Error Handling / Dependencies / Data Flow / API-Interface / Open Questions
- **Re-check feature/workflow/action pages that link to this component** (search `wiki/features/`, `wiki/workflows/`, `wiki/actions/` for the component slug). Update any whose user-visible behavior, steps, or action contracts have changed.
- **For action pages:** if the action's `endpoint`, `auth_required`, `confirmation_required`, `idempotent`, or `side_effects` changed, those frontmatter fields MUST be updated; bump the page `version`. The `wiki-mcp` consumers depend on these fields being accurate.
- Architecture pages if the change affects system-level behavior

**Deleted module:**
- Remove the component page: `wiki/components/[name].md`
- Every page that contains `[[name]]` — all wikilinks to the deleted page must be removed or redirected
- **If a feature/action/integration was also removed:** delete those pages too, AND remove their slugs from any `actions:`, `features:`, `components:`, `workflows:` frontmatter on linked pages
- `wiki/index.md` — remove all deleted entries
- Architecture pages if the deletion changes the system structure

**Architectural change:**
- `wiki/architecture/overview.md` — Mermaid diagram and layer descriptions
- `wiki/architecture/tech-stack.md` — if tech changed
- `wiki/project-discovery.md` — if the high-level summary changed
- Any component pages whose data flow or dependencies changed
- **Consider creating a `wiki/decisions/[name].md` ADR** — significant architectural changes warrant an explicit decision record. Set `decision_status: accepted` and link from any superseded decision via `superseded_by`.

**Dependency change:**
- `wiki/architecture/tech-stack.md` — update the relevant row
- Component pages that use the dependency — update Dependencies sections
- **If the change involves a third-party service:** update the corresponding `wiki/integrations/[name].md` page. Bump version. Update `vendor`, `protocol`, `auth_via` frontmatter as needed.

**User-visible behavior change (no source-code module added):**
This category is new in Phase III.5. A copy-edit, a UX flow alteration, or a configuration change can affect user-facing pages without touching code structure. Update:
- `wiki/features/[name].md` — refresh User-visible behavior, Notes for the assistant
- `wiki/workflows/[name].md` — update Steps, Decision points, Failure modes if relevant
- Bump the page `version`.

### Source-document conventions

Some source files map naturally to wiki pages:

| Source pattern | Wiki destination | Notes |
|----------------|------------------|-------|
| `*-api.md` at project root | `wiki/actions/[name].md` (strip `-api` from slug) | One file per endpoint |
| `*-Integration.md`, `*-integration.md` | `wiki/integrations/[name].md` (strip suffix) | One per third-party |
| `*-Workflow.md`, `*_WORKFLOW.md` (user-flow sense) | `wiki/workflows/[name].md` | Distinguish from process docs |
| `ADR-*.md`, `decisions/*.md` in source | `wiki/decisions/[name].md` | Preserve `decision_status` |

**Do NOT ingest:**
- Process / methodology docs at the project root (e.g. `Claude-Codex-Workflow.md`, `CONTRIBUTING.md`, `*-handoff.md`). These are dev-ops artifacts, not project knowledge. Skip them.
- Generated files (build outputs, lock files, etc.).
- Files under `node_modules/`, `.git/`, `venv/`, `dist/`, `build/`, `wiki/`, `codebase-map/`.

Compile the full triage list internally:

```
Pages to create: [list]
Pages to update: [list] — [specific sections affected for each]
Pages to remove: [list]
Wikilinks to repair: [list]
```

Proceed directly to Phase I-2.

---

### Phase I-2 — Read Source

Read the actual changed files. If a diff was provided, read it fully — do not skim the context lines. If specific files were named, read them completely.

For files over 500 lines: read the full file. Do not truncate.

Ask clarifying questions for anything ambiguous before writing. Mark uncertain areas with `<!-- TODO: clarify -->` rather than guessing.

---

### Phase I-3 — Update Component Pages

Execute the triage list. Work through pages in this order: new pages first, then updates, then deletions.

**New component page:**
1. Read `wiki/components/_mapping-template.md`
2. Copy its full content to `wiki/components/[name].md`
3. Fill in each section in order using the source files you read in Phase I-2
4. Set `status` honestly: `partial` if any section is incomplete, `complete` only if every section has real content

**Modified component page:**
1. Re-read the current page
2. Re-read the changed source files
3. Update only the sections identified in triage — do not touch sections unaffected by this change
4. If you fill in a previously empty section or clear a TODO, note this in the mapping-log entry
5. Update `mapped_date` in the frontmatter to today's date

**Deleted component page:**
1. Before deleting, scan all wiki pages for `[[component-name]]` wikilinks: `grep -r "\[\[component-name\]\]" [OUTPUT_PATH] --include="*.md"`
2. For each page with a link to the deleted component: remove the wikilink or update it to point to the replacement (if merged into another component)
3. Delete the component page file
4. Note: do not delete the `components/_mapping-template.md` stub — that is a permanent template

---

### Phase I-4 — Update Architecture Pages (if triggered in triage)

If the triage identified architecture pages as affected:

**`wiki/architecture/overview.md`:**
- Update the Mermaid system diagram if the component structure changed
- Update layer descriptions if the layers themselves changed
- Do not rewrite sections unaffected by this change

**`wiki/architecture/tech-stack.md`:**
- Update the relevant row(s) in the tech table
- For dependency changes: update version, add/remove rows as appropriate

**`wiki/project-discovery.md`:**
- Update only if the high-level project summary or entry points changed
- Preserve all other sections

---

### Phase I-5 — Update Index and Log

**`wiki/index.md`:**
- Add **every new page** created in this session to the appropriate section — not just component pages. Non-component pages (operation prompts, query results, architecture pages, etc.) belong in their respective sections (Operations, Architecture, etc.). No page may be left out of index.md.
- Remove deleted pages from their sections
- Update the Mapping Status table if overall completeness changed

**`wiki/mapping-log.md`:**
Append one entry in the standard log format:

```markdown
## [DATE] — Ingest: [brief description of change]

**Change type:** [new module / modified module / deleted module / architectural change / dependency change]
**Files changed in source:** [list]
**Wiki pages created:** [list, or "none"]
**Wiki pages updated:** [list with sections changed for each]
**Wiki pages removed:** [list, or "none"]
**Wikilinks repaired:** [list, or "none"]
**Open questions:** [list any TODOs added, or "none"]
```

---

### Phase I-6 — Verification

Before declaring the Ingest session complete, run through this checklist. Do not skip it.

**Wikilinks:**
- [ ] For every page you touched, grep for all `[[` links: `grep -r "\[\[" [OUTPUT_PATH] --include="*.md" -h | sort | uniq`
- [ ] Verify every `[[target]]` corresponds to an actual file at `OUTPUT_PATH/target.md`
- [ ] Fix any broken wikilinks before declaring complete

**Status honesty:**
- [ ] No `status: complete` page you touched contains any `<!-- TODO -->` or `<!-- LLM:` placeholder comments
- [ ] Run: `grep -r "TODO\|LLM:" [OUTPUT_PATH] --include="*.md"` — note any hits; do not set pages to `complete` if hits remain

**Index and orphan check:**
- [ ] Every page you created is listed in `wiki/index.md`
- [ ] Every page you deleted has been removed from `wiki/index.md`
- [ ] No new orphans introduced — run: `find [OUTPUT_PATH] -name "*.md" -not -path "*/.obsidian/*" -not -name "_mapping-template.md" | while read f; do name=$(basename "$f" .md); relpath="${f#[OUTPUT_PATH]/}"; relpath="${relpath%.md}"; grep -rlq "\[\[$name\]\]\|\[\[$relpath\]\]" [OUTPUT_PATH] --include="*.md" 2>/dev/null | grep -qv "^$f$" || echo "ORPHAN: $relpath"; done`
  Fix any reported orphans before declaring complete.

**Log:**
- [ ] `wiki/mapping-log.md` has a new Ingest entry for this session

**Summary to user:**
Present a concise end-of-session summary:
```
Ingest complete.
Created: [N pages]
Updated: [N pages — list]
Removed: [N pages]
Open questions added: [N — list]
Mode: [human-dev-readwrite / agent-dev-readwrite / kb-maintainer]
```

---

### Phase I-7 — Run Lint (ALWAYS LAST)

After verification passes, run a full Lint session immediately in the same session:

1. Read `wiki/lint-schema.md` fully.
2. Run phases L-0 through L-7 in order.
3. The L-7 log entry is appended to `wiki/mapping-log.md` as its own entry.

Do not skip this phase. Every Ingest session ends with a Lint pass to keep the wiki consistent.

---

## Clarifying Questions

Ask when you encounter:
- A file whose purpose isn't clear from its name or the diff context
- A change that could affect multiple components in ambiguous ways
- Anything that would significantly change the architecture diagram

Format:
```
**Question:** What is [X]?
Context: [what you observed that raised the question]
```

Do not guess. But do proceed with the rest of the Ingest session while waiting for answers — mark ambiguous areas with `<!-- TODO: clarify -->`.

---

## Markdown Conventions

Follow all conventions in `wiki/_schema.md` for this project. Key reminders:

- Frontmatter on every page: `type`, `mapped_date` (today's date), `status`, `tags`
- Use `[[wikilinks]]` for internal links — only to pages that exist
- Use relative source paths for code references: `` `src/components/Button.tsx` ``
- Mermaid for all diagrams
- File naming: kebab-case, no spaces
