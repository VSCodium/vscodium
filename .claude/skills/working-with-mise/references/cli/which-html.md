mise which

which` [​](#mise-which)

- **Usage:** `mise which [FLAGS] [BIN_NAME]`
- **Effect:** read-only
- **Source code:** [`src/cli/which.rs`](https://github.com/jdx/mise/blob/main/src/cli/which.rs)

Show the path a tool's executable resolves to

Use this to figure out what version of a tool is currently active.

## Arguments [​](#arguments)

- **`[BIN_NAME]`** — The executable to look up

## Flags [​](#flags)

- **`-t --tool <TOOL@VERSION>`** — Use a specific tool@version e.g.: `mise which npm --tool=node@20`
- **`--plugin`** — Show the plugin name instead of the path
- **`--version`** — Show the version instead of the path
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise which node
/home/username/.local/share/mise/installs/node/20.0.0/bin/node
```

```
mise which node --plugin
node
```

```
mise which node --version
20.0.0
```

## Related documentation [​](#related-documentation)

- [Shims and executable lookup](https://mise.jdx.dev/dev-tools/shims.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/which.md)

Last updated:

Pager

[Previous pagemise where](https://mise.jdx.dev/cli/where.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)