mise completion

completion` [​](#mise-completion)

- **Usage:** `mise completion [FLAGS] [SHELL]`
- **Aliases:** `complete`, `completions`
- **Effect:** read-only
- **Source code:** [`src/cli/completion.rs`](https://github.com/jdx/mise/blob/main/src/cli/completion.rs)

Generate shell completions

## Arguments [​](#arguments)

- **`[SHELL]`** — Shell type to generate completions for

  **Choices:** `bash`, `fish`, `powershell`, `zsh`, `pwsh`

## Flags [​](#flags)

- **`--include-bash-completion-lib`** — Retained for compatibility with older completion generators.

  usage-rs's built-in bash script is self-contained, so this is now a no-op.
- **`--install`** — Install the script where this shell looks for it, instead of printing it

  Writes the script file and nothing else: no shell rc file and no PowerShell profile is edited. Where a shell needs a one-time line of its own — zsh's `fpath+=`, PowerShell's dot-source — it is printed for you to add.

  **Effect:** modifies state
- **`--force`** — Replace a file at the target path that mise did not write

  **Effect:** modifies state
- **`--tool <TOOL>`** — A tool's completion instead of mise's own, from the packslip it was installed from

  NAME is a tool installed with the `packslip:` backend, or one of its executables. The script comes from whichever version is active here, from the most verifiable source its packslip offers: a file the vendor shipped, a script derived from its CLI spec, or a command of the tool's own. With --install, what is written is a small stub that asks mise for the script each time the shell completes the tool, so it follows version switches without being rewritten.
- **`-h --help`** — Print help

## Examples [​](#examples)

Install for your shell; follow any printed one-time setup instructions

```
mise completion zsh --install
mise completion bash --install
mise completion fish --install
mise completion powershell --install
```

Print a completion script to inspect or save at a custom path

```
mise completion zsh
```

For a tool installed through Packslip with completion resources

```
mise completion zsh --tool rg
mise completion zsh --tool rg --install
```

## Related documentation [​](#related-documentation)

- [Shell completions](https://mise.jdx.dev/dev-tools/packslip-resources.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/completion.md)

Last updated:

Pager

[Previous pagemise cache task](https://mise.jdx.dev/cli/cache/task.html)

[Next pagemise config](https://mise.jdx.dev/cli/config.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)