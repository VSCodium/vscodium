---
slug: shadow-ide/schema/app-actions-adoption-checklist
project_slug: shadow-ide
kind: schema
audience: [dev, agent]
version: 1
last_updated: 2026-05-04
mapped_date: 2026-05-04
status: complete
tags: [app-actions, mcp, adoption, checklist, dry-run, ci]
---

# App Actions Adoption Checklist

Use this checklist when a kbmap-installed project wants governed
AI Agent/read-write-edit mode through a per-app `app-actions-mcp` server.

The default `wiki-mcp` server remains read-only. It describes the wiki and
action contracts, but it never dispatches project behavior. The write-side
`app-actions-mcp` server lives in the target app repo because it must own app
auth, sessions, allowlists, idempotency, audit logs, dry-run behavior, test-mode
behavior, and any live side-effect policy.

Do not add `app-actions-mcp` just because kbmap is installed. Add it only when
the project owner wants controlled execution for debugging, tests, safe local
repairs, fixture dogfood, or feature-building workflows.

## 1. Confirm The Capability Profile

Choose the work mode before building the write-side server:

| Actor | Work mode | App-action access |
|-------|-----------|-------------------|
| QA tester or reviewer | `qa-readonly` | Read wiki/source evidence only. May use read-side `describe_action`, but cannot execute app actions. |
| Human engineer | `human-dev-readwrite` | May edit source and run allowlisted local dry-run/test-mode app actions after project approval. |
| AI coding agent | `agent-dev-readwrite` | May edit/debug/build in scope and run allowlisted local dry-run/test-mode app actions. |
| KB maintainer | `kb-maintainer` | Wiki-only updates; no source edits and no app action execution. |
| CI | `ci-automation` | Fixture-only deterministic checks with live effects pinned off. |

Live production-affecting execution is not part of the default read/write/edit
profile. It requires explicit operator approval and project-specific audit
rules.

## 2. Map Action Contracts First

Before writing server code, create or update the relevant `wiki/actions/*.md`
pages. Each executable action needs:

- accurate endpoint and endpoint kind;
- auth requirements and auth mechanism;
- confirmation and idempotency policy;
- controlled `side_effects`;
- a linked feature;
- dry-run/test-mode metadata;
- `live_execution_requires_approval`;
- a `## Safety gates` section that explains how the action is safely dogfooded.

Use `wiki/actions/_mapping-template.md` for the page shape and
`wiki/frontmatter-schema.md` for field meanings.

## 3. Create The Per-App Server In The App Repo

Create `app-actions-mcp` inside the target application repository, not inside
the kbmap template and not inside the read-only `mcp-server/`.

Recommended minimum tools:

- `list_app_actions` lists allowlisted executable actions.
- `get_app_action_policy` explains safety gates for one action.
- `validate_app_action` checks auth, mode, params, dry-run/test-mode, and live
  policy without dispatching.
- `execute_app_action` dispatches only after validation passes.

Start from the kbmap reference dispatcher at
`knowledgeBase-vault/codebase-map/examples/reference-dispatcher.ts`, then
replace the stubs with the app's real auth/session checks and dispatch wiring.

## 4. Pin Runtime Gates Closed By Default

Use environment flags that fail closed:

- `APP_ACTIONS_ENABLE_EXECUTION=false` by default.
- `APP_ACTIONS_ENABLE_LIVE=false` by default.
- App-specific live flags, upload flags, message flags, payment flags, and
  external-write flags default off.
- `WIKI_PATH` points at the adopted project's `wiki/`.
- Test fixtures point at local temp directories, local databases, or fake
  service adapters.
- Timeouts are explicit so a hung action cannot block the host indefinitely.

The write-side server should refuse execution when required flags are missing,
when known live flags are enabled during fixture dogfood, or when a live
side-effect request lacks explicit approval.

## 5. Implement A Source-Controlled Allowlist

The allowlist should be code-reviewed source, not user input.

Each entry should bind:

- action slug;
- dispatch handler;
- required capability profile;
- allowed environments;
- dry-run/test-mode requirements;
- auth/session requirement;
- whether live execution can ever be allowed;
- audit label or event name.

Unknown actions must fail validation. Actions present in the wiki but absent
from the allowlist are described by read-side MCP only; they are not executable.

## 6. Require Auth And Session Evidence

For authenticated actions:

- validate the caller/session before dispatch;
- keep secrets out of the wiki;
- pass tokens through host/runtime secrets, not action frontmatter;
- audit validation failures and successful dispatches;
- refuse to run as a generic agent identity when the app requires a real user
  context.

For local developer actions, document the exact safe local auth mechanism in
the app repo.

## 7. Enforce Dry-Run And Test-Mode Policy

Side-effecting actions need complete safety metadata before they are exposed to
`app-actions-mcp`. Executable dogfood needs at least one safe path:

- `dry_run_supported: true` with a non-empty `dry_run_param`; or
- `test_mode_supported: true` with a non-empty `test_mode_param`.

Dry-run is the preferred path. It must return before the real side effect, such
as queueing a job, uploading a file, sending a message, charging money, or
writing to a production system.

Test mode is weaker than dry-run when it still sends, uploads, or queues work.
Use it only with fake destinations and explicit operator intent.

Actions with `side_effects: [none]` may omit dry-run/test-mode fields, but they
still need accurate auth, endpoint, and linked-feature metadata.

When a side-effecting action does not yet have a dry-run or test-mode path, keep
the contract policy-inspection-only. Set the dry-run/test-mode booleans to
`false`, keep `live_execution_requires_approval: true`, and explain in
`## Safety gates` that `app-actions-mcp` must not execute it until a fixture
path exists.

## 8. Dogfood With Fixtures Only

Fixture dogfood must use fake/local data and prove the side effect did not
happen.

Examples:

- local SQLite or temp database instead of production data;
- fake SMS/email/payment adapters;
- local temp export directory instead of SFTP;
- `dry_run: true` responses such as `status: "dry_run"` and `task_id: null`;
- assertions that queues, uploads, sends, charges, and external writes were not
  called.

Do not use production data, paid systems, live message delivery, real uploads,
or live external writes in fixture dogfood.

## 9. Preserve It In CI

CI should prove the adoption remains safe:

- read-only `wiki-mcp` builds;
- write-side `app-actions-mcp` builds;
- policy/list/validate tools work with execution disabled;
- fixture-backed dry-run/test-mode dogfood passes;
- live flags are pinned off;
- no SMS, SFTP upload, payment, or production external write is reachable;
- manifest/mapstatus checks still pass after action contract changes.

CI must not require real credentials for paid or production systems.

## 10. PR Checklist

Before merging an app-actions adoption:

- [ ] `wiki/actions/*.md` contracts are mapped for every executable action.
- [ ] Side-effecting actions include dry-run/test-mode/live-approval metadata.
- [ ] `## Safety gates` sections explain the proof of no live side effect.
- [ ] `app-actions-mcp` lives in the app repo.
- [ ] Allowlist is source-controlled and denies unknown actions.
- [ ] Runtime flags fail closed by default.
- [ ] Auth/session handling is documented and tested.
- [ ] Fixture dogfood uses fake/local data only.
- [ ] CI proves no live external side effect can happen.
- [ ] Live execution requires explicit operator approval.

## Related Templates

- `wiki/app-actions-dogfood-template.md` defines the reusable dogfood and CI
  preservation pattern.
- `wiki/actions/_mapping-template.md` defines the action contract page shape.
- `knowledgeBase-vault/codebase-map/examples/reference-dispatcher.ts` shows the
  write-side MCP dispatcher pattern to copy into an app repo.
