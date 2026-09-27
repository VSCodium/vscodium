mise install-into

install-into` [​](#mise-install-into)

- **Usage:** `mise install-into <TOOL@VERSION> <PATH>`
- **Effect:** modifies state
- **Source code:** [`src/cli/install_into.rs`](https://github.com/jdx/mise/blob/main/src/cli/install_into.rs)

Install a tool version to a specific path

Used for building a tool to a directory for use outside of mise

## Arguments [​](#arguments)

- **`<TOOL@VERSION>`** — Tool to install e.g.: node@20
- **`<PATH>`** — Path to install the tool into

## Flags [​](#flags)

- **`-h --help`** — Print help

## Examples [​](#examples)

install node@20.0.0 into ./mynode

```
mise install-into node@20.0.0 ./mynode && ./mynode/bin/node -v
v20.0.0
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/install-into.md)

Last updated:

Pager

[Previous pagemise install](https://mise.jdx.dev/cli/install.html)

[Next pagemise latest](https://mise.jdx.dev/cli/latest.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)