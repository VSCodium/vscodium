mise where

where` [​](#mise-where)

- **Usage:** `mise where <TOOL@VERSION>`
- **Effect:** read-only
- **Source code:** [`src/cli/where.rs`](https://github.com/jdx/mise/blob/main/src/cli/where.rs)

Display the installation path for a tool

The tool must be installed for this to work.

## Arguments [​](#arguments)

- **`<TOOL@VERSION>`** — Tool to look up e.g.: ruby@3 With "@\<PREFIX>", shows the latest installed version matching the prefix. Otherwise, shows the current, active installed version.

## Flags [​](#flags)

- **`-h --help`** — Print help

## Examples [​](#examples)

Show the latest installed node 20.x Errors if no matching version is installed

```
mise where node@20
/home/jdx/.local/share/mise/installs/node/20.0.0
```

Show the install directory of the active node, or of the latest installed version if no config requests node Errors if no matching version is installed

```
mise where node
/home/jdx/.local/share/mise/installs/node/20.0.0
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/where.md)

Last updated:

Pager

[Previous pagemise watch](https://mise.jdx.dev/cli/watch.html)

[Next pagemise which](https://mise.jdx.dev/cli/which.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)