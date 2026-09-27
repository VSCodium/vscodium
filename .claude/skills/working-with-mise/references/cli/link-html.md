mise link

link` [​](#mise-link)

- **Usage:** `mise link [-f --force] <TOOL@VERSION> <PATH>`
- **Aliases:** `ln`
- **Effect:** modifies state
- **Source code:** [`src/cli/link.rs`](https://github.com/jdx/mise/blob/main/src/cli/link.rs)

Symlink a tool version into mise

Use this to register an install that was compiled by hand or built with another tool.

## Arguments [​](#arguments)

- **`<TOOL@VERSION>`** — Tool name and version to create a symlink for
- **`<PATH>`** — The local path to the tool version e.g.: \~/.nvm/versions/node/v20.0.0

## Flags [​](#flags)

- **`-f --force`** — Overwrite an existing tool version if it exists
- **`-h --help`** — Print help

## Examples [​](#examples)

build node-20.0.0 with node-build and link it into mise

```
node-build 20.0.0 ~/.nodes/20.0.0
mise link node@20.0.0 ~/.nodes/20.0.0
```

have mise use the node version provided by Homebrew

```
brew install node
mise link node@brew "$(brew --prefix node)"
mise use node@brew
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/link.md)

Last updated:

Pager

[Previous pagemise latest](https://mise.jdx.dev/cli/latest.html)

[Next pagemise lock](https://mise.jdx.dev/cli/lock.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)