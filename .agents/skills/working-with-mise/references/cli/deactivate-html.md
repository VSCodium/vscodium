mise deactivate

deactivate` [​](#mise-deactivate)

- **Usage:** `mise deactivate`
- **Effect:** read-only
- **Source code:** [`src/cli/deactivate.rs`](https://github.com/jdx/mise/blob/main/src/cli/deactivate.rs)

Print the script to disable mise in the current shell session

The shell function installed by activation evaluates this output in supported shells. When calling the executable directly, evaluate or source its output with the appropriate shell syntax. This does not remove the startup-file line; new shells will activate mise again.

## Flags [​](#flags)

- **`-h --help`** — Print help

## Examples [​](#examples)

Bash or Zsh, calling the executable rather than the activation function

```
eval "$(command mise deactivate)"
```

Fish

```
command mise deactivate | source
```

## Related documentation [​](#related-documentation)

- [Shell activation](https://mise.jdx.dev/getting-started.html#activate-mise).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/deactivate.md)

Last updated:

Pager

[Previous pagemise daemons urls](https://mise.jdx.dev/cli/daemons/urls.html)

[Next pagemise deps](https://mise.jdx.dev/cli/deps.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)