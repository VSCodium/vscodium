mise deps

deps` [​](#mise-deps)

- **Usage:** `mise deps [FLAGS] [PROVIDER] [SUBCOMMAND]`
- **Aliases:** `dep`, `prepare`
- **Effect:** modifies state
- **Source code:** [`src/cli/deps/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/deps/mod.rs)

\[experimental] Manage project dependencies

With no subcommand, runs dependency installation for the current project, the same as `mise deps install`. Providers detect their inputs and installed outputs to decide whether work is needed; use `--explain PROVIDER` to inspect that decision.

Providers with `auto = true` run before `mise exec` and `mise run` unless `--no-deps` is passed. These install project dependencies, such as node\_modules, separately from versioned tools managed by `mise install`.

## Arguments [​](#arguments)

- **`[PROVIDER]`** — Provider to operate on (runs only this provider, or use with --explain)

## Flags [​](#flags)

- **`--explain`** — Show why a provider is fresh or stale (requires a provider argument)
- **`-f --force`** — Force run all deps steps even if outputs are fresh
- **`-n --dry-run`** — Only check if deps install is needed, don't run commands
- **`--list`** — Show what deps providers are available
- **`--monorepo`** — Install dependencies from every \[monorepo].config\_roots config root

  Requires monorepo\_root = true plus explicit \[monorepo].config\_roots in the monorepo root config. Providers are named like //apps/api:uv.

  **Environment Variable:** `MISE_MONOREPO`
- **`--only <ONLY>`** — Run specific deps rule(s) only
- **`--skip <SKIP>`** — Skip specific deps rule(s)
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise deps                    # Install all project dependencies
mise deps install            # Same as bare `mise deps`
mise deps install --force    # Force reinstall even if fresh
mise deps install --dry-run  # Show what would run
mise deps --monorepo         # Install deps from explicit monorepo config roots
mise deps add npm:react      # Add a dependency
mise deps add -D npm:vitest  # Add a dev dependency
mise deps remove npm:lodash  # Remove a dependency
```

## Subcommands [​](#subcommands)

- [`mise deps add [-D --dev] <PACKAGES>…`](https://mise.jdx.dev/cli/deps/add.html)
- [`mise deps install [FLAGS] [PROVIDER]`](https://mise.jdx.dev/cli/deps/install.html)
- [`mise deps remove <PACKAGES>…`](https://mise.jdx.dev/cli/deps/remove.html)

Configuration:

toml

```
# Built-in npm provider (auto-detects lockfile)
[deps.npm]
auto = true              # Auto-run before mise x/run

# Custom provider
[deps.codegen]
auto = true
sources = ["schema/*.graphql"]
outputs = ["src/generated/"]
run = "npm run codegen"

# To disable npm instead, add `disable = ["npm"]` under [deps].
```

## Related documentation [​](#related-documentation)

- [Project dependencies](https://mise.jdx.dev/dev-tools/deps.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/deps.md)

Last updated:

Pager

[Previous pagemise deactivate](https://mise.jdx.dev/cli/deactivate.html)

[Next pagemise deps add](https://mise.jdx.dev/cli/deps/add.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)