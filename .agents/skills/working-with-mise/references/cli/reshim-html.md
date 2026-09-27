mise reshim

reshim` [​](#mise-reshim)

- **Usage:** `mise reshim [-f --force] [--system]`
- **Effect:** modifies state
- **Source code:** [`src/cli/reshim.rs`](https://github.com/jdx/mise/blob/main/src/cli/reshim.rs)

Create shims for executables provided by installed tools

Run this when an executable was added to an existing installation outside mise, for example after a language package manager installed a CLI globally. It rebuilds the user shim directory by default; `--system` selects the shared system shim farm.

Shims are created for all installed versions. The shim resolves which version to run from the current configuration when invoked. `--force` rebuilds mise-owned shims; it does not turn unrelated files into mise-owned shims.

## Flags [​](#flags)

- **`-f --force`** — Rebuild all mise-owned shims
- **`--system`** — Rebuild the system shim farm
- **`-h --help`** — Print help

## Examples [​](#examples)

Rebuild shims, then check node. Example output: `v20.0.0`.

```
mise reshim
~/.local/share/mise/shims/node -v
```

## Related documentation [​](#related-documentation)

- [Shims](https://mise.jdx.dev/dev-tools/shims.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/reshim.md)

Last updated:

Pager

[Previous pagemise registry](https://mise.jdx.dev/cli/registry.html)

[Next pagemise run](https://mise.jdx.dev/cli/run.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)