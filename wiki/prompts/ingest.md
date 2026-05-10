---
type: agent-prompt
purpose: Single source of truth for the wiki ingest workflow — invoked by the /ingest slash command in Claude Code, by Codex/Replit as the final step of any session that modified source files, and (legacy) by run-ingest.sh.
version: "2.0"
---

# Wiki Ingest

You are running the wiki ingest workflow for the shadow-ide project. Source files have been modified in this session — your job is to integrate those changes into the wiki accurately.

## How to invoke this prompt

| Agent | Trigger |
|-------|---------|
| Claude Code | `/ingest` slash command, or auto-prompted by SessionStart/UserPromptSubmit hook banner |
| Codex | Read this file as the FINAL step of every session that modified source files |
| Replit | Same as Codex — read this file as the FINAL step before returning to the user |
| `run-ingest.sh` (manual) | Reads this file via `wiki/prompts/ingest.md` and feeds it to a sub-agent |

## Instructions

1. **Read [[ingest-schema]] fully** before doing anything else. It contains the complete phased workflow.
2. **Read `.claude/pending-ingest.txt`** — that is your authoritative list of files modified since the last ingest. If the file is missing or empty, you have no work to do; emit `INGEST: skipped — no pending files` and exit.
3. **Execute every phase in order: I-0 through I-7.** Phase I-7 runs Lint automatically (read [[lint-schema]] and execute L-0 through L-7).
4. **Work from the project root** — paths in the schemas are relative to `[PROJECT_ROOT]`.
5. **On success, clear the pending list:** `> .claude/pending-ingest.txt` (truncate, do not delete the file). On failure, leave it intact so the next session retries.
6. **Emit one of these as the final user-facing line of your turn:**
   - `INGEST: done — N files` (success — replaces the pending list)
   - `INGEST: skipped — <reason>` (no work needed — empty pending list, query-only session, etc.)
   - `INGEST: failed — <error>` (something went wrong — pending list preserved for retry)

## Safety Rules (Non-Negotiable)

- You may ONLY write to the `wiki/` directory and `.claude/pending-ingest.txt`. Never modify source code files.
- Never modify [[ingest-schema]], [[lint-schema]], or [[query-schema]] — they are read-only instruction documents.
- Never create a `[[wikilink]]` to a page that does not exist.
- Never spawn a child Claude session from inside this workflow — the workflow runs in the parent session.

## Context: Changed Files

The list of source files to ingest lives at `.claude/pending-ingest.txt` — read it directly. Each line is one absolute path. Special sentinel paths that may appear (from `bash-mutation-watch.sh`):

- `<git-apply>` / `<git-am>` — a git patch was applied; reconcile by running `git diff` against the previous wiki ingest's commit (find it in `mapping-log.md`).
