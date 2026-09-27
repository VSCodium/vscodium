mise prune

prune` [​](#mise-prune)

- **Usage:** `mise prune [FLAGS] [INSTALLED_TOOL]…`
- **Effect:** destructive — may delete or irreversibly overwrite
- **Source code:** [`src/cli/prune.rs`](https://github.com/jdx/mise/blob/main/src/cli/prune.rs)

Delete unused versions of tools

mise tracks which config files have been used in \~/.local/state/mise/tracked-configs Versions which are no longer the latest specified in any of those configs are deleted. Versions installed only with environment variables `MISE_<TOOL>_VERSION` will be deleted, as will versions only referenced on the command line `mise exec <TOOL>@<VERSION>`.

Tool stubs that have been executed are tracked in \~/.local/state/mise/tracked-stubs. Versions still referenced by a tracked stub are not deleted.

You can list prunable tools with `mise ls --prunable`

## Arguments [​](#arguments)

- **`[INSTALLED_TOOL]…`** — Prune only these tools

## Flags [​](#flags)

- **`-n --dry-run`** — Do not actually delete anything
- **`--configs`** — Prune only tracked and trusted configuration links that point to nonexistent configurations
- **`--dry-run-code`** — Like --dry-run but exits with code 1 if there are tools to prune

  This is useful for scripts to check if tools need to be pruned.
- **`--monorepo`** — Placeholder for future monorepo pruning; `mise prune --monorepo` is not implemented yet.
- **`--tools`** — Prune only unused versions of tools
- **`-h --help`** — Print help

## Examples [​](#examples)

Preview unused versions without deleting them. Example output: `rm -rf ~/.local/share/mise/installs/node/20.0.0` and `rm -rf ~/.local/share/mise/installs/node/20.0.1`.

```
mise prune --dry-run
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/prune.md)

Last updated:

Pager

[Previous pagemise plugins update](https://mise.jdx.dev/cli/plugins/update.html)

[Next pagemise registry](https://mise.jdx.dev/cli/registry.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)