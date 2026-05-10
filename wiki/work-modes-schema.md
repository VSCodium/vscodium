---
type: schema
purpose: Canonical work-mode and capability-profile contract for kbmap projects.
version: "1.0"
---

# Work Modes Schema

Work modes define what kind of work an agent or person may do in a project that
has a kbmap wiki installed. They separate three different capabilities that are
easy to confuse:

- reading the knowledge base;
- editing the project source code;
- maintaining the knowledge base after project work changes behavior.

The read-side `wiki-mcp` server remains read-only in every mode. A coding agent
may still edit project files when the active mode grants source-write
capability through the local development environment.

---

## Default modes

| Mode | Intended actor | Summary |
|------|----------------|---------|
| `qa-readonly` | QA tester, reviewer, support analyst | Investigate behavior and produce test guidance without editing files. |
| `human-dev-readwrite` | Software engineer using the wiki as context | Debug, edit, build, and test the project; update the KB afterward. |
| `agent-dev-readwrite` | Codex, Claude Code, Cursor agent, or another coding agent | Read KB first, edit/debug/build within scope, verify, then ingest KB updates. |
| `kb-maintainer` | Documentation or KB maintenance agent | Update wiki pages only; do not edit source code. |
| `architect` | Senior engineer, tech lead, AI-facing admin | Plan cross-cutting design, ADRs, and broad changes; implementation authority depends on session scope. |
| `ci-automation` | CI runner or scheduled automation | Run scoped verification and regeneration tasks with narrow write permissions. |

Projects may add local modes, but the default mode IDs above are stable API
terms. Agent instructions, examples, and future MCP discovery should use these
exact identifiers.

---

## Capability fields

Each mode is described by the following fields.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `mode_id` | string | yes | Stable kebab-case identifier. |
| `intended_actor` | string | yes | Person, role, or agent expected to use the mode. |
| `can_read_kb` | bool | yes | May read `wiki/`, manifests, graph artifacts, and MCP read tools. |
| `can_read_source` | bool | yes | May inspect project source files as evidence. |
| `can_edit_source` | bool | yes | May modify project source files. |
| `can_run_tests` | bool | yes | May run test, lint, typecheck, and build verification commands. |
| `can_run_app` | bool | yes | May start a dev server or local app runtime for verification. |
| `can_validate_app_actions` | bool | yes | May inspect or validate write-side app-action policy without dispatching. |
| `can_execute_safe_app_actions` | bool | yes | May execute allowlisted local app-actions that are dry-run, test-mode, or fixture-only. |
| `can_execute_live_app_actions` | bool | yes | May execute live side-effecting app-actions. Should be `false` by default outside explicit operator mode. |
| `can_update_kb` | bool | yes | May create or modify wiki pages. |
| `requires_ingest_after_code_change` | bool | yes | Source edits require a completed ingest before final response. |
| `approval_required_for` | list | yes | Actions that require explicit user approval. |
| `forbidden_actions` | list | yes | Actions that are never allowed in this mode. |
| `final_contract` | string | yes | Required final status language for the mode. |

---

## Canonical capability matrix

| Capability | `qa-readonly` | `human-dev-readwrite` | `agent-dev-readwrite` | `kb-maintainer` | `architect` | `ci-automation` |
|------------|---------------|-----------------------|-----------------------|-----------------|-------------|-----------------|
| Read KB | yes | yes | yes | yes | yes | yes |
| Read source | yes | yes | yes | yes | yes | scoped |
| Edit source | no | yes | yes | no | maybe | scoped |
| Run tests/builds | no | yes | yes | no | maybe | yes |
| Run dev server/app | no | yes | yes, if needed | no | maybe | usually no |
| Validate app-action policy | read-only only | yes | yes | read-only only | yes | yes |
| Execute safe app-actions | no | yes | yes | no | no | scoped fixture-only |
| Execute live app-actions | no | approval only | approval only | no | no | no |
| Update KB | no | yes | yes | yes | yes | scoped |
| Requires ingest after source change | n/a | yes | yes | n/a | if source changed | if source changed |

`architect` is intentionally conditional. Architecture sessions often produce
plans, ADRs, or issue cards without touching source. If the user asks the
architect to implement, switch to `human-dev-readwrite` or
`agent-dev-readwrite` depending on who is doing the edits.

---

## Mode contracts

### `qa-readonly`

Use this mode when a QA tester, reviewer, or support analyst needs to understand
expected behavior, investigate a report, or produce test guidance.

Allowed:
- read wiki pages, manifest entries, graph artifacts, and source files;
- use read-side `wiki-mcp` action descriptions to understand available
  contracts;
- use read-only commands to locate evidence;
- produce bug hypotheses, reproduction steps, test plans, and citations.

Forbidden:
- editing source files;
- editing wiki files;
- installing dependencies or running builds;
- dispatching real app actions;
- calling write-side `app-actions-mcp`;
- filing query-result pages unless the project explicitly defines a separate
  writable QA research mode.

Final contract: `READONLY: answered` or `READONLY: failed — <error>`.

### `human-dev-readwrite`

Use this mode when a human engineer is driving project implementation with the
wiki as context.

Allowed:
- read KB and source;
- edit source files;
- run tests, builds, linters, and local app verification;
- run approved local app-actions for debugging, dry-run repairs, and test-mode
  workflows;
- update wiki pages after source changes.

Required:
- read relevant KB pages before editing;
- keep edits scoped to the requested task;
- run appropriate verification;
- run ingest after source changes.

Final contract: summarize code changes, verification, and ingest status.

### `agent-dev-readwrite`

Use this mode when an AI coding agent is expected to directly debug, edit, build,
or extend the target project.

Required flow:
1. Read `wiki/index.md`, `wiki/_schema.md`, `wiki/work-modes.md`, and relevant
   component/feature/workflow/action pages.
2. Inspect source only after orienting through the KB.
3. Edit project files within the user's requested scope.
4. Run focused verification.
5. Update or ingest affected KB pages before final response.

Allowed:
- source edits, bug fixes, feature additions, and test updates;
- test, lint, typecheck, build, and local dev-server verification;
- approved local `app-actions-mcp` actions for debugging, fixture dogfood,
  dry-run repairs, and test-mode workflows;
- KB updates through ingest/lint workflows.

Approval required:
- destructive commands;
- broad rewrites or unrelated refactors;
- dependency installs or lockfile churn not required by the task;
- secrets, credentials, or environment changes;
- production-affecting operations;
- real external side effects such as sending emails, charging cards, or calling
  production APIs.

Forbidden:
- reverting unrelated user changes;
- skipping ingest after source edits;
- silently expanding scope;
- dispatching real app actions against production systems.
- dispatching live side-effecting app actions without dry-run/test-mode proof
  and explicit operator approval.

Final contract: list changed files, verification run, ingest/KB update status,
and any residual risk or skipped check.

### `kb-maintainer`

Use this mode for wiki-only maintenance: ingest, lint, stale-page repair, schema
drift cleanup, and manifest regeneration.

Allowed:
- read source as evidence;
- update wiki pages and mapping logs;
- run wiki lint or manifest tooling.

Forbidden:
- editing project source code;
- changing runtime behavior;
- dispatching app actions.

Final contract: `KB: updated`, `KB: skipped — <reason>`, or
`KB: failed — <error>`.

### `architect`

Use this mode for planning, ADRs, cross-project synthesis, and high-level design.

Allowed:
- read KB and source;
- draft plans, decisions, patterns, and Linear cards;
- update ADRs or vault-level planning docs when requested.

Forbidden unless the active mode changes:
- editing implementation files;
- running production-affecting commands;
- making broad code changes without explicit implementation scope.

Final contract: summarize decisions, open questions, and next implementation
steps.

### `ci-automation`

Use this mode for scheduled or pipeline-driven tasks.

Allowed:
- run scoped checks;
- regenerate deterministic artifacts such as manifests;
- update explicitly allowed automation outputs.
- run fixture-backed app-actions dogfood when live flags are pinned off.

Forbidden:
- exploratory source edits;
- broad wiki rewrites;
- commands outside the configured automation scope.

Final contract: machine-readable success/failure output plus relevant artifact
paths.

---

## Mode selection rules

If the user asks a question about how the project works, default to
`qa-readonly` unless they ask you to edit, fix, build, or update files.

If the user asks an AI agent to debug, fix, add a feature, implement a task, or
run verification with edits allowed, use `agent-dev-readwrite`.

If the user asks a human engineer to do the work while the agent only advises,
use `human-dev-readwrite` for the human's intended workflow but keep the agent's
own actions within the user's requested scope.

If the user asks to update docs, ingest a diff, repair stale wiki pages, or run
wiki lint without changing source, use `kb-maintainer`.

If the user asks to plan, compare architectures, define a strategy, or create
issue cards, use `architect`.

When intent is ambiguous and choosing incorrectly could cause writes, ask for
clarification before editing.

---

## Future machine-readable policy

Markdown remains the human source of truth in v1. A future release may add a
generated `wiki/work-modes.json` or a `manifest.json` extension so MCP hosts and
automation can discover mode capabilities programmatically.

Recommended JSON shape:

```json
{
  "schema_version": 1,
  "source": "wiki/work-modes.md",
  "default_mode": "qa-readonly",
  "modes": [
    {
      "mode_id": "agent-dev-readwrite",
      "can_read_kb": true,
      "can_read_source": true,
      "can_edit_source": true,
      "can_run_tests": true,
      "can_run_app": true,
      "can_validate_app_actions": true,
      "can_execute_safe_app_actions": true,
      "can_execute_live_app_actions": false,
      "can_update_kb": true,
      "requires_ingest_after_code_change": true,
      "approval_required_for": [
        "destructive_commands",
        "dependency_installs",
        "production_side_effects"
      ],
      "forbidden_actions": [
        "revert_unrelated_user_changes",
        "skip_ingest_after_source_change"
      ]
    }
  ]
}
```

The JSON file should be generated from the Markdown policy or clearly marked as
derived. Do not create two independently edited sources of truth.

Follow-up implementation cards, if this design is accepted:
- generate `wiki/work-modes.json` from `wiki/work-modes.md`;
- expose active/available modes through `wiki-mcp`;
- add host-specific UI guidance for selecting a mode at session start.
