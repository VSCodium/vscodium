mise ls

ls` [​](#mise-ls)

- **Usage:** `mise ls [FLAGS] [INSTALLED_TOOL]…`
- **Aliases:** `list`
- **Effect:** read-only
- **Source code:** [`src/cli/ls.rs`](https://github.com/jdx/mise/blob/main/src/cli/ls.rs)

List installed and active tool versions

Lists the tools mise knows about: versions that are installed, and versions requested by a config file (active) whether or not they are installed.

## Arguments [​](#arguments)

- **`[INSTALLED_TOOL]…`** — Only show tool versions from \[TOOL]

## Flags [​](#flags)

- **`--truncate`** — Truncate long terminal output to fit the available width

  **Default:** `true`
- **`-c --current`** — Only show tool versions currently specified in a mise.toml
- **`-g --global`** — Only show tool versions currently specified in the global mise.toml
- **`-i --installed`** — Only show tool versions that are installed (Hides tools defined in mise.toml but not installed)
- **`-J --json`** — Output in JSON format
- **`-l --local`** — Only show tool versions currently specified in the local mise.toml
- **`-m --missing`** — Display missing tool versions
- **`--all-sources`** — Display all tracked config sources for tools
- **`--monorepo`** — List tools from every \[monorepo].config\_roots config root

  Uses the active MISE\_ENV and requires monorepo\_root = true plus explicit \[monorepo].config\_roots in the monorepo root config.

  **Environment Variable:** `MISE_MONOREPO`
- **`--no-header`** — Don't display headers
- **`--outdated`** — Display whether a version is outdated
- **`--prefix <PREFIX>`** — Display versions matching this prefix
- **`--prunable`** — List only tools that can be pruned with `mise prune`
- **`-h --help`** — Print help

## Examples [​](#examples)

Show installed versions and requests from active configuration

```
mise ls
```

Show only versions requested by the current configuration

```
mise ls --current
```

Find configured versions that need installation

```
mise ls --missing
```

Machine-readable output: an object keyed by tool name

```
mise ls --json
```

With a tool argument, JSON output is an array of its version records

```
mise ls node --json
```

Include references from every tracked configuration file

```
mise ls --all-sources
```

## Related documentation [​](#related-documentation)

- [Development tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/ls.md)

Last updated:

Pager

[Previous pagemise lock](https://mise.jdx.dev/cli/lock.html)

[Next pagemise ls-remote](https://mise.jdx.dev/cli/ls-remote.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)