---
slug: shadow-ide/schema/app-actions-dogfood-template
project_slug: shadow-ide
kind: schema
audience: [dev, agent]
version: 1
last_updated:
mapped_date:
status: complete
tags: [app-actions, mcp, dogfood, dry-run, ci, work-modes]
---

# App Actions Dogfood Template

This page is the reusable pattern for adding a governed write-side
`app-actions-mcp` server to a project that already uses kbmap.

The read-side `wiki-mcp` remains read-only. It can answer questions and describe
action contracts, but it never executes app behavior. The write-side
`app-actions-mcp` lives inside the target app repo and is responsible for
controlled execution: debugging commands, safe local repairs, test runs,
dry-run app operations, and approved feature-building workflows.

Use this template when a project wants AI Agent/read-write-edit mode to do real
work while preserving strict control over paid, external, production, or
destructive side effects.

---

## Capability Profiles

| Profile | Work mode | App action access | Typical use |
|---------|-----------|-------------------|-------------|
| QA read-only | `qa-readonly` | None, except read-side `describe_action` and safe previews if the project explicitly exposes them as read-only | Investigate behavior, produce test plans, cite evidence. |
| Engineer read/write/debug | `human-dev-readwrite` | May run local tests, debug commands, and dry-run/test-mode app actions | Debug issues, add features, verify behavior, update KB. |
| AI Agent read/write/edit | `agent-dev-readwrite` | May run allowlisted local app-actions with dry-run/test-mode gates and scoped source edits | Implement fixes/features, run verification, dogfood safe app operations. |
| KB maintainer | `kb-maintainer` | None | Update wiki docs, manifests, mapping logs. |
| Live operator | project-specific explicit approval | May run live side-effecting actions only after approval and audit | Production-affecting tasks such as real uploads, real messages, charges, or external writes. |
| CI preservation | `ci-automation` | Only deterministic fixture-backed dry-run/test-mode actions | Prove safety gates and app-action contracts on every PR. |

Rule of thumb: the more external the effect, the more explicit the approval
must be. Dry-run/test-mode is allowed for dogfood; live side effects require a
human operator decision.

---

## Action Contract Requirements

Every executable action needs an `actions/*.md` page with accurate frontmatter.
Side-effecting actions also need a safe execution story.

Minimum action fields:

```yaml
executable: true
endpoint: "POST /api/example"
endpoint_kind: http
auth_required: true
auth_via: "session cookie"
confirmation_required: true
idempotent: false
side_effects: [mutates_db]
feature: "shadow-ide/feature/example"
dry_run_supported: true
dry_run_param: "dry_run"
test_mode_supported: false
test_mode_param: ""
live_execution_requires_approval: true
```

Guidance:

- If `side_effects` includes anything other than `none`, set
  `confirmation_required: true` unless the operation is clearly read-like.
- If the action can send messages, upload files, charge money, mutate external
  systems, or touch production data, it must have either `dry_run_supported:
  true`, `test_mode_supported: true`, or a written reason in **Notes for the
  assistant** explaining why it cannot be safely dogfooded.
- `dry_run: true` must avoid the real side effect. It should not enqueue work
  that could later be consumed by a worker.
- `test_mode: true` may redirect a real send to a test destination only when an
  operator intentionally executes a non-dry-run test. Do not treat test mode as
  a substitute for dry-run when queueing or external costs are possible.
- Live dispatch requires explicit user approval plus any project-specific
  runtime flags.

---

## app-actions-mcp Server Shape

Create the write-side server inside the target app repo, not inside kbmap.
Start from `wiki-mcp.describe_action` contracts and the reference dispatcher in
the kbmap kit, then replace stubs with app-specific auth and execution.

Recommended tools:

- `list_app_actions` — list allowlisted executable actions.
- `get_app_action_policy` — explain gates for one action.
- `validate_app_action` — validate auth, confirmation, dry-run/test-mode, and
  live-execution policy without dispatching.
- `execute_app_action` — dispatch only after validation passes.

Recommended runtime gates:

- `APP_ACTIONS_ENABLE_EXECUTION=false` by default.
- `APP_ACTIONS_ENABLE_LIVE=false` by default.
- Per-action allowlist in source code.
- Session/auth input required for authenticated app actions.
- `allow_live: true` required in the tool call for live side effects.
- Explicit refusal when known live flags are enabled during fixture dogfood.
- Audit log for every validation failure and every dispatched action.

---

## Fixture-Backed Dogfood Pattern

Use fixture dogfood to prove the write-side MCP can reach the app without using
real users, paid systems, or production state.

Required properties:

- Creates an isolated local database or fixture store.
- Seeds fake users and fake domain records only.
- Starts the app on a free localhost port.
- Logs in or creates a local session using fixture credentials.
- Executes only allowlisted app actions.
- Uses `dry_run: true` and/or `test_mode: true` for side-effecting actions.
- Asserts the backend response proves no live work happened, such as
  `dry_run: true`, `status: "dry_run"`, `task_id: null`, or no upload step.
- Cleans up temp databases, generated files, cookies, and local processes.

Example dogfood scenarios:

| Scenario | Safe proof |
|----------|------------|
| Export/upload action | Dry-run generates local output but never uploads. |
| Notification action | Preview executes; send executes only a no-queue dry-run path. |
| Data repair action | Runs against a throwaway database and reports intended changes. |
| Feature/debug action | Runs tests, typechecks, or local diagnostics with no external calls. |

---

## CI Preservation Checklist

Add CI coverage after the local dogfood script passes.

CI should prove:

- read-only kbmap health still passes;
- read-side `wiki-mcp` still builds and serves query tools;
- write-side `app-actions-mcp` builds;
- policy-only app-actions smoke tests pass with execution disabled;
- backend/unit tests prove dry-run paths do not queue or perform live work;
- fixture-backed app-actions dogfood passes with fake local data;
- `APP_ACTIONS_ENABLE_LIVE=false` and other live flags are pinned off;
- no SMS, email, charge, upload, production API call, or destructive command is
  performed during CI.

PR summary should include:

- which fixture dogfood scripts ran;
- what side effects were explicitly avoided;
- how dry-run/test-mode was asserted;
- whether any live operation remains manual-only.

---

## Copy/Adapt Checklist For A New Project

- [ ] Map action pages for the project workflows that should be discoverable.
- [ ] Mark side effects accurately in every action contract.
- [ ] Add dry-run/test-mode fields to side-effecting contracts.
- [ ] Build a per-app `app-actions-mcp` server with an allowlist.
- [ ] Add `validate_app_action` before `execute_app_action`.
- [ ] Add fixture data and local backend/session setup.
- [ ] Dogfood at least one safe action end to end.
- [ ] Add unit tests proving dry-run/test-mode does not perform live work.
- [ ] Add CI preservation steps.
- [ ] Document which actions remain live-operator-only.

If a project cannot provide a safe fixture-backed proof for an action, keep that
action out of AI Agent/read-write-edit execution until the app has a real
dry-run or test-mode path.
