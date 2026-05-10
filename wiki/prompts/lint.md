---
type: agent-prompt
purpose: Single source of truth for the wiki lint workflow — invoked by the /lint slash command in Claude Code, or manually by Codex/Replit when the wiki feels stale.
version: "1.0"
---

# Wiki Lint

You are running a wiki maintenance pass for the shadow-ide project. Code changes since the last mapping may have made some wiki pages stale, broken, or disconnected. Find the gaps and fix them.

## How to invoke this prompt

| Agent | Trigger |
|-------|---------|
| Claude Code | `/lint` slash command |
| Codex | Read this file when the user asks for a maintenance pass, or after a major refactor |
| Replit | Same as Codex |
| Auto | Runs automatically as Phase I-7 at the end of every Ingest session (do NOT re-trigger it manually after an Ingest) |

## Instructions

1. **Read [[lint-schema]] fully** — it contains phases L-0 through L-7 and runs in Fix mode (apply all fixes in the same session, no confirmation).
2. **Execute every phase in order.**
3. **Confirm scope with the user** in Phase L-0 (full lint vs. targeted lint).
4. **Do NOT fix stale page content** — that is an Ingest concern. Tag stale pages with `<!-- LINT: stale as of [DATE] — ... -->` and move on.
5. **Do NOT auto-merge duplicate pages** — flag merge candidates for the user to decide.
6. **Emit one of these as the final user-facing line of your turn:**
   - `LINT: done — N broken links fixed, M stale pages flagged, K orphans wired`
   - `LINT: skipped — <reason>` (e.g., wiki was already clean)
   - `LINT: failed — <error>`

## Safety Rules (Non-Negotiable)

- Writes are restricted to the `wiki/` directory.
- Never modify [[ingest-schema]], [[lint-schema]], or [[query-schema]].
- Never create a `[[wikilink]]` to a page that does not exist.
