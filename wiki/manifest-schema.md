---
type: schema
purpose: Locked schema for wiki/manifest.json — the structured index every wiki page is registered in. External API contract for MCP consumers.
manifest_version: 1
schema_version: "1.0"
---

# Manifest Schema — wiki/manifest.json

`wiki/manifest.json` is a regenerable index of every page in the wiki. The lint workflow rebuilds it on every run (T16.5). Read by:

- The **wiki-mcp** read-side server (Phase VII) — uses it to answer `list_by_kind`, `recent_changes`, `get_manifest` without parsing every markdown file.
- The **/mapstatus** slash command (T16) — reports counts and drift.
- The **/kbmap-upgrade** slash command (T14) — checks `manifest_version` for migration prompts.
- The **federated MCP gateway** (Phase VIII, deferred) — aggregates manifests from multiple per-project servers.

**Why locked NOW:** `manifest_version` is an external API contract. Every consumer relies on the field set being stable. Bumping it forces every consumer to migrate. Lock the v1 shape today; bump to v2 only on genuine breaking changes.

---

## Top-level shape

```json
{
  "manifest_version": 1,
  "generated_at": "2026-04-25T18:42:31Z",
  "project_slug": "enrollee-app",
  "kbmap_version": "1.0.0",
  "page_count": 47,
  "pages": [
    { ... },
    { ... }
  ]
}
```

### Top-level fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `manifest_version` | int | yes | The wire-format version. **Always `1` for v1 manifests.** Bumping requires a coordinated migration. |
| `generated_at` | ISO8601 string | yes | UTC timestamp of regeneration. The lint phase that produced this manifest stamps this. |
| `project_slug` | string | yes | The project's slug prefix (e.g. `"enrollee-app"`). Every page entry's `slug` starts with this prefix. |
| `kbmap_version` | semver string | yes | The version of the codebase-map kit that generated this manifest. Useful for `/kbmap-upgrade` to detect old projects. |
| `page_count` | int | yes | Length of the `pages` array. Sanity check for consumers. |
| `pages` | array of page entries | yes | Sorted alphabetically by `slug` for deterministic output. |

---

## Page entry shape

```json
{
  "slug": "enrollee-app/feature/enrollee-login",
  "kind": "feature",
  "audience": ["user", "agent"],
  "version": 1,
  "last_updated": "2026-04-25",
  "mapped_date": "2026-04-25",
  "status": "complete",
  "path": "wiki/features/enrollee-login.md",
  "frontmatter_excerpt": {
    "components": ["enrollee-app/component/STLoginViewController", "enrollee-app/component/AppController"],
    "actions": ["enrollee-app/action/mobile-login"],
    "workflows": ["enrollee-app/workflow/first-time-login"],
    "tags": ["auth", "login"]
  },
  "links_in": ["enrollee-app/workflow/first-time-login", "enrollee-app/component/STLoginViewController"],
  "links_out": ["enrollee-app/component/STLoginViewController", "enrollee-app/action/mobile-login"]
}
```

### Page entry fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `slug` | string | yes | The page's globally-unique slug. Format: `<project_slug>/<kind>/<name>`. |
| `kind` | enum | yes | One of the `kind:` values from `frontmatter-schema.md`. |
| `audience` | array of strings | yes | Subset of `["dev", "user", "agent"]` (or `["all"]` if section-headered). |
| `version` | int | yes | Page-level version from frontmatter. |
| `last_updated` | ISO date | yes | YYYY-MM-DD from frontmatter. |
| `mapped_date` | ISO date | yes | Original creation date from frontmatter. |
| `status` | enum | yes | `stub` / `partial` / `complete` from frontmatter. |
| `path` | string | yes | Path relative to the project root (e.g. `"wiki/features/enrollee-login.md"`). |
| `frontmatter_excerpt` | object | yes | Page-kind-specific subset of frontmatter. **Schema below.** |
| `links_in` | array of slugs | yes | Other pages that wikilink TO this page. |
| `links_out` | array of slugs | yes | Pages this page wikilinks TO. |

### `frontmatter_excerpt` per kind

The excerpt object includes only the fields useful for indexing/filtering — full frontmatter is in the markdown file itself, fetchable via `get_page(slug)`.

**For `kind: feature`:**
```json
{ "components": [...], "actions": [...], "workflows": [...], "tags": [...] }
```

**For `kind: workflow`:**
```json
{ "components": [...], "features": [...], "actions": [...], "tags": [...] }
```

**For `kind: action`:**
```json
{
  "endpoint": "POST /api/rest/mobile/login",
  "endpoint_kind": "http",
  "auth_required": false,
  "confirmation_required": false,
  "idempotent": false,
  "side_effects": ["creates_session", "records_telemetry"],
  "feature": "enrollee-app/feature/enrollee-login",
  "tags": [...]
}
```

**For `kind: integration`:**
```json
{
  "vendor": "BACtrack",
  "protocol": "bluetooth-le",
  "auth_via": "API key passed at SDK init",
  "features": [...],
  "components": [...],
  "tags": [...]
}
```

**For `kind: component`:**
```json
{ "source_path": "src/auth/", "features": [...], "workflows": [...], "tags": [...] }
```

**For `kind: decision`:**
```json
{ "decision_status": "accepted", "superseded_by": null, "components": [...], "tags": [...] }
```

**For `kind: glossary`:**
```json
{ "tags": [...] }
```

**For `kind: architecture`, `query-result`, `mapping-log`, `overview`, `schema`:**
```json
{ "tags": [...] }
```

---

## Determinism guarantees

Lint must produce a byte-identical manifest given an unchanged wiki. This means:

- `pages` array is sorted by `slug` ascending.
- Within each page entry, `links_in`, `links_out`, `audience`, list values in `frontmatter_excerpt` are all sorted alphabetically (or by their natural enum order).
- `generated_at` is the only field that varies on identical regeneration — and per the lint phase contract, the lint workflow runs `git diff manifest.json` excluding the `generated_at` field to verify determinism.

This guarantee makes the manifest safe to commit to git: a lint pass on an unchanged wiki produces no diff.

---

## Validation rules (run during T16.5 manifest generation)

The lint phase fails (and refuses to write `manifest.json`) if:

1. `manifest_version` does not equal the locked value (currently `1`). Catches accidental edits to the manifest's own version.
2. Any page's `slug` does not match the regex `^[a-z0-9-]+/(component|feature|workflow|integration|decision|glossary|architecture|query-result|action|mapping-log|overview|schema)/[a-z0-9-]+$`.
3. Any page's `slug` is not unique across the wiki.
4. Any page's `kind` does not match its directory.
5. Any cross-reference slug (in `links_in`, `links_out`, or `frontmatter_excerpt`) does not resolve to an actual page in the manifest.
6. Bidirectional pair violation: `actions.<X>.feature: Y` exists but `features.<Y>.actions` does not include `X`.

A lint that fails manifest generation reports the specific page and rule violated, but does NOT modify the existing manifest — it leaves the prior valid version in place so MCP consumers don't see corrupt data mid-update.

---

## Consumer compatibility

Versioning policy:

- **`manifest_version: 1` consumers** must accept any future v1 manifest with extra fields they don't recognize. Forward-compat for additions.
- **Breaking changes** (renames, type changes, field removals) require `manifest_version: 2` and an explicit migration. The `/kbmap-upgrade` slash command handles the migration prompt.

The wiki-mcp server (T22) ships with a hardcoded `MANIFEST_VERSION_SUPPORTED = 1` constant. If it reads a manifest with a higher version, it refuses to start with a clear error pointing at the upgrade docs.

---

## Example: full manifest with two pages

```json
{
  "manifest_version": 1,
  "generated_at": "2026-04-25T18:42:31Z",
  "project_slug": "enrollee-app",
  "kbmap_version": "1.0.0",
  "page_count": 2,
  "pages": [
    {
      "slug": "enrollee-app/action/mobile-login",
      "kind": "action",
      "audience": ["agent", "dev"],
      "version": 1,
      "last_updated": "2026-04-25",
      "mapped_date": "2026-04-25",
      "status": "complete",
      "path": "wiki/actions/mobile-login.md",
      "frontmatter_excerpt": {
        "endpoint": "POST /api/rest/mobile/login",
        "endpoint_kind": "http",
        "auth_required": false,
        "confirmation_required": false,
        "idempotent": false,
        "side_effects": ["creates_session", "records_telemetry"],
        "feature": "enrollee-app/feature/enrollee-login",
        "tags": ["auth", "api"]
      },
      "links_in": ["enrollee-app/feature/enrollee-login", "enrollee-app/workflow/first-time-login"],
      "links_out": ["enrollee-app/feature/enrollee-login"]
    },
    {
      "slug": "enrollee-app/feature/enrollee-login",
      "kind": "feature",
      "audience": ["agent", "user"],
      "version": 1,
      "last_updated": "2026-04-25",
      "mapped_date": "2026-04-25",
      "status": "complete",
      "path": "wiki/features/enrollee-login.md",
      "frontmatter_excerpt": {
        "components": ["enrollee-app/component/AppController", "enrollee-app/component/STLoginViewController"],
        "actions": ["enrollee-app/action/mobile-login"],
        "workflows": ["enrollee-app/workflow/first-time-login", "enrollee-app/workflow/returning-user-login"],
        "tags": ["auth", "biometric", "login"]
      },
      "links_in": ["enrollee-app/workflow/first-time-login"],
      "links_out": ["enrollee-app/action/mobile-login", "enrollee-app/component/AppController", "enrollee-app/component/STLoginViewController"]
    }
  ]
}
```
