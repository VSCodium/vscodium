mise edit

edit` [​](#mise-edit)

- **Usage:** `mise edit [FLAGS] [PATH]`
- **Effect:** modifies state
- **Source code:** [`src/cli/edit.rs`](https://github.com/jdx/mise/blob/main/src/cli/edit.rs)

Edit mise.toml interactively

## Arguments [​](#arguments)

- **`[PATH]`** — Path to the config file to create

## Flags [​](#flags)

- **`-g --global`** — Edit the global config file (\~/.config/mise/config.toml)
- **`-n --dry-run`** — Show what would be generated without writing to file
- **`-t --tool-versions <TOOL_VERSIONS>`** — Path to a .tool-versions file to import tools from
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise edit             # edit mise.toml interactively
mise edit .mise.toml  # edit a specific file
mise edit -g          # edit the global config file
mise edit -y          # skip interactive editor
mise edit -n          # preview without writing
```

## Related documentation [​](#related-documentation)

- [Configuration](https://mise.jdx.dev/configuration.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/edit.md)

Last updated:

Pager

[Previous pagemise dotfiles watch](https://mise.jdx.dev/cli/dotfiles/watch.html)

[Next pagemise en](https://mise.jdx.dev/cli/en.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)