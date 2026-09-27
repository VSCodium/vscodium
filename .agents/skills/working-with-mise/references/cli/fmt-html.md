mise fmt

fmt` [​](#mise-fmt)

- **Usage:** `mise fmt [FLAGS]`
- **Effect:** modifies state
- **Source code:** [`src/cli/fmt.rs`](https://github.com/jdx/mise/blob/main/src/cli/fmt.rs)

Format mise TOML configuration

Sorts keys and normalizes whitespace using TOML 1.1 syntax, including multiline inline tables. Lists whose order carries no meaning are sorted as well: task `sources` and `outputs`, `task_config.global_inputs` and `input_groups`, and `redactions`. File pattern lists sort by reach — `@group:` references, then globs, then literal paths — and a list is left as written when an entry excludes with `!` or carries a comment. By default, formats config files in the current directory; `--all` includes every loaded config. Use `--check` in CI or `--stdin` to format a supplied document without rewriting a file.

## Flags [​](#flags)

- **`-a --all`** — Format every config file mise currently loads, not just those in the current directory
- **`-c --check`** — Check whether the configs are formatted without rewriting them; exits 1 if any are not
- **`-s --stdin`** — Read config from stdin and write its formatted version into stdout
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise fmt
mise fmt --check
cat mise.toml | mise fmt --stdin
```

## Related documentation [​](#related-documentation)

- [Configuration](https://mise.jdx.dev/configuration.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/fmt.md)

Last updated:

Pager

[Previous pagemise exec](https://mise.jdx.dev/cli/exec.html)

[Next pagemise generate](https://mise.jdx.dev/cli/generate.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)