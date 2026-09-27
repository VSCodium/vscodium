mise patrons

patrons` [​](#mise-patrons)

- **Usage:** `mise patrons [-J --json] [--refresh]`
- **Effect:** read-only
- **Source code:** [`src/cli/patrons.rs`](https://github.com/jdx/mise/blob/main/src/cli/patrons.rs)

Show the individuals supporting mise as Patron-tier members

Lists the individuals on the Patron tier from <https://jdx.dev/patrons.json>. The list refreshes daily; supporting terminals will render each patron's name as a clickable link via OSC 8 hyperlinks.

To appear here, become a patron at <https://jdx.dev/sponsors.html>.

## Flags [​](#flags)

- **`-J --json`** — Output in JSON format
- **`--refresh`** — Bypass the local cache and re-fetch
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise patrons
mise patrons -J
mise patrons --refresh
```

## Related documentation [​](#related-documentation)

- [Supporting mise](https://mise.jdx.dev/about.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/patrons.md)

Last updated:

Pager

[Previous pagemise packslip pins](https://mise.jdx.dev/cli/packslip/pins.html)

[Next pagemise plugins](https://mise.jdx.dev/cli/plugins.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)