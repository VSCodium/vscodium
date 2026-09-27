mise tool

tool` [​](#mise-tool)

- **Usage:** `mise tool [FLAGS] <TOOL>`
- **Effect:** read-only
- **Source code:** [`src/cli/tool.rs`](https://github.com/jdx/mise/blob/main/src/cli/tool.rs)

Show information about a tool

## Arguments [​](#arguments)

- **`<TOOL>`** — Tool name to get information about

## Flags [​](#flags)

- **`-J --json`** — Output in JSON format
- **`--active`** — Only show active versions
- **`--backend`** — Only show backend field
- **`--config-source`** — Only show config source
- **`--description`** — Only show description field
- **`--installed`** — Only show installed versions
- **`--requested`** — Only show requested versions
- **`--tool-options`** — Only show tool options
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise tool node
Backend:            core
Installed Versions: 20.0.0 22.0.0
Active Version:     20.0.0
Requested Version:  20
Config Source:      ~/.config/mise/mise.toml
Tool Options:       [none]
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/tool.md)

Last updated:

Pager

[Previous pagemise token gitlab](https://mise.jdx.dev/cli/token/gitlab.html)

[Next pagemise tool-alias](https://mise.jdx.dev/cli/tool-alias.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)