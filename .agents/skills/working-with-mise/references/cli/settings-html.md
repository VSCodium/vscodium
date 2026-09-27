mise settings

settings` [​](#mise-settings)

- **Usage:** `mise settings [FLAGS] [SETTING] [VALUE] [SUBCOMMAND]`
- **Effect:** modifies state
- **Source code:** [`src/cli/settings/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/settings/mod.rs)

Manage settings

## Arguments [​](#arguments)

- **`[SETTING]`** — Name of setting
- **`[VALUE]`** — Setting value to set

## Global Flags [​](#global-flags)

- **`-l --local`** — Use the local config file instead of the global one

## Flags [​](#flags)

- **`-a --all`** — List all settings
- **`-J --json`** — Output in JSON format
- **`-T --toml`** — Output in TOML format
- **`--json-extended`** — Output in JSON format with sources
- **`-h --help`** — Print help

## Examples [​](#examples)

list explicitly configured settings

```
mise settings
```

get the value of the setting "always\_keep\_download"

```
mise settings always_keep_download
```

set the value of the setting "always\_keep\_download" to "true"

```
mise settings always_keep_download=true
```

set the value of the setting "node.mirror\_url" to " <https://npmmirror.com/mirrors/node/>"

```
mise settings node.mirror_url https://npmmirror.com/mirrors/node/
```

## Subcommands [​](#subcommands)

- [`mise settings add [-l --local] <SETTING> [VALUE]`](https://mise.jdx.dev/cli/settings/add.html)
- [`mise settings get [-l --local] <SETTING>`](https://mise.jdx.dev/cli/settings/get.html)
- [`mise settings ls [FLAGS] [SETTING]`](https://mise.jdx.dev/cli/settings/ls.html)
- [`mise settings set [-l --local] <SETTING> [VALUE]`](https://mise.jdx.dev/cli/settings/set.html)
- [`mise settings unset [-l --local] <KEY>`](https://mise.jdx.dev/cli/settings/unset.html)

## Related documentation [​](#related-documentation)

- [Settings reference](https://mise.jdx.dev/configuration/settings.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/settings.md)

Last updated:

Pager

[Previous pagemise set](https://mise.jdx.dev/cli/set.html)

[Next pagemise settings add](https://mise.jdx.dev/cli/settings/add.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)