mise trust

trust` [​](#mise-trust)

- **Usage:** `mise trust [FLAGS] [CONFIG_FILE]`
- **Effect:** modifies state
- **Source code:** [`src/cli/trust.rs`](https://github.com/jdx/mise/blob/main/src/cli/trust.rs)

Mark a config file as trusted

This means mise is allowed to parse the file when it needs to read config that may execute code or affect the environment. Without trust, mise may prompt, skip the config in some discovery paths, or fail with an untrusted-config error when it cannot prompt.

In normal mode, commands that execute project-defined behavior (`mise run`, naked task invocations such as `mise <TASK>`, `mise install`, `mise exec`, and `mise watch`) automatically trust their active config. Paranoid mode requires explicit, content-bound trust for every non-global config.

In normal mode, safe config files do not require trust: files that only contain `min_version`, `[tools]` entries with plain version strings (or arrays of them), and `[tasks]` without templates or tool options.

Trust is shared across git worktrees: a config file inside a linked worktree is trusted when the equivalent path in the repository's main checkout has been trusted. Paranoid mode disables this sharing since worktrees can check out branches with different config contents.

## Arguments [​](#arguments)

- **`[CONFIG_FILE]`** — The config file whose trust status to change

## Flags [​](#flags)

- **`-a --all`** — Trust all config files in the current directory, its parents, and its subdirectories

  Subdirectories are walked respecting .gitignore, skipping hidden directories and common build/dependency directories (node\_modules, vendor, target, dist, build).
- **`--ignore`** — Do not trust this config and ignore it in the future
- **`--show`** — Show the trusted status of config files from the current directory and its parents. Does not trust or untrust any files.
- **`--untrust`** — Remove explicit trust for this config
- **`-h --help`** — Print help

## Examples [​](#examples)

trusts \~/some\_dir/mise.toml

```
mise trust ~/some_dir/mise.toml
```

trusts mise.toml in the current or parent directory

```
mise trust
```

## Related documentation [​](#related-documentation)

- [Configuration trust](https://mise.jdx.dev/security.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/trust.md)

Last updated:

Pager

[Previous pagemise tool-stub](https://mise.jdx.dev/cli/tool-stub.html)

[Next pagemise uninstall](https://mise.jdx.dev/cli/uninstall.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)