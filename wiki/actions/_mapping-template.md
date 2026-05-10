---
slug: shadow-ide/action/ACTION_NAME
project_slug: shadow-ide
kind: action
audience: [agent, dev]
version: 1
last_updated:
mapped_date:
status: stub
executable: true
endpoint: ""
endpoint_kind: http
auth_required: false
auth_via: ""
confirmation_required: true
idempotent: false
side_effects: []
feature: ""
dry_run_supported: false
dry_run_param: ""
test_mode_supported: false
test_mode_param: ""
live_execution_requires_approval: true
tags: []
---

<!--
STRUCTURAL CONTRACT — READ BEFORE EDITING

An action page describes an EXECUTABLE OPERATION that the agentic in-app
assistant can dispatch on behalf of the user. The page IS the contract: it
declares the endpoint, auth requirements, confirmation policy, and side
effects. The write-side `app-actions-mcp` server (per-app, lives in each
app repo) reads these contracts to know what it may execute and how.

When creating a new action page:

1. Read frontmatter-schema.md for the full action-specific frontmatter spec.
2. Copy this file to OUTPUT_PATH/actions/[name].md.
3. Replace shadow-ide and ACTION_NAME. Strip redundant suffixes (don't end
   ACTION_NAME with `-api` — the directory already says it's an action).
4. Required action-specific frontmatter:
   - executable: true (always)
   - endpoint: the canonical invocation (e.g. "POST /api/rest/mobile/login")
   - endpoint_kind: http | mcp_tool | cli | sdk_call | bluetooth | local_function
   - auth_required: bool — does the user need to be authenticated?
   - auth_via: short human description of auth mechanism (or "")
   - confirmation_required: bool — should the assistant ask "are you sure?"
     Default true for any action with side effects beyond `none`.
   - idempotent: bool — safe to retry on transient failure?
   - side_effects: list from controlled vocabulary (see frontmatter-schema.md)
   - feature: the slug of the feature this action implements (REQUIRED, single)
   - dry_run_supported / dry_run_param: required in practice for actions that
     mutate state, send messages, upload files, charge money, or call external
     systems and should be exposed to app-actions-mcp dogfood
   - test_mode_supported / test_mode_param: optional safe-test destination
     support; do not treat this as a substitute for dry-run when queueing or
     external costs are possible
   - live_execution_requires_approval: default true for side-effecting actions
5. Audience: default [agent, dev]. Actions are inherently agent-facing.
6. Bidirectional link: this action's `feature:` must point to a feature page,
   and that feature page's `actions:` must include this action's slug.

Lint validates: required frontmatter populated; endpoint matches an entry in
wiki/.endpoints.json; bidirectional feature ↔ action link; side_effects from
controlled vocabulary; slug grammar.

Section order: Description → Endpoint → Parameters → Side effects → Safety gates → Errors → Linked feature → Notes for the assistant
-->

# Action Name

> One-line summary in agent-readable terms. What the action does, what it returns.

## Description

<!-- 2–4 sentences explaining what the action does, when it's invoked, and
     what it returns. Written for an AI agent reader, not an end user.

     Example:
     "Authenticates an enrollee and returns session credentials + service config.
     Called when a user submits credentials in the login UI. Validates against
     the enrollment database, creates a session token, records the login event
     with device telemetry, and returns the session token + zone configuration." -->

## Endpoint

<!-- The canonical invocation. Echo the frontmatter `endpoint` value here in
     human-readable form. For HTTP: include verb, path, and base URL pattern.
     For SDK/local: include the fully-qualified method or function name. -->

## Parameters

### Required

<!-- Table of required parameters. For HTTP actions, distinguish path, query,
     and body parameters where relevant.

     | Name | Type | Description |
     |------|------|-------------|
     |      |      |             |
-->

### Optional

<!-- Same table format. -->

## Side effects

<!-- Bulleted list — must align with the `side_effects` frontmatter list but
     written in human terms.

     Example:
     - Creates a session token bound to the device.
     - Logs the login event with device telemetry.
     - Increments login attempt counter.

     If `side_effects: [none]`, write "None — read-only operation." -->

## Safety gates

<!-- REQUIRED for executable actions. Explain how app-actions-mcp can validate
     or execute this action safely.

     Include:
     - dry-run support and the exact parameter/value, if available;
     - test-mode support and the exact parameter/value, if available;
     - whether dry-run returns before queueing background work;
     - what proves no live side effect happened;
     - whether live execution requires explicit operator approval;
     - whether this action should stay validation-only until a safe path exists.

     Example:
     "- Supports `dry_run: true`; backend returns `status: \"dry_run\"` and
       `task_id: null` before queueing work.
      - Live execution requires operator approval and APP_ACTIONS_ENABLE_LIVE.
      - Fixture dogfood must seed fake data and assert no external upload or
        message send occurred." -->

## Errors

<!-- Bulleted list of error conditions and what they mean. Format:
     - 401 Unauthorized — credentials rejected
     - 423 Locked — account is locked, user must reset password
     - 500 Server Error — backend issue, retry allowed if `idempotent: true` -->

## Linked feature

<!-- Single wikilink to the [[features/feature-name]] this action implements.
     The frontmatter `feature` field must match. -->

## Notes for the assistant

<!-- REQUIRED section. Guidance for the agentic in-app assistant on:
     - When to dispatch this action automatically (or NOT to).
     - What to ask the user before dispatching (especially if confirmation_required).
     - How to phrase the confirmation prompt.
     - What to do on failure.
     - Whether to retry (idempotent matters here).
     - Compliance / safety considerations specific to this action.

     Example:
     "DO NOT dispatch this action directly. Login credentials must be entered
     by the user in the official login UI for compliance and audit reasons.
     If the user asks 'how do I log in?', explain [[workflows/first-time-login]]
     and direct them to the Log In screen. confirmation_required: false here
     means the API call itself doesn't require an extra confirmation — but
     the user must initiate the login from the UI." -->
