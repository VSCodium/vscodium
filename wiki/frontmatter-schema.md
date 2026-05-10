---
type: schema
purpose: Canonical reference for YAML frontmatter conventions across every wiki page kind. Authoritative source for slug grammar, audience tagging, version policy, and the full field set. Lint validates against this document.
version: "1.0"
manifest_version_compat: 1
---

# Frontmatter Schema — Universal Conventions

Every page in the wiki begins with a YAML frontmatter block. This document is the single source of truth for what goes in that block, how to choose values, and what `lint-schema.md` validates.

The frontmatter is also the structured surface that the **wiki-mcp** server in Phase VII reads to index pages — every field below is consumed by an MCP tool eventually, so consistency matters.

---

## Field reference

### Universal fields (every page)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `slug` | string | yes | Globally-unique identifier. Grammar: `<project_slug>/<kind>/<name>`. Kebab-case. Stable across renames; treat as an external API contract. |
| `project_slug` | string | yes | Short kebab-case prefix shared by every page in this project (e.g. `enrollee-app`). Locked at bootstrap; changing it requires a rename of every slug. |
| `kind` | enum | yes | One of: `component`, `feature`, `workflow`, `integration`, `decision`, `glossary`, `architecture`, `query-result`, `action`, `mapping-log`, `overview`, `schema`. The page's directory must match the kind (e.g. `kind: action` ⇒ `wiki/actions/<name>.md`). |
| `audience` | list | yes | One or more of `dev`, `user`, `agent`. **`all` is discouraged** — force a choice. If you must use `all`, the page must contain section-level audience headers (`## For developers`, `## For users`, `## For agents`). |
| `version` | int | yes | Page-level version. Bumps when content changes meaningfully (not on whitespace edits). The MCP `recent_changes` tool uses this together with `last_updated`. |
| `last_updated` | date | yes | ISO date the page was last edited (`YYYY-MM-DD`). Auto-stamped by ingest/lint. |
| `status` | enum | yes | `stub` (placeholder content), `partial` (some sections filled, TODOs remain), `complete` (every section has real content, no TODOs). |
| `mapped_date` | date | yes | ISO date the page was originally created. Distinct from `last_updated` — never changes after creation. |
| `tags` | list | no | Freeform classification tags (e.g. `[auth, biometric, login]`). Searchable by MCP. |

### Cross-reference fields (set on most page kinds)

These mirror wikilinks in body content but live in frontmatter so MCP tools can read them without parsing markdown. Lint validates that every cross-reference target exists.

| Field | Type | Description |
|-------|------|-------------|
| `components` | list of slugs | Components this page touches or describes. Required on features, workflows, integrations, actions. |
| `features` | list of slugs | Features this page implements or relates to. Required on workflows, integrations, actions. |
| `actions` | list of slugs | Executable actions this page exposes. Required on features (may be empty for display-only features). |
| `workflows` | list of slugs | Workflows this page participates in. Optional on components, features, integrations. |
| `feature` | single slug | The single feature an action page implements. Required on `kind: action` only. Lint validates the bidirectional pair: `actions.<this>.feature == X` ⇒ `features.<X>.actions` includes `<this>`. |

### Action-specific fields (`kind: action` only)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `executable` | bool | yes | Always `true` on action pages. Pages without `executable: true` are not actions. |
| `endpoint` | string | yes | Canonical invocation. Examples: `"POST /api/rest/mobile/login"`, `"mcp:dispatch_action"`, `"cli: shadowtrack login"`. Lint cross-checks against `wiki/.endpoints.json`. |
| `endpoint_kind` | enum | yes | Transport: `http`, `mcp_tool`, `cli`, `sdk_call`, `bluetooth`, `local_function`. |
| `auth_required` | bool | yes | Whether the action needs the user to be authenticated. |
| `auth_via` | string | no | Human description of how auth works. e.g. `"Bearer token in Authorization header"`, `"EnrolleeID + password in body"`. |
| `confirmation_required` | bool | yes | Should the agentic assistant ask "are you sure?" before dispatching. Default `true` for any action with side effects. |
| `idempotent` | bool | yes | Safe to retry on transient failure? `false` for actions that mutate state; `true` for read-like actions. |
| `side_effects` | list | no | Controlled vocabulary describing what the action changes. Allowed values: `creates_session`, `sends_email`, `sends_sms`, `charges_card`, `mutates_db`, `external_api_call`, `records_telemetry`, `triggers_notification`, `modifies_file`, `none`. The `app-actions-mcp` (Phase VIII) reads this to enforce policy. |
| `dry_run_supported` | bool | no | Whether the action has a no-side-effect dry-run path that can be dogfooded safely. Required by mapstatus for side-effecting actions that will be exposed to `app-actions-mcp`. |
| `dry_run_param` | string | no | Parameter name that enables dry-run behavior, e.g. `"dry_run"`. Required when `dry_run_supported: true`; empty when not supported. |
| `test_mode_supported` | bool | no | Whether the action can redirect behavior to a safe test destination. This is weaker than dry-run when queues or external costs are possible. Required as an alternative safety gate when side-effecting actions have no dry-run path. |
| `test_mode_param` | string | no | Parameter name that enables test-mode behavior, e.g. `"test_mode"`. Required when `test_mode_supported: true`; empty when not supported. |
| `live_execution_requires_approval` | bool | no | Whether live execution requires explicit operator approval. Required by mapstatus and must be `true` for side-effecting actions. |

### Integration-specific fields (`kind: integration` only)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vendor` | string | yes | Third-party service or hardware vendor (e.g. `"BACtrack"`, `"Stripe"`, `"Twilio"`). |
| `protocol` | enum | yes | `http`, `https`, `bluetooth-le`, `grpc`, `websocket`, `sdk-only`, `webhook`, `oauth2`. |
| `auth_via` | string | no | Same shape as on action pages. |

### Decision-specific fields (`kind: decision` only)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `decision_status` | enum | yes | `proposed`, `accepted`, `superseded`, `rejected`. Note: this is distinct from the universal `status` field — `status` tracks page completeness, `decision_status` tracks the decision itself. |
| `superseded_by` | slug | no | If `decision_status: superseded`, the slug of the decision that replaced it. |

### Component-specific fields (`kind: component` only)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source_path` | string | yes | Relative path to the source code root for this component (e.g. `"src/auth/"` or `"ShadowTrack/Application/ViewController/Login/"`). Lint checks that this path exists. |

---

## Slug grammar

Format: `<project_slug>/<kind>/<name>`

- `<project_slug>` — set at bootstrap; locked per-project. Kebab-case, no slashes.
- `<kind>` — one of the enum values above. Pluralization MATCHES the directory: `actions/`, `features/`, `workflows/`, `integrations/`, `decisions/`, `components/`, but the slug uses the singular `kind` enum (`action`, `feature`, `workflow`, etc.). **Convention:** plural in directory paths, singular in slugs.
- `<name>` — kebab-case, descriptive but compact. Strip redundant suffixes (`-api` on actions because they live in `actions/`, `-integration` on integrations).

### Examples

- `enrollee-app/feature/enrollee-login` (file: `wiki/features/enrollee-login.md`)
- `enrollee-app/action/mobile-login` (file: `wiki/actions/mobile-login.md`)
- `enrollee-app/integration/bactrack-breathalyzer` (file: `wiki/integrations/bactrack-breathalyzer.md`)
- `enrollee-app/workflow/first-time-login` (file: `wiki/workflows/first-time-login.md`)

### Stability

**Slugs are an external API contract** for the MCP server. Renaming a slug breaks any consumer holding a reference. The lint workflow flags slug changes and warns; the upgrade process should add a `superseded_by` redirect on the old slug rather than delete it outright (TBD design — to be specified during T22).

---

## Audience tagging

Three audiences:

- **`dev`** — software engineers, designers, and contributors reading the wiki to understand or modify the code.
- **`user`** — end users (probationers, officers, bail bondsmen, etc.) who interact with the app via the agentic in-app assistant. They never read the wiki directly; the assistant queries it on their behalf.
- **`agent`** — AI agents (Claude/Cursor/Codex, MCP consumers) that read the wiki programmatically. Almost every page should include `agent` because the wiki is fundamentally a knowledge base for agents.

### Tagging guidance

| Page kind | Typical audience |
|-----------|------------------|
| `component` | `[dev, agent]` |
| `feature` | `[user, agent]` (assistant explains it) or `[user, agent, dev]` |
| `workflow` | `[user, agent, dev]` (cross-cutting) |
| `integration` | `[dev, agent]` (users don't see them directly) |
| `action` | `[agent, dev]` (agents dispatch them; devs maintain them) |
| `decision` | `[dev, agent]` |
| `glossary` | `[user, agent, dev]` |
| `architecture` | `[dev, agent]` |
| `query-result` | inherits from the question's audience |
| `mapping-log`, `overview`, `schema` | `[dev, agent]` |

### Avoiding `audience: [all]`

`all` is shorthand that almost always hides drift. Pages tagged `all` accumulate prose appropriate to one audience but inappropriate to others, and MCP queries that filter by audience start returning garbage. **Lint rule:** any page with `audience: [all]` MUST contain three sections (`## For developers`, `## For users`, `## For agents`) — the section-level audience contract. Otherwise downgrade to a specific list.

A page with a single audience or a specific list does NOT need section-level audience headers — the whole page is for that audience. This is a refinement from the original Plan agent draft (informed by T10.0 dry-run findings).

---

## Version bump policy

The page-level `version` field bumps when content changes meaningfully:

- **Bump:** new section added, factual claim changed, action's `endpoint` or `auth_required` changed, slug renamed (rare), `decision_status` changed.
- **Do NOT bump:** typo fixes, whitespace edits, link reformatting, frontmatter `last_updated` auto-stamps.

Distinct from the `manifest_version` in `manifest-schema.md` — that's the wire-format version of `wiki/manifest.json`, an external API contract for MCP consumers.

---

## What lint validates

Per `lint-schema.md` (T10.5):

1. **Required fields present** — every universal field is set; every kind-specific field is set when the kind matches.
2. **Slug grammar conforms** — matches `<project_slug>/<kind>/<name>` regex.
3. **Slug uniqueness** — no two pages share a slug.
4. **Slug ↔ path consistency** — `kind: action` page must live in `wiki/actions/`, etc.
5. **Cross-reference targets resolve** — every slug in `components`, `features`, `actions`, `workflows`, `feature` must point to a real page.
6. **Bidirectional feature ↔ action** — `actions.<X>.feature: Y` ⇒ `features.<Y>.actions` includes `X`.
7. **Action endpoint validity** — `actions.<X>.endpoint` matches an entry in `wiki/.endpoints.json` (the per-project endpoint manifest).
8. **Audience consistency** — `audience: [all]` requires all three section headers; single-audience pages should not contain audience-mismatched section headers.
9. **`source_path` exists** — for components, the referenced directory exists in source.

---

## Worked examples

### Component page

```yaml
---
slug: enrollee-app/component/STLoginViewController
project_slug: enrollee-app
kind: component
audience: [dev, agent]
version: 1
last_updated: 2026-04-25
mapped_date: 2026-04-25
status: complete
source_path: ShadowTrack/Application/ViewController/Login/
features: [enrollee-app/feature/enrollee-login]
workflows: [enrollee-app/workflow/first-time-login, enrollee-app/workflow/returning-user-login]
tags: [auth, ui, viewcontroller]
---
```

### Feature page

```yaml
---
slug: enrollee-app/feature/enrollee-login
project_slug: enrollee-app
kind: feature
audience: [user, agent]
version: 1
last_updated: 2026-04-25
mapped_date: 2026-04-25
status: complete
components: [enrollee-app/component/STLoginViewController, enrollee-app/component/AppController]
actions: [enrollee-app/action/mobile-login]
workflows: [enrollee-app/workflow/first-time-login, enrollee-app/workflow/returning-user-login]
tags: [auth, login, biometric]
---
```

### Action page

```yaml
---
slug: enrollee-app/action/mobile-login
project_slug: enrollee-app
kind: action
audience: [agent, dev]
version: 1
last_updated: 2026-04-25
mapped_date: 2026-04-25
status: complete
executable: true
endpoint: "POST /api/rest/mobile/login"
endpoint_kind: http
auth_required: false
auth_via: "EnrolleeID + EnrollmentPassword in body"
confirmation_required: false
idempotent: false
side_effects: [creates_session, records_telemetry]
feature: enrollee-app/feature/enrollee-login
tags: [auth, api]
---
```

### Integration page

```yaml
---
slug: enrollee-app/integration/bactrack-breathalyzer
project_slug: enrollee-app
kind: integration
audience: [dev, agent]
version: 1
last_updated: 2026-04-25
mapped_date: 2026-04-25
status: complete
vendor: BACtrack
protocol: bluetooth-le
auth_via: "API key passed at SDK init"
features: [enrollee-app/feature/sobriety-test]
components: [enrollee-app/component/BACtrackCommunicator, enrollee-app/component/STSobrietyTestManager]
tags: [hardware, sobriety, bluetooth]
---
```

### Decision page

```yaml
---
slug: enrollee-app/decision/use-amplify-for-auth
project_slug: enrollee-app
kind: decision
audience: [dev, agent]
version: 1
last_updated: 2026-04-25
mapped_date: 2026-04-25
status: complete
decision_status: accepted
components: [enrollee-app/component/AmplifyConfig]
tags: [auth, infra]
---
```

---

## Migration notes

If a wiki was created under an earlier version of this schema, the upgrade workflow (`/kbmap-upgrade` from T14) handles:

- Adding `slug`, `project_slug`, `kind`, `version`, `last_updated`, `audience` to every page that's missing them. Slugs are derived from filename + folder + the project slug entered at bootstrap.
- Bumping `manifest_version` if the wiki/manifest.json shape changed.
- Reporting any bidi-link inconsistencies that the new lint rules now catch.

This document's own `version:` will bump on breaking changes; `manifest_version_compat: 1` declares the manifest version this frontmatter spec is paired with.
