mise en

en` [​](#mise-en)

- **Usage:** `mise en [-s --shell <SHELL>] [DIR]`
- **Source code:** [`src/cli/en.rs`](https://github.com/jdx/mise/blob/main/src/cli/en.rs)

Start a new shell with the mise environment built from the current configuration

This is an alternative to `mise activate` for starting a mise session explicitly. The new shell has the tools and environment variables from the config loaded. Unlike an activated shell, changing directories does not update the environment.

## Arguments [​](#arguments)

- **`[DIR]`** — Directory to start the shell in

  **Default:** `.`

## Flags [​](#flags)

- **`-s --shell <SHELL>`** — Shell to start

  Defaults to $SHELL
- **`-h --help`** — Print help

## Examples [​](#examples)

Start a shell and check node. Example output: `v20.0.0`.

```
mise en .
node -v
```

Skip loading bashrc.

```
mise en -s "bash --norc"
```

Skip loading zshrc.

```
mise en -s "zsh -f"
```

## Related documentation [​](#related-documentation)

- [Shell activation](https://mise.jdx.dev/getting-started.html#activate-mise).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/en.md)

Last updated:

Pager

[Previous pagemise edit](https://mise.jdx.dev/cli/edit.html)

[Next pagemise env](https://mise.jdx.dev/cli/env.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)