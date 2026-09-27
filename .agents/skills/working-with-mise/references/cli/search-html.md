mise search

search` [​](#mise-search)

- **Usage:** `mise search [FLAGS] [NAME]`
- **Effect:** read-only
- **Source code:** [`src/cli/search.rs`](https://github.com/jdx/mise/blob/main/src/cli/search.rs)

Search for available tools

Searches the registry and installed backend catalogs for tools matching NAME.

By default, it will show all tools that fuzzy match the search term. For non-fuzzy matches, use the `--match-type` flag.

## Arguments [​](#arguments)

- **`[NAME]`** — The tool to search for

## Flags [​](#flags)

- **`-i --interactive`** — Show an interactive search menu
- **`-m --match-type <MATCH_TYPE>`** — Match type: equal, contains, or fuzzy

  **Choices:** `equal`, `contains`, `fuzzy`

  **Default:** `fuzzy`
- **`--no-header`** — Don't display headers
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise search jq
Tool  Description
jq    Command-line JSON processor. https://github.com/jqlang/jq
jqp   A TUI playground to experiment with jq. https://github.com/noahgorstein/jqp
jiq   jid on jq - interactive JSON query tool using jq expressions. https://github.com/fiatjaf/jiq
gojq  Pure Go implementation of jq. https://github.com/itchyny/gojq
```

```
mise search --interactive
Tool
Search a tool
❯ jq    Command-line JSON processor. https://github.com/jqlang/jq
  jqp   A TUI playground to experiment with jq. https://github.com/noahgorstein/jqp
  jiq   jid on jq - interactive JSON query tool using jq expressions. https://github.com/fiatjaf/jiq
  gojq  Pure Go implementation of jq. https://github.com/itchyny/gojq
/jq
esc clear filter • enter confirm
```

## Related documentation [​](#related-documentation)

- [Registry and explicit backends](https://mise.jdx.dev/registry.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/search.md)

Last updated:

Pager

[Previous pagemise run](https://mise.jdx.dev/cli/run.html)

[Next pagemise self-update](https://mise.jdx.dev/cli/self-update.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)