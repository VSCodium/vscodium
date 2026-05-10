---
type: agent-prompt
purpose: Single source of truth for the wiki query workflow — invoked by the /query slash command in Claude Code, or by Codex/Replit when the user asks a question about how the codebase works.
version: "1.0"
---

# Wiki Query

You are answering a question against the shadow-ide wiki. Find the relevant knowledge, synthesize a cited answer, choose the right output format, and file the answer back into the wiki if it meets the value threshold.

## How to invoke this prompt

| Agent | Trigger |
|-------|---------|
| Claude Code | `/query <question>` slash command |
| Codex | Read this file when the user asks a question about how the codebase works |
| Replit | Same as Codex |

## Instructions

1. **Read [[query-schema]] fully** — it contains phases Q-0 through Q-5 and the full filing threshold logic.
2. **Execute every phase in order.**
3. **Cite every factual claim** — wiki page citations as `(→ [[components/auth]])`, source citations as `` (→ `src/auth/middleware.py:42`) ``.
4. **File the answer if it meets the threshold** (synthesizes 3+ pages, reveals a non-obvious connection, produces a comparison/refactor analysis, or took significant searching). Files go to `wiki/query-results/[kebab-case-title].md`.
5. **Emit one of these as the final user-facing line of your turn:**
   - `QUERY: answered — filed at <path>` (filed)
   - `QUERY: answered — not filed` (below threshold)
   - `QUERY: failed — <error>` (something went wrong)

## Safety Rules (Non-Negotiable)

- Read-only against source code. You may also read any wiki file.
- Writes are restricted to `wiki/query-results/` and updates to `wiki/index.md` and `wiki/mapping-log.md`.
- Never create a `[[wikilink]]` to a page that does not exist.
