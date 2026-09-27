mise activate

activate` [​](#mise-activate)

- **Usage:** `mise activate [FLAGS] [SHELL_TYPE]`
- **Effect:** read-only
- **Source code:** [`src/cli/activate.rs`](https://github.com/jdx/mise/blob/main/src/cli/activate.rs)

Print the script to activate mise in an interactive shell

Evaluate this command's output with the syntax for your shell; running it alone only prints the script. Activation updates tools and environment variables as this shell changes directories.

Add the appropriate example below once to your interactive startup file: \~/.bashrc for Bash, \~/.zshrc for Zsh, \~/.config/fish/config.fish for Fish, or $PROFILE for PowerShell. See the getting-started guide for other shells.

The mise executable must be on PATH before that line runs. Otherwise use its absolute path, for example `eval "$(~/.local/bin/mise activate zsh)"`.

Use `mise exec -- command` for scripts and CI that do not need interactive hooks. Customize status output with the `status` settings.

## Arguments [​](#arguments)

- **`[SHELL_TYPE]`** — Shell type to generate the script for

  **Choices:** `bash`, `elvish`, `fish`, `nu`, `xonsh`, `zsh`, `pwsh`, `powershell`

## Flags [​](#flags)

- **`-q --quiet`** — Suppress non-error messages
- **`--no-hook-env`** — Do not automatically call hook-env

  This can be helpful for debugging mise. If you run `eval "$(mise activate --no-hook-env)"`, then you can call `mise hook-env` manually which will output the env vars to stdout without actually modifying the environment. That way you can do things like `mise hook-env --trace` to get more information or just see the values that hook-env is outputting.
- **`--shims`** — Use shims instead of modifying PATH

  Effectively the same as:

  ```
  PATH="$HOME/.local/share/mise/shims:$PATH"
  ```

  `mise activate --shims` does not support all the features of `mise activate`. See <https://mise.jdx.dev/dev-tools/shims.html#shims-vs-path> for more information
- **`-h --help`** — Print help

## Examples [​](#examples)

Activate mise in Bash.

```
eval "$(mise activate bash)"
```

Activate mise in Zsh.

```
eval "$(mise activate zsh)"
```

Activate mise in Fish.

```
mise activate fish | source
```

Activate mise in Xonsh.

```
execx($(mise activate xonsh))
```

Activate mise in PowerShell.

```
(&mise activate pwsh) | Out-String | Invoke-Expression
```

## Related documentation [​](#related-documentation)

- [Shell activation](https://mise.jdx.dev/getting-started.html#activate-mise).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/activate.md)

Last updated:

Pager

[Previous pageCLI Overview](https://mise.jdx.dev/cli/)

[Next pagemise backends](https://mise.jdx.dev/cli/backends.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)