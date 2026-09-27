mise config

config` [​](#mise-config)

- **Usage:** `mise config [FLAGS] [SUBCOMMAND]`
- **Aliases:** `cfg`, `toml`
- **Effect:** read-only
- **Source code:** [`src/cli/config/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/config/mod.rs)

Manage config files

## Flags [​](#flags)

- **`--truncate`** — Truncate long terminal output to fit the available width

  **Default:** `true`
- **`-J --json`** — Output in JSON format
- **`--no-header`** — Do not print table header
- **`--tracked-configs`** — List all tracked config files
- **`-h --help`** — Print help

## Subcommands [​](#subcommands)

- [`mise config get [FLAGS] [KEY]`](https://mise.jdx.dev/cli/config/get.html)
- [`mise config ls [FLAGS]`](https://mise.jdx.dev/cli/config/ls.html)
- [`mise config set [FLAGS] <KEY> [VALUE]`](https://mise.jdx.dev/cli/config/set.html)

## Related documentation [​](#related-documentation)

- [Configuration](https://mise.jdx.dev/configuration.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/config.md)

Last updated:

Pager

[Previous pagemise completion](https://mise.jdx.dev/cli/completion.html)

[Next pagemise config get](https://mise.jdx.dev/cli/config/get.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)