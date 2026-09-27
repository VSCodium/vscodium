mise uninstall

uninstall` [​](#mise-uninstall)

- **Usage:** `mise uninstall [FLAGS] [INSTALLED_TOOL@VERSION]…`
- **Effect:** destructive — may delete or irreversibly overwrite
- **Source code:** [`src/cli/uninstall.rs`](https://github.com/jdx/mise/blob/main/src/cli/uninstall.rs)

Remove installed tool versions

This only removes the installed version; it does not modify mise.toml. Use `mise unuse` to remove a tool from mise.toml and uninstall it.

## Arguments [​](#arguments)

- **`[INSTALLED_TOOL@VERSION]…`** — Tool(s) to remove

## Flags [​](#flags)

- **`-a --all`** — Delete all installed versions
- **`-n --dry-run`** — Do not actually delete anything
- **`--dry-run-code`** — Like --dry-run but exits with code 1 if there are tools to uninstall

  This is useful for scripts to check if tools need to be uninstalled.
- **`-h --help`** — Print help

## Examples [​](#examples)

uninstall a specific version

```
mise uninstall node@18.0.0
```

uninstall the current node version (if only one version is installed)

```
mise uninstall node
```

uninstall every installed version of node

```
mise uninstall --all node
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/uninstall.md)

Last updated:

Pager

[Previous pagemise trust](https://mise.jdx.dev/cli/trust.html)

[Next pagemise unset](https://mise.jdx.dev/cli/unset.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)