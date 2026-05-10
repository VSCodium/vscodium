---
slug: shadow-ide/schema/work-modes
project_slug: shadow-ide
kind: schema
audience: [dev, agent]
version: 1
last_updated:
mapped_date:
status: complete
tags: [work-modes, permissions, agents]
---

# Work Modes

This project uses kbmap work modes to decide whether the current user or agent
is only reading the project, maintaining the knowledge base, or actively editing
project source code.

The canonical schema is `wiki/work-modes-schema.md`. This page is the local
project policy. Keep mode IDs stable so agents and automation can reason about
them consistently.

---

## Mode table

| Mode | Actor | Can edit source? | Can update KB? | Primary use |
|------|-------|------------------|----------------|-------------|
| `qa-readonly` | QA tester, reviewer, support analyst | No | No | Investigate behavior, produce test guidance, cite evidence. |
| `human-dev-readwrite` | Software engineer | Yes | Yes | Debug, add features, run verification, keep KB in sync. |
| `agent-dev-readwrite` | Codex, Claude Code, Cursor agent, or similar AI coding agent | Yes | Yes | AI agent directly edits/debugs/builds within scope, then ingests KB updates. |
| `kb-maintainer` | KB/documentation agent | No | Yes | Update wiki pages, lint, repair stale docs, regenerate manifests. |
| `architect` | Tech lead, senior engineer, AI-facing admin | Maybe | Yes | Plan broad changes, ADRs, patterns, issue breakdowns. |
| `ci-automation` | CI runner or scheduled job | Scoped | Scoped | Run deterministic checks or regeneration tasks. |

---

## `qa-readonly`

Use when the person or agent should investigate without changing files.

Allowed:
- read `wiki/` pages and manifests;
- inspect source files as evidence;
- use read-side `wiki-mcp` tools, including `describe_action`, to understand
  available contracts;
- run read-only search/list/stat commands;
- produce bug hypotheses, reproduction steps, and test plans.

Forbidden:
- edit source files;
- edit wiki files;
- install dependencies or run builds;
- dispatch app actions;
- call write-side `app-actions-mcp`;
- file query-result pages unless a project owner enables a writable QA research
  mode.

Final status: `READONLY: answered`.

---

## `human-dev-readwrite`

Use when a software engineer is allowed to modify this project.

Allowed:
- read KB and source;
- edit source files;
- run tests, linters, typechecks, builds, and local app verification;
- run approved local `app-actions-mcp` debugging or dry-run/test-mode actions;
- update KB pages after source changes.

Required:
- read relevant KB pages before implementation;
- keep edits scoped to the requested task;
- run appropriate verification;
- complete ingest after source changes.

Final status: summarize code changes, verification, and ingest status.

---

## `agent-dev-readwrite`

Use when an AI coding agent is allowed to directly work in this project.

Expected flow:
1. Read `wiki/index.md`, `wiki/_schema.md`, this file, and relevant
   component/feature/workflow/action pages.
2. Inspect source files after KB orientation.
3. Edit/debug/build only within the requested scope.
4. Run focused verification.
5. Update or ingest KB changes before final response.

Allowed:
- source edits;
- bug fixes and feature additions;
- test updates;
- test/lint/typecheck/build commands;
- local dev-server use when needed for verification;
- approved local `app-actions-mcp` actions for debugging, fixture dogfood,
  dry-run repairs, and test-mode app workflows;
- KB updates through ingest/lint workflows.

Requires explicit approval:
- destructive commands;
- broad rewrites or unrelated refactors;
- dependency installs or lockfile churn;
- secrets, credentials, or environment changes;
- production-affecting operations;
- real external side effects.

Forbidden:
- revert unrelated user changes;
- skip ingest after source edits;
- silently expand scope;
- dispatch production app actions.
- dispatch live side-effecting app actions without dry-run/test-mode proof and
  explicit operator approval.

Final status: changed files, verification run, ingest/KB update status, and any
residual risks or skipped checks.

---

## `kb-maintainer`

Use when the task is wiki-only.

Allowed:
- read source as evidence;
- update wiki pages;
- update mapping logs and manifests;
- run wiki lint/maintenance tooling.

Forbidden:
- edit source code;
- change runtime behavior;
- dispatch app actions.

Final status: `KB: updated`, `KB: skipped — <reason>`, or
`KB: failed — <error>`.

---

## `architect`

Use for design planning, ADRs, cross-project synthesis, and issue breakdowns.

This mode may update planning or KB documents when asked, but implementation
edits should switch to `human-dev-readwrite` or `agent-dev-readwrite`.

---

## `ci-automation`

Use for deterministic automation.

Allowed work must be explicitly configured by the job. Typical examples are
tests, lint, manifest regeneration, report generation, and fixture-backed
app-actions dogfood with live side effects pinned off.

---

## Examples

### QA investigates a bug

Mode: `qa-readonly`

The agent reads feature, workflow, component, and source evidence, then returns
expected behavior, likely failure areas, and a test checklist. No files are
changed.

### AI agent fixes a bug

Mode: `agent-dev-readwrite`

The agent reads the KB, inspects relevant source, edits the code, runs tests,
updates affected wiki pages through ingest, and reports changed files plus
verification.

### KB maintainer updates stale docs

Mode: `kb-maintainer`

The agent reads source and existing wiki pages, updates stale KB content, runs
lint, and does not edit source files.
