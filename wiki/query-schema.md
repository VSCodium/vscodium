---
type: schema
purpose: LLM instructions for answering questions against the wiki and filing valuable answers back as wiki pages
version: "1.0"
---

# Query Schema — Ask the Wiki

You are answering a question against this project's wiki. Your job is to find the relevant knowledge, synthesize an accurate answer with citations, choose the right output format for the question, and automatically file the answer back into the wiki if it meets the value threshold.

You are NOT ingesting new code and NOT running a maintenance pass. You are reading the wiki and producing a structured answer.

If the active work mode is `qa-readonly`, this workflow is strictly read-only:
you may inspect wiki and source evidence, but you must not write query-result
pages, edit source, edit wiki files, install dependencies, or run builds. Return
the answer directly with citations and test guidance when useful.

---

## Safety Rules (Non-Negotiable)

1. **NEVER** modify, delete, or rename any source code file in the project.
2. **NEVER** modify any file inside `codebase-map/` — it is the template kit.
3. **NEVER** modify this schema file itself. It is a read-only instruction document copied from the template kit. If you accidentally edit it, restore it from the template kit's `query-schema.md`.
4. **NEVER** execute code from the project (no `npm start`, no `python main.py`, etc.) unless the user explicitly asks.
5. **NEVER** install dependencies or run build commands.
6. **NEVER** create a `[[wikilink]]` to a page that does not exist.
7. You may **read** any file in the project or wiki. You may run read-only shell commands (`find`, `grep`, `wc`) to locate content.
8. All wiki output (filed query-result pages) goes to `OUTPUT_PATH`. Check `wiki/index.md` or the mapping-log if you need to confirm the exact path.
9. If `wiki/work-modes.md` says the active mode is `qa-readonly`, skip Phase Q-4/Q-5 filing even when the answer would otherwise meet the filing threshold.

---

## Output Format Selection

Choose the format that best fits the question. Do not default to a plain answer when a structured format serves the question better.

| Question type | Best format |
|---|---|
| Explain how X works, what X does, why X exists | Markdown summary page |
| Compare X and Y (two modules, approaches, versions) | Comparison table |
| How does data flow from A to B? What calls what? | Mermaid sequence or graph diagram |
| What is the architecture of X? How do these parts connect? | Mermaid architecture diagram |
| How do I implement X? Show me an example | Inline code example with explanation |
| Give me a presentation / overview I can share | Marp slide deck |
| What are all the Xs in this codebase? (inventory) | Markdown table |
| End-user "how do I X?" question | Step-by-step guide drawn from `workflows/` + `features/` pages |
| Agent "what can be dispatched?" question | Structured table of actions with their endpoints, auth, side effects |
| QA bug investigation | Expected behavior, likely failure areas, reproduction steps, and test checklist |

For complex questions, combine formats: a Mermaid diagram plus a prose explanation is often the right answer for architecture questions.

---

## Filing Threshold

A query answer is automatically filed as a wiki page if **any one** of the following is true:

- It synthesizes content from **3 or more** wiki pages into a single coherent answer
- It reveals a **non-obvious connection or pattern** not stated anywhere in the existing wiki
- It produces a **comparison, analysis, or refactor plan** that would shape future design decisions
- It took **significant searching across the wiki** to construct and would be costly to recreate from scratch

Do **not** file:
- Simple factual lookups answered by a single wiki page
- One-sentence answers
- Questions whose answer is already a direct quote from an existing page

When in doubt: file it. A query-result page costs little and compounds the wiki's value. An answer that disappears into chat history costs a future session its time to reconstruct.

---

## Query Workflow

Follow these phases in order. **Do not skip phases.**

---

### Phase Q-0 — Orient

1. Read `wiki/index.md` to understand the scope of the wiki — what pages exist, what components are mapped.
2. Read `wiki/_schema.md` for this project's wiki conventions.
3. Read the question carefully. Identify:
   - What is actually being asked? (Restate it in one sentence to confirm understanding.)
   - What type of answer does the question call for? (Explanation, comparison, flow, architecture, code example, inventory?)
   - What areas of the codebase is this question about?
4. If the question is ambiguous, ask for clarification before proceeding. For compound questions ("how does X work and also compare it to Y"), break them into sub-questions and answer each.

---

### Phase Q-1 — Search

1. Scan `wiki/index.md` for pages that are directly relevant to the question.
2. **Identify the question's intended audience.** Three cases:
   - End-user-facing question ("how do I do X?", "what does this app do?") → primarily `audience: user` pages (`features/`, `workflows/`, `glossary/`). Component-level depth is secondary.
   - Developer / architecture question ("how is X implemented?", "what calls Y?") → primarily `audience: dev` pages (`components/`, `architecture/`, `decisions/`).
   - Cross-cutting / agent question ("what actions can be dispatched?", "what does this app expose to MCP?") → focus on `actions/`, `integrations/`, and the `wiki/manifest.json` for structural answers.

   When in doubt, search across all audiences but prioritize the relevant ones in the reading list.
3. Scan the `## Components`, `## Features`, `## Workflows`, `## Actions`, `## Integrations`, `## Decisions` sections of `wiki/index.md` — identify every page that could contain relevant information.
4. If the question involves architecture or system-level behavior, include `wiki/architecture/overview.md` and `wiki/architecture/tech-stack.md` in your reading list.
5. If the question involves a specific implementation detail, grep the wiki for keywords:
   - `grep -r "[keyword]" [OUTPUT_PATH] --include="*.md" -l`
6. **For action-related questions** ("can the assistant do X?"), check `wiki/manifest.json` for `kind: action` entries and filter by `endpoint_kind`, `auth_required`, or `side_effects` as relevant.
7. Build a reading list: every page that might contain relevant content. Err toward reading more, not less — a missed page means a gap in the answer.

---

### Phase Q-2 — Read

1. Read every page on your reading list fully. For component pages: read all sections, not just "Purpose."
2. As you read, collect citations:
   ```
   [wiki/components/auth.md] — "The auth module uses JWT tokens with a 24-hour expiry."
   [wiki/architecture/overview.md] — "All requests pass through the auth middleware before reaching service handlers."
   ```
3. If a wiki page references a source file for a detail you need, read that source file.
4. If the wiki is incomplete or stale for the relevant area (marked `status: partial`, `status: stub`, or has a `<!-- LINT: stale -->` comment), note this and answer from source files directly. Flag the gap at the end of your answer.

---

### Phase Q-3 — Synthesize

1. Compose the answer in the format you selected in Q-0.
2. Every factual claim must trace back to a citation from Phase Q-2. Use inline citations:
   - `(→ [[components/auth]])` for wiki page citations
   - `` (→ `src/auth/middleware.py:42`) `` for source file citations
3. If the answer uses a Mermaid diagram, render it in a fenced code block:
   ````
   ```mermaid
   graph TD
       A[Client] --> B[Auth Middleware]
       B --> C[Service Handler]
   ```
   ````
4. If the answer uses a Marp slide deck, add `marp: true` in the frontmatter of the filed page and structure content as `---`-separated slides.
5. If the answer reveals a gap in the wiki (a component that should exist but doesn't, a relationship that isn't documented), include a **Gaps Identified** section at the end:
   ```markdown
   ## Gaps Identified
   - `wiki/components/[name].md` does not exist — this component is referenced in source but unmapped
   - `wiki/components/auth.md` is marked partial — the session management section is empty
   ```

---

### Phase Q-4 — File (Automatic When Threshold Met)

If the answer meets the filing threshold (any criterion from the Filing Threshold section above):

Skip this phase entirely when the active work mode is `qa-readonly`. In strict
read-only mode, produce the answer in chat and include `READONLY: answered` in
the final status instead of writing a query-result page.

1. Create a new page at `OUTPUT_PATH/query-results/[kebab-case-title].md`.
   - Create the `OUTPUT_PATH/query-results/` directory if it does not yet exist.
   - Use a descriptive kebab-case title that summarizes what was answered: `auth-flow-comparison.md`, `api-to-database-data-flow.md`.
2. Use this frontmatter:
   ```yaml
   ---
   type: query-result
   question: "[the original question, verbatim]"
   mapped_date: YYYY-MM-DD
   status: complete
   tags: [query-result, relevant-tags]
   ---
   ```
3. Structure the page:
   - `## Question` — the original question
   - `## Answer` — your synthesized answer (from Phase Q-3)
   - `## Sources` — bulleted list of every wiki page and source file cited
   - `## Gaps Identified` — if any gaps were found; omit section if none
4. Add the new page to `wiki/index.md` under a `## Query Results` section (create this section if it doesn't exist yet).
5. Cross-link from every component page that this answer references: add `[[query-results/[title]]]` to their `## Related Pages` section.

If the answer does NOT meet the filing threshold, present it directly to the user and do not create any files.

---

### Phase Q-5 — Log (Only When Filed)

If you filed a query-result page in Phase Q-4, append an entry to `wiki/mapping-log.md`:

```markdown
## [DATE] — Query: [brief title of question]

**Question:** [one-sentence summary]
**Filed as:** `query-results/[filename].md`
**Wiki pages read:** [list]
**Source files read:** [list, or "none"]
**Gaps identified:** [list, or "none"]
```

If the answer was not filed, do not append a log entry.

---

## Clarifying Questions

Ask when you encounter:
- A question that could mean two different things given the codebase structure
- A wiki page that is stale or incomplete for the relevant area — is the information in source accurate?
- A term the user used that doesn't match any wiki page or component name — is it a synonym, an old name, or something not yet mapped?

Format:
```
**Question:** [X]
Context: [what you observed that raised the question]
```

---

## Markdown Conventions

Follow all conventions in `wiki/_schema.md` for this project. Key reminders:
- `mapped_date` in frontmatter set to today's date on every page you create
- Use `[[wikilinks]]` for internal links — only to pages that exist
- Mermaid for all diagrams
- File naming: kebab-case, no spaces
- Query-result pages live in `query-results/` subdirectory
