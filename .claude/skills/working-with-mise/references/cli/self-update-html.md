mise self-update

self-update` [​](#mise-self-update)

- **Usage:** `mise self-update [FLAGS] [VERSION]`
- **Effect:** modifies state
- **Source code:** [`src/cli/self_update.rs`](https://github.com/jdx/mise/blob/main/src/cli/self_update.rs)

Update mise itself

Uses the GitHub Releases API to find the latest release and binary. By default, this will also update any installed plugins. Uses mise's GitHub token resolution chain for authenticated requests.

Packagers can disable this command so that mise is updated through the package manager instead. See <https://mise.jdx.dev/contributing.html#packaging-and-self-update-instructions>

## Arguments [​](#arguments)

- **`[VERSION]`** — Update to a specific version

## Flags [​](#flags)

- **`-f --force`** — Update even if already up to date
- **`-y --yes`** — Skip confirmation prompt
- **`--no-plugins`** — Disable auto-updating plugins
- **`-h --help`** — Print help

## Related documentation [​](#related-documentation)

- [Installing and updating mise](https://mise.jdx.dev/installing-mise.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/self-update.md)

Last updated:

Pager

[Previous pagemise search](https://mise.jdx.dev/cli/search.html)

[Next pagemise set](https://mise.jdx.dev/cli/set.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)