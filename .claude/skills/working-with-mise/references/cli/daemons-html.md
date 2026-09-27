mise daemons

daemons` [​](#mise-daemons)

- **Usage:** `mise daemons [--json] [SUBCOMMAND]`
- **Aliases:** `daemon`
- **Effect:** read-only
- **Source code:** [`src/cli/daemons.rs`](https://github.com/jdx/mise/blob/main/src/cli/daemons.rs)

\[experimental] Manage project daemons with pitchfork

Define commands or managed service presets in \[daemons]: cockroachdb, nats, postgres, redis, spicedb. With no subcommand, list configured and previously managed daemons.

## Flags [​](#flags)

- **`--json`**
- **`-h --help`** — Print help

## Subcommands [​](#subcommands)

- [`mise daemons logs [ARGS]…`](https://mise.jdx.dev/cli/daemons/logs.html)
- [`mise daemons ls [--json]`](https://mise.jdx.dev/cli/daemons/ls.html)
- [`mise daemons prune [-n --dry-run]`](https://mise.jdx.dev/cli/daemons/prune.html)
- [`mise daemons register`](https://mise.jdx.dev/cli/daemons/register.html)
- [`mise daemons restart [ARGS]…`](https://mise.jdx.dev/cli/daemons/restart.html)
- [`mise daemons start [ARGS]…`](https://mise.jdx.dev/cli/daemons/start.html)
- [`mise daemons status [ARGS]…`](https://mise.jdx.dev/cli/daemons/status.html)
- [`mise daemons stop [ARGS]…`](https://mise.jdx.dev/cli/daemons/stop.html)
- [`mise daemons tui [ARGS]…`](https://mise.jdx.dev/cli/daemons/tui.html)
- [`mise daemons urls [--json]`](https://mise.jdx.dev/cli/daemons/urls.html)

## Related documentation [​](#related-documentation)

- [Getting started](https://mise.jdx.dev/getting-started.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/daemons.md)

Last updated:

Pager

[Previous pagemise config set](https://mise.jdx.dev/cli/config/set.html)

[Next pagemise daemons logs](https://mise.jdx.dev/cli/daemons/logs.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)