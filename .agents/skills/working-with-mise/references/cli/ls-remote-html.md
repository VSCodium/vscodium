mise ls-remote

ls-remote` [​](#mise-ls-remote)

- **Usage:** `mise ls-remote [FLAGS] [TOOL@VERSION] [PREFIX]`
- **Aliases:** `list-all`, `list-remote`
- **Effect:** read-only
- **Source code:** [`src/cli/ls_remote.rs`](https://github.com/jdx/mise/blob/main/src/cli/ls_remote.rs)

List tool versions available to install

Results may be cached; run `mise cache clear TOOL` to refresh one tool before querying it again. Version formats and ordering are backend-specific.

## Arguments [​](#arguments)

- **`[TOOL@VERSION]`** — Tool to get versions for
- **`[PREFIX]`** — Filter the available versions by this prefix Equivalent to the version selector after `@` in the first argument

## Flags [​](#flags)

- **`--all`** — List available versions for every backend/tool currently known to mise
- **`--minimum-release-age <MINIMUM_RELEASE_AGE>`** — Only show versions released before this age or date

  Supports absolute dates like "2024-06-01" and relative durations like "90d" or "1y".
- **`-J --json`** — Output in JSON format (includes version metadata like created\_at timestamps when available)
- **`--no-versions-host`** — Disable checking the mise-versions host
- **`--prerelease`** — Include pre-release versions in the output for backends that report upstream prerelease metadata or opt in to regex-based prerelease detection. Equivalent to setting `MISE_PRERELEASES=1` or the `prereleases` setting for the duration of this command.
- **`--strict-metadata`** — Fail if release metadata fetches fail

  Requires --json and --no-versions-host.

  This prevents metadata consumers from accepting empty fallback results when a backend's metadata-producing upstream request fails.
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise ls-remote node
mise ls-remote node@20
mise ls-remote node 20
mise ls-remote node --minimum-release-age 30d
mise ls-remote github:cli/cli --json
```

## Related documentation [​](#related-documentation)

- [Version requests](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/ls-remote.md)

Last updated:

Pager

[Previous pagemise ls](https://mise.jdx.dev/cli/ls.html)

[Next pagemise mcp](https://mise.jdx.dev/cli/mcp.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)