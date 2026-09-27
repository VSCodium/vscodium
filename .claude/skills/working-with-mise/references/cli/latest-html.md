mise latest

latest` [​](#mise-latest)

- **Usage:** `mise latest [-i --installed] [--minimum-release-age <MINIMUM_RELEASE_AGE>] <TOOL@VERSION>`
- **Effect:** read-only
- **Source code:** [`src/cli/latest.rs`](https://github.com/jdx/mise/blob/main/src/cli/latest.rs)

Resolve the latest matching version request for a tool

Supports prefixes such as `node@20`. The selected backend decides how channels, refs, and non-SemVer versions resolve; "latest" is not a generic sort of strings. This prints a version without installing it or changing configuration.

## Arguments [​](#arguments)

- **`<TOOL@VERSION>`** — Tool to get the latest version of

## Flags [​](#flags)

- **`-i --installed`** — Show latest installed instead of available version
- **`--minimum-release-age <MINIMUM_RELEASE_AGE>`** — Only consider versions released before this date or older than this duration

  Supports absolute dates like "2024-06-01" and relative durations like "90d" or "1y". Overrides per-tool `minimum_release_age` options and the global `minimum_release_age` setting.
- **`-h --help`** — Print help

## Examples [​](#examples)

Resolve a Node 20 release, or the backend's latest stable release

```
mise latest node@20
mise latest node
```

Restrict resolution to installed versions

```
mise latest node@20 --installed
```

Exclude releases newer than the requested age

```
mise latest node --minimum-release-age 30d
```

## Related documentation [​](#related-documentation)

- [Version requests](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/latest.md)

Last updated:

Pager

[Previous pagemise install-into](https://mise.jdx.dev/cli/install-into.html)

[Next pagemise link](https://mise.jdx.dev/cli/link.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)