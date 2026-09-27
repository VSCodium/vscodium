mise shell

shell` [​](#mise-shell)

- **Usage:** `mise shell [FLAGS] <TOOL@VERSION>…`
- **Aliases:** `sh`
- **Effect:** read-only
- **Source code:** [`src/cli/shell.rs`](https://github.com/jdx/mise/blob/main/src/cli/shell.rs)

Set a tool version for the current shell session

Only works in a session where mise is already activated.

This works by setting environment variables for the current shell session such as `MISE_NODE_VERSION=20` which is "eval"ed as a shell function created by `mise activate`.

## Arguments [​](#arguments)

- **`<TOOL@VERSION>…`** — Tool(s) to use

## Flags [​](#flags)

- **`-j --jobs <JOBS>`** — Number of jobs to run in parallel Values below 1 are treated as 1 Defaults to the `jobs` setting

  **Environment Variable:** `MISE_JOBS`
- **`-u --unset`** — Remove a previously set version
- **`--raw`** — Connect backend install command stdin/stdout/stderr directly to the terminal. Implies `--jobs=1`
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise shell node@20
node -v
v20.0.0
```

## Related documentation [​](#related-documentation)

- [Shell activation](https://mise.jdx.dev/getting-started.html#activate-mise).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/shell.md)

Last updated:

Pager

[Previous pagemise settings unset](https://mise.jdx.dev/cli/settings/unset.html)

[Next pagemise shell-alias](https://mise.jdx.dev/cli/shell-alias.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)