mise registry

registry` [​](#mise-registry)

- **Usage:** `mise registry [FLAGS] [NAME]`
- **Effect:** read-only
- **Source code:** [`src/cli/registry.rs`](https://github.com/jdx/mise/blob/main/src/cli/registry.rs)

List registry shorthand names and their backends

The registry maps short names to installation backends. For example, `node` uses the built-in Node backend. A tool may have multiple candidates; explicit backend syntax and configuration can override registry selection.

This is not a list of every tool mise can install. Use an explicit identifier such as `github:owner/repo` for a supported source without a registry shorthand.

## Arguments [​](#arguments)

- **`[NAME]`** — Show only the specified tool's full name

## Flags [​](#flags)

- **`-b --backend <BACKEND>`** — Show only tools for this backend
- **`--hide-aliased`** — Hide aliased tools
- **`-J --json`** — Output in JSON format
- **`--security`** — Include security features for each tool's backends in JSON output

  Requires --json. Security info is de-duplicated across all of a tool's backends. This can add noticeable time for large listings since each backend's security info is resolved individually.
- **`-h --help`** — Print help

## Examples [​](#examples)

List the registry, then inspect node. The second command prints `core:node`.

```
mise registry
mise registry node
```

```
mise registry --backend aqua
mise registry --json
```

## Related documentation [​](#related-documentation)

- [Registry and explicit backends](https://mise.jdx.dev/registry.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/registry.md)

Last updated:

Pager

[Previous pagemise prune](https://mise.jdx.dev/cli/prune.html)

[Next pagemise reshim](https://mise.jdx.dev/cli/reshim.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)