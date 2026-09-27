mise oci

oci` [​](#mise-oci)

- **Usage:** `mise oci <SUBCOMMAND>`
- **Effect:** read-only
- **Source code:** [`src/cli/oci/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/oci/mod.rs)

\[experimental] Build OCI container images from a mise.toml

Each tool becomes its own OCI layer, so bumping any single tool version only invalidates one content-addressable blob — unlike a Dockerfile where changing an early `RUN` invalidates every layer above it.

This command is experimental and requires `mise settings experimental=true` (or `MISE_EXPERIMENTAL=1`). Behavior, flags, and output layout may change in future releases.

## Flags [​](#flags)

- **`-h --help`** — Print help

## Subcommands [​](#subcommands)

- [`mise oci build [FLAGS]`](https://mise.jdx.dev/cli/oci/build.html)
- [`mise oci push [FLAGS] <REF>`](https://mise.jdx.dev/cli/oci/push.html)
- [`mise oci run [FLAGS] [-- CMD]…`](https://mise.jdx.dev/cli/oci/run.html)

## Related documentation [​](#related-documentation)

- [Building and running OCI images](https://mise.jdx.dev/dev-tools/mise-oci.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/oci.md)

Last updated:

Pager

[Previous pagemise mcp](https://mise.jdx.dev/cli/mcp.html)

[Next pagemise oci build](https://mise.jdx.dev/cli/oci/build.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)