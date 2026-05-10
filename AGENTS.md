---
type: agent-instructions
project: shadow-ide
wiki_path: wiki/
mapped_date: YYYY-MM-DD
---

# shadow-ide — Agent Instructions

## MANDATORY: Read the Wiki Before Anything Else

This project is governed by a structured wiki at `wiki/`. You MUST follow these steps at the start of every session, before reading or modifying any source code:

1. Read `wiki/index.md` to orient yourself
2. Read `wiki/_schema.md` for the maintenance conventions
3. Read `wiki/work-modes.md` to identify the active work mode
4. For any code change, read the relevant page in `wiki/components/` FIRST

Do not begin work on bugs, features, or refactors until you have completed steps 1–3. The wiki is the authoritative model of this codebase. Source code is the implementation truth; the wiki is how you reason about it before and after changes.

## MANDATORY: Work Mode Routing

Before acting, classify the session into one work mode from `wiki/work-modes.md`.
This determines whether you may only investigate, may maintain the KB, or may
edit project source.

| User intent | Active mode | Agent behavior |
|---|---|---|
| Ask how something works, investigate a bug, produce QA guidance | `qa-readonly` | Read KB/source evidence only. Do not edit files. |
| Human engineer is using the KB while doing implementation | `human-dev-readwrite` | Support implementation; source changes require ingest afterward. |
| AI agent is asked to fix, debug, build, add a feature, or edit files | `agent-dev-readwrite` | Read KB first, edit within scope, verify, then ingest KB updates. |
| Update docs/wiki, ingest a diff, repair stale pages | `kb-maintainer` | Update wiki only. Do not edit source. |
| Plan architecture, ADRs, cross-project strategy, issue cards | `architect` | Produce plans/decisions; switch modes before implementation edits. |
| CI or scheduled job | `ci-automation` | Run only the configured deterministic task. |

If the user asks an AI coding agent to debug, fix, implement, build, or add a
feature, assume `agent-dev-readwrite` unless they explicitly say no edits. In
that mode you may modify project source, but you must preserve unrelated user
changes, avoid destructive actions without approval, run focused verification,
and complete ingest before the final response.

If intent is ambiguous and choosing incorrectly could cause writes, ask one
clarifying question before editing.

## MANDATORY: Operation Routing

Three operations govern ongoing wiki maintenance. Route to the correct one automatically based on session context — do not wait to be told:

| Session involves | Operation | Read first | Slash command |
|---|---|---|---|
| A question about how the codebase works | **Query** | `wiki/query-schema.md` then `wiki/prompts/query.md` | `/query <question>` |
| Any source file is created, modified, or deleted | **Ingest** | `wiki/ingest-schema.md` then `wiki/prompts/ingest.md` | `/ingest` |
| Periodic maintenance, broken links, staleness | **Lint** | `wiki/lint-schema.md` then `wiki/prompts/lint.md` | `/lint` |

The schema files contain the **phased workflow** (read once per project). The prompt files in `wiki/prompts/` are the **invocation contracts** — the single source of truth for each operation. Slash commands are convenience wrappers around the prompt files.

**Ingest also runs Lint automatically** at Phase I-7. Do not run a separate `/lint` after `/ingest`.

A code change without a completed Ingest (Phase I-6 verification passed, `.claude/pending-ingest.txt` cleared) is an incomplete session.

## MANDATORY: End-of-Session Contract

**Every session must emit one of these as its final user-facing line** so failure modes are visible:

| Operation | Final-line format |
|---|---|
| Ingest | `INGEST: done — N files` / `INGEST: skipped — <reason>` / `INGEST: failed — <error>` |
| Query | `QUERY: answered — filed at <path>` / `QUERY: answered — not filed` / `QUERY: failed — <error>` |
| Lint | `LINT: done — N broken links fixed, M stale pages flagged, K orphans wired` / `LINT: skipped — <reason>` / `LINT: failed — <error>` |

If a session involves no code changes and no question, no contract line is required.

## MANDATORY: Automatic Wiki Ingest at Session End

**This applies to all agents (Claude Code, Codex, Replit, etc.) equally — only the trigger differs.**

When source files are modified during a session, the wiki ingest workflow MUST run before the session ends. This is non-negotiable. The list of modified files lives at `.claude/pending-ingest.txt`.

### How it triggers per agent

**Claude Code** (recommended setup — automatic, no manual action needed):

- `PostToolUse` hooks (`wiki/scripts/track-change.sh` for Edit/Write/MultiEdit, `wiki/scripts/bash-mutation-watch.sh` for Bash) append modified file paths to `.claude/pending-ingest.txt`.
- `SessionStart` and `UserPromptSubmit` hooks (`wiki/scripts/session-start.sh`, `wiki/scripts/prompt-banner.sh`) inject a "wiki ingest pending for N files" reminder via `additionalContext` until the pending list is cleared.
- When you see the reminder, run `/ingest`. The slash command reads `wiki/prompts/ingest.md` which executes the full I-0 → I-7 workflow in the parent session.
- **No Stop hook spawns a child agent.** The previous Stop-hook-spawns-subagent design was removed (broken `--cwd` flag, recursion risk, blocked exit, API-key dependency).

**Codex** (no hook support — manual is mandatory):

- As the FINAL step of every session that modified source files, you MUST read `wiki/prompts/ingest.md` and execute the workflow it describes (phases I-0 through I-7).
- Do not return a final response to the user until ingest is complete and you have emitted one of the `INGEST: ...` contract lines.
- The list of changed files is at `.claude/pending-ingest.txt`. If that file is missing or empty, you have no work to do; emit `INGEST: skipped — no pending files` and stop.

**Replit** (same as Codex — no hook support):

- See `replit.md` at the project root for Replit-specific notes (it imports the same workflow).
- The contract is identical: read `wiki/prompts/ingest.md` and execute as your final session step.

**Gemini CLI / Cursor** (automatic hooks supported):

- **Gemini CLI:** Configured via `.gemini/settings.json` to load `AGENTS.md` and run background hooks.
- **Cursor:** Configured via `.cursor/hooks.json` to run background hooks (`postToolUse`, `stop`).
- `AfterTool` / `postToolUse` hooks track changes; `SessionEnd` / `stop` hooks run `run-ingest.sh` automatically.
- If hooks are disabled, read `wiki/prompts/ingest.md` and execute as your final session step.
- Use `/memory show` (Gemini CLI) to verify the hierarchical context is loaded.

### Manual fallback (any agent)

`wiki/scripts/run-ingest.sh` is installed but NOT wired into any hook by default. It spawns a sub-agent (`claude --print` or `codex -q`) to run the ingest workflow against `.claude/pending-ingest.txt`. Use it from a CI runner or when you want a separate process to do the work. Requires `ANTHROPIC_API_KEY` in the environment when using `claude`.

<!-- LLM: Do NOT edit the four MANDATORY sections above. They are project-agnostic
     and must be copied verbatim into every project. You fill in ONLY the three
     sections below (Project Summary, Key Entry Points, Architecture at a Glance). -->

## Project Summary

<!-- LLM: Write 3–5 sentences. What does this project do? Who uses it? What is the core tech stack?
     Be specific — this is the first thing any agent reads when opening this project. -->

## Key Entry Points

<!-- LLM: List 3–5 files an agent must know about to work on this project.
     Format: `path/to/file.ext` — one-line description of what it does. -->

## Architecture at a Glance

<!-- LLM: 2–4 bullet points summarizing the top-level architecture.
     Example:
     - FastAPI backend (`backend/`) with PostgreSQL via SQLAlchemy
     - Next.js 14 frontend (`web/src/`)
     - Celery workers for async scraping and notifications
     - Docker Compose for local dev, AWS EC2 for production
-->
