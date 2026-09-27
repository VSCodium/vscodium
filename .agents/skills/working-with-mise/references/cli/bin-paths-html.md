mise bin-paths

bin-paths` [​](#mise-bin-paths)

- **Usage:** `mise bin-paths [--bin-names] [-J --json] [TOOL@VERSION]…`
- **Effect:** read-only
- **Source code:** [`src/cli/bin_paths.rs`](https://github.com/jdx/mise/blob/main/src/cli/bin_paths.rs)

List all the active runtime bin paths

## Arguments [​](#arguments)

- **`[TOOL@VERSION]…`** — Tool(s) to look up e.g.: ruby@3

## Flags [​](#flags)

- **`--bin-names`** — Output executable names instead of bin directories
- **`-J --json`** — Output executable entries in JSON format (implies --bin-names)
- **`-h --help`** — Print help

## Related documentation [​](#related-documentation)

- [Shims and executable lookup](https://mise.jdx.dev/dev-tools/shims.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/bin-paths.md)

Last updated:

Pager

[Previous pagemise backends ls](https://mise.jdx.dev/cli/backends/ls.html)

[Next pagemise bootstrap](https://mise.jdx.dev/cli/bootstrap.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)