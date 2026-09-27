---
title: "mise alias | mise-en-place"
meta:
  description: "mise-en-place documentation"
---

# `mise alias` [​](#mise-alias)

- **Usage**: `mise alias [-p --plugin <PLUGIN>] [--no-header] <SUBCOMMAND>`
- **Aliases**: `a`
- **Source code**: [`src/cli/alias/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/alias/mod.rs)

Manage version aliases.

## Flags [​](#flags)

### `-p --plugin <PLUGIN>` [​](#p-plugin-plugin)

filter aliases by plugin

### `--no-header` [​](#no-header)

Don't show table header

## Subcommands [​](#subcommands)

- [`mise alias get <PLUGIN> <ALIAS>`](https://mise.jdx.dev/cli/alias/get.html)
- [`mise alias ls \[--no-header\] \[TOOL\]`](https://mise.jdx.dev/cli/alias/ls.html)
- [`mise alias set <ARGS>…`](https://mise.jdx.dev/cli/alias/set.html)
- [`mise alias unset <PLUGIN> \[ALIAS\]`](https://mise.jdx.dev/cli/alias/unset.html)