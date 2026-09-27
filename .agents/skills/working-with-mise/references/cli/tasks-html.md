mise tasks

tasks` [​](#mise-tasks)

- **Usage:** `mise tasks [FLAGS] [TASK] [SUBCOMMAND]`
- **Aliases:** `t`, `task`
- **Effect:** read-only
- **Source code:** [`src/cli/tasks/mod.rs`](https://github.com/jdx/mise/blob/main/src/cli/tasks/mod.rs)

Manage tasks

## Arguments [​](#arguments)

- **`[TASK]`** — Task name to show info for

## Flags [​](#flags)

- **`-g --global`** — Only show global tasks
- **`-J --json`** — Output in JSON format
- **`-l --local`** — Only show non-global tasks
- **`-x --extended`** — Show all columns
- **`--all`** — Load all tasks from the entire monorepo, including sibling directories. By default, only tasks from the current directory hierarchy are loaded.
- **`--hidden`** — Show hidden tasks
- **`--name-only`** — Only show task names, one per line. Useful for piping to fzf and similar tools.
- **`--no-header`** — Do not print table header
- **`--sort <COLUMN>`** — Sort by column. Default is name.

  **Choices:** `name`, `alias`, `description`, `source`
- **`--sort-order <SORT_ORDER>`** — Sort order. Default is asc.

  **Choices:** `asc`, `desc`
- **`-h --help`** — Print help

## Subcommands [​](#subcommands)

- [`mise tasks add [FLAGS] <TASK> [-- RUN]…`](https://mise.jdx.dev/cli/tasks/add.html)
- [`mise tasks deps [FLAGS] [TASKS]…`](https://mise.jdx.dev/cli/tasks/deps.html)
- [`mise tasks edit [-p --path] <TASK>`](https://mise.jdx.dev/cli/tasks/edit.html)
- [`mise tasks graph [FLAGS]`](https://mise.jdx.dev/cli/tasks/graph.html)
- [`mise tasks info [-J --json] <TASK>`](https://mise.jdx.dev/cli/tasks/info.html)
- [`mise tasks ls [FLAGS]`](https://mise.jdx.dev/cli/tasks/ls.html)
- [`mise tasks run [FLAGS] [TASK] [ARGS]…`](https://mise.jdx.dev/cli/tasks/run.html)
- [`mise tasks validate [--errors-only] [--json] [TASKS]…`](https://mise.jdx.dev/cli/tasks/validate.html)

## Related documentation [​](#related-documentation)

- [Task configuration](https://mise.jdx.dev/tasks/task-configuration.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/tasks.md)

Last updated:

Pager

[Previous pagemise sync ruby](https://mise.jdx.dev/cli/sync/ruby.html)

[Next pagemise tasks add](https://mise.jdx.dev/cli/tasks/add.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)