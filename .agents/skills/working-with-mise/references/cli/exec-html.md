mise exec

exec` [​](#mise-exec)

- **Usage:** `mise exec [FLAGS] [TOOL@VERSION]… [-- COMMAND]…`
- **Aliases:** `x`
- **Source code:** [`src/cli/exec.rs`](https://github.com/jdx/mise/blob/main/src/cli/exec.rs)

Execute a command with tool(s) set

Use this to run a command with mise's tools and environment without modifying the shell session, or to run ad-hoc commands with tools that are not in the config.

Tools are loaded from mise.toml and can be overridden with \<TOOL@VERSION> args. Only the tools you name are overridden: if `mise.toml` includes `node = "20"` and you run `mise exec python@3.11 -- python -V`, node@20 is still loaded.

The "--" separates tools from the command to pass along to the subprocess.

## Arguments [​](#arguments)

- **`[TOOL@VERSION]…`** — Tool(s) to load e.g.: node@20 python@3.10
- **`[-- COMMAND]…`** — Executable and arguments to run directly, after `--`

## Flags [​](#flags)

- **`-c --command <COMMAND>`** — Command string to execute through a shell (supports pipes and redirection)
- **`-j --jobs <JOBS>`** — Number of jobs to run in parallel Values below 1 are treated as 1 Defaults to the `jobs` setting

  **Environment Variable:** `MISE_JOBS`
- **`--allow-env <VAR>`** — Allow specific env var through (implies --deny-env for everything else) Supports wildcards, e.g. --allow-env='MYAPP\_\*'
- **`--allow-net <HOST>`** — Allow network to specific host (implies --deny-net for everything else) Per-host filtering is unsupported on Linux and returns an error. See the sandboxing guide for current macOS host-filter limitations. On Windows, sandboxing is unavailable: mise warns and runs without host filtering.
- **`--allow-read <PATH>`** — Allow reads from specific path (implies --deny-read for everything else)
- **`--allow-write <PATH>`** — Allow writes to specific path (implies --deny-write for everything else)
- **`--deny-all`** — Block reads, writes, network, and env vars
- **`--deny-env`** — Block env var inheritance except PATH, HOME, USER, SHELL, TERM, COLORTERM, LANG
- **`--deny-net`** — Block all network access
- **`--deny-read`** — Block filesystem reads (system libs and tool dirs still accessible)
- **`--deny-write`** — Block all filesystem writes
- **`--fresh-env`** — Bypass the environment cache and recompute the environment
- **`--no-deps`** — Skip automatic dependency preparation
- **`--raw`** — Connect backend install command stdin/stdout/stderr directly to the terminal. Implies `--jobs=1`
- **`-h --help`** — Print help

## Examples [​](#examples)

Launch app.js using node-20.x, with the full command or its shorter alias.

```
mise exec node@20 -- node ./app.js
mise x node@20 -- node ./app.js
```

Specify command as a string:

```
mise exec node@20 python@3.11 --command "node -v && python -V"
```

Run a command in a different directory:

```
mise x -C /path/to/project node@20 -- node ./app.js
```

## Related documentation [​](#related-documentation)

- [Running tools](https://mise.jdx.dev/dev-tools/).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/exec.md)

Last updated:

Pager

[Previous pagemise env](https://mise.jdx.dev/cli/env.html)

[Next pagemise fmt](https://mise.jdx.dev/cli/fmt.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)