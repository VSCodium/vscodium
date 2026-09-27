mise unset

unset` [​](#mise-unset)

- **Usage:** `mise unset [-f --file <FILE>] [-g --global] [ENV_KEY]…`
- **Effect:** modifies state
- **Source code:** [`src/cli/unset.rs`](https://github.com/jdx/mise/blob/main/src/cli/unset.rs)

Remove environment variable(s) from the config file

By default, this command selects the nearest configuration directory and modifies its lowest-precedence TOML file, creating `mise.toml` here if none exists.

## Arguments [​](#arguments)

- **`[ENV_KEY]…`** — Environment variable(s) to remove e.g.: NODE\_ENV

## Flags [​](#flags)

- **`-f --file <FILE>`** — Specify a file to use instead of `mise.toml`

  Can be a file path or directory. If a directory is provided, will create/use mise.toml in that directory.

  Defaults to [`MISE_DEFAULT_CONFIG_FILENAME`](https://mise.jdx.dev/configuration.html#mise_default_config_filename) environment variable, or `mise.toml`. Use [`MISE_GLOBAL_CONFIG_FILE`](https://mise.jdx.dev/configuration.html#mise_global_config_file) to choose a different global config path.

  **Aliases:** `--path`
- **`-g --global`** — Use the global config file
- **`-h --help`** — Print help

## Examples [​](#examples)

Remove NODE\_ENV from the selected project config

```
mise unset NODE_ENV
```

Remove NODE\_ENV from the global config

```
mise unset NODE_ENV -g
```

## Related documentation [​](#related-documentation)

- [Environment variables](https://mise.jdx.dev/environments/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/unset.md)

Last updated:

Pager

[Previous pagemise uninstall](https://mise.jdx.dev/cli/uninstall.html)

[Next pagemise untrust](https://mise.jdx.dev/cli/untrust.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)