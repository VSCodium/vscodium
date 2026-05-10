---
slug: shadow-ide/schema/work-mode-examples
project_slug: shadow-ide
kind: schema
audience: [dev, agent]
version: 1
last_updated:
mapped_date:
status: complete
tags: [work-modes, examples, agents]
---

# Work Mode Examples

These examples show how agents should apply `wiki/work-modes.md` in ordinary
project work.

---

## QA Read-Only Bug Investigation

Mode: `qa-readonly`

Prompt shape:

> The login screen fails after entering valid credentials. Help me understand
> what should happen and what QA should test.

Allowed workflow:
1. Read `wiki/index.md`, `wiki/work-modes.md`, relevant feature/workflow pages,
   and component pages.
2. Read source files as evidence when wiki pages are incomplete or stale.
3. Use read-only search commands to locate related code.
4. Return expected behavior, likely failure points, reproduction steps, and test
   cases.

Not allowed:
- edit source;
- edit wiki files;
- run builds or dependency installs;
- file query-result pages unless the project defines a writable QA mode.

Expected final status: `READONLY: answered`.

---

## AI Agent Fixes A Bug

Mode: `agent-dev-readwrite`

Prompt shape:

> Fix the login failure and verify it.

Allowed workflow:
1. Read `wiki/index.md`, `wiki/_schema.md`, `wiki/work-modes.md`, and the
   relevant feature/workflow/component/action pages.
2. Inspect source files after KB orientation.
3. Edit only the files needed for the requested fix.
4. Run focused tests, lint, typecheck, build, or local app verification as
   appropriate.
5. Run ingest so affected KB pages reflect the behavior change.
6. Final response lists changed files, verification, ingest status, and residual
   risk.

Requires explicit approval:
- destructive commands;
- broad unrelated refactors;
- dependency installs;
- secrets or environment changes;
- production-affecting operations.

---

## Human Developer Uses The KB

Mode: `human-dev-readwrite`

Prompt shape:

> Help me add a dashboard filter. I will make the code changes.

Allowed workflow:
1. Use the KB to identify relevant components, workflows, and source files.
2. Explain likely edit points and tests.
3. If the human makes source changes, make sure ingest runs afterward.
4. If the agent is later asked to edit directly, switch to
   `agent-dev-readwrite`.

---

## KB Maintainer Updates Stale Docs

Mode: `kb-maintainer`

Prompt shape:

> Update the wiki for this diff.

Allowed workflow:
1. Read the changed files or diff.
2. Read current wiki pages before updating them.
3. Update affected components, features, workflows, actions, architecture, index,
   and mapping log.
4. Run lint/verification for wiki consistency.

Not allowed:
- edit source files;
- change runtime behavior;
- dispatch app actions.

Expected final status: `KB: updated`.

---

## Architect Plans A Cross-Cutting Change

Mode: `architect`

Prompt shape:

> Plan how we should support role-based project work modes across installed
> kbmap projects.

Allowed workflow:
1. Read schemas, templates, project docs, and related decisions.
2. Draft ADRs, plans, patterns, and issue cards.
3. Identify implementation sequence and risks.
4. Switch to `agent-dev-readwrite` before the AI agent edits implementation
   files.

---

## CI Automation Regenerates Artifacts

Mode: `ci-automation`

Prompt shape:

> Nightly job: regenerate manifests and report drift.

Allowed workflow:
1. Run only configured deterministic commands.
2. Update only configured generated artifacts.
3. Emit machine-readable success/failure output.

Not allowed:
- exploratory source edits;
- broad wiki rewrites;
- commands outside the automation scope.
