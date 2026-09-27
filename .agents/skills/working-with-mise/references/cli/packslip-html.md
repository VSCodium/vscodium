mise packslip

packslip` [​](#mise-packslip)

- **Usage:** `mise packslip [SUBCOMMAND]`
- **Effect:** read-only
- **Source code:** [`src/cli/packslip/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/packslip/mod.rs)

The signers mise accepts packslips from

A tool installed with the `packslip:` backend is verified against the identity its project name implies, and mise then remembers which signer it accepted, the way SSH remembers hosts. A later release from another signer, a weaker scheme, a repackager where the vendor signed before, or one that drops build provenance is refused until a person says so.

## Flags [​](#flags)

- **`-h --help`** — Print help

## Subcommands [​](#subcommands)

- [`mise packslip forget <PROJECT>`](https://mise.jdx.dev/cli/packslip/forget.html)
- [`mise packslip pins [-J --json]`](https://mise.jdx.dev/cli/packslip/pins.html)

## Related documentation [​](#related-documentation)

- [Signer verification](https://mise.jdx.dev/dev-tools/packslip-verification.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/packslip.md)

Last updated:

Pager

[Previous pagemise outdated](https://mise.jdx.dev/cli/outdated.html)

[Next pagemise packslip forget](https://mise.jdx.dev/cli/packslip/forget.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)