mise test-tool

test-tool` [​](#mise-test-tool)

- **Usage:** `mise test-tool [FLAGS] [TOOLS]…`
- **Source code:** [`src/cli/test_tool.rs`](https://github.com/jdx/mise/blob/main/src/cli/test_tool.rs)

Test that a tool installs and runs

Includes newly published releases by disabling the global minimum release age for this command.

## Arguments [​](#arguments)

- **`[TOOLS]…`** — Tool(s) to test

## Flags [​](#flags)

- **`-a --all`** — Test every tool specified in registry/
- **`-j --jobs <JOBS>`** — Number of tool tests to run in parallel Values below 1 are treated as 1 \[default: 4]

  **Environment Variable:** `MISE_TEST_TOOL_JOBS`
- **`--all-config`** — Test all tools specified in config files
- **`--include-non-defined`** — Also test tools not defined in registry/, guessing how to test them
- **`--raw`** — Connect backend install command stdin/stdout/stderr directly to the terminal. Implies `--jobs=1`
- **`-h --help`** — Print help

## Examples [​](#examples)

```
mise test-tool ripgrep
```

## Related documentation [​](#related-documentation)

- [Contributing and registry tests](https://mise.jdx.dev/contributing.html#tool-testing).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/test-tool.md)

Last updated:

Pager

[Previous pagemise tasks validate](https://mise.jdx.dev/cli/tasks/validate.html)

[Next pagemise token](https://mise.jdx.dev/cli/token.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)