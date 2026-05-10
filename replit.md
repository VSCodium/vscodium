---
type: agent-instructions
project: shadow-ide
agent: replit
wiki_path: wiki/
mapped_date: YYYY-MM-DD
---

# shadow-ide — Replit Agent Instructions

> **This file is the entry point for the Replit AI agent.** It mirrors `AGENTS.md` (which Codex and other AGENTS-aware tools read) but with Replit-specific notes about hook unavailability and how to keep the wiki in sync.
>
> The full contract is identical across all three agents (Claude Code, Codex, Replit). Read `AGENTS.md` if you want the canonical version — this file just adds Replit-specific guidance on top.

---

## MANDATORY: Read the Wiki Before Anything Else

This project is governed by a structured wiki at `wiki/`. Before reading or modifying any source code:

1. Read `wiki/index.md` to orient yourself
2. Read `wiki/_schema.md` for the maintenance conventions
3. Read `wiki/work-modes.md` to identify the active work mode
4. For any code change, read the relevant page in `wiki/components/` FIRST

The wiki is the authoritative model of this codebase. Source code is the implementation truth; the wiki is how you reason about it before and after changes.

## MANDATORY: Work Mode Routing

Classify every session using `wiki/work-modes.md` before editing:

| User intent | Active mode |
|---|---|
| Investigate or answer without edits | `qa-readonly` |
| AI agent directly fixes, debugs, builds, or adds a feature | `agent-dev-readwrite` |
| Wiki-only updates | `kb-maintainer` |
| Planning or issue breakdown | `architect` |

In `agent-dev-readwrite`, you may edit project source within the requested
scope, but you must preserve unrelated user changes, verify the result, and run
ingest before your final response.

## MANDATORY: Operation Routing

| Session involves | Operation | Read first |
|---|---|---|
| A question about how the codebase works | **Query** | `wiki/query-schema.md` then `wiki/prompts/query.md` |
| Any source file is created, modified, or deleted | **Ingest** | `wiki/ingest-schema.md` then `wiki/prompts/ingest.md` |
| Periodic maintenance, broken links, staleness | **Lint** | `wiki/lint-schema.md` then `wiki/prompts/lint.md` |

**Ingest runs Lint automatically** at Phase I-7. Do not run a separate Lint after Ingest.

## MANDATORY: End-of-Session Contract

**Every session must emit one of these as its final user-facing line:**

- `INGEST: done — N files` / `INGEST: skipped — <reason>` / `INGEST: failed — <error>`
- `QUERY: answered — filed at <path>` / `QUERY: answered — not filed` / `QUERY: failed — <error>`
- `LINT: done — N broken links fixed, ...` / `LINT: skipped — ...` / `LINT: failed — ...`

If the session involves no code changes and no question, no contract line is required.

## MANDATORY: Automatic Wiki Ingest at Session End — Replit Specifics

**Replit has no equivalent of Claude Code's hooks.** That means the ingest trigger is fully manual and falls on you (the agent) to execute reliably. There is no PostToolUse hook recording your file changes; there is no SessionStart banner reminding you to ingest.

### Your obligation as the Replit agent

When a session involves any source file modification, you MUST:

1. **Track changes yourself.** As you Edit/Write/run shell commands that mutate files, mentally maintain (or scratch-write to a temp note) the list of files you have changed. This list IS your `pending-ingest.txt` for this session.
2. **As the FINAL step of the session**, before returning your last response to the user:
   - Read `wiki/prompts/ingest.md` in full.
   - Execute the workflow it describes — phases I-0 through I-7.
   - Where the workflow says "read `.claude/pending-ingest.txt`," substitute the in-session change list you tracked in step 1 (Replit doesn't write to `.claude/` from hooks, so the file may be missing or stale).
3. **Emit the `INGEST: ...` contract line** as the final line of your response.

### Why this matters

Without hooks, "the agent will do it" is the only enforcement. Every skip leaves the wiki silently out of sync with the code. Treat ingest as a hard step, not an optional polish — the same way you'd treat tests passing before merging a PR.

### When in doubt — invoke the manual fallback

`wiki/scripts/run-ingest.sh` is a shell script that spawns a fresh sub-agent to run the ingest workflow. If you have shell access in the Replit environment and an `ANTHROPIC_API_KEY` is configured, you can run it as the final session step:

```bash
bash wiki/scripts/run-ingest.sh
```

It will read `.claude/pending-ingest.txt` (if present) and run a sub-agent against the unified ingest prompt. If `.claude/pending-ingest.txt` doesn't exist (because no PostToolUse hook ran), create it first by listing the files you modified, one per line.

<!-- AGENT: Do NOT edit the four MANDATORY sections above. They are project-agnostic
     and must stay verbatim. You fill in ONLY the three sections below
     (Project Summary, Key Entry Points, Architecture at a Glance). -->

## Project Summary

<!-- AGENT: Write 3–5 sentences. What does this project do? Who uses it? What is the core tech stack? -->

## Key Entry Points

<!-- AGENT: List 3–5 files an agent must know about to work on this project. -->

## Architecture at a Glance

<!-- AGENT: 2–4 bullet points summarizing the top-level architecture. -->
