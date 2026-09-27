mise tool-stub

tool-stub` [​](#mise-tool-stub)

- **Usage:** `mise tool-stub <FILE> [ARGS]…`
- **Source code:** [`src/cli/tool_stub.rs`](https://github.com/jdx/mise/blob/main/src/cli/tool_stub.rs)

Execute a tool stub

Tool stubs are executable files containing TOML configuration that specify which tool to run and how to run it. They provide a convenient way to create portable, self-contained executables that automatically manage tool installation and execution.

A tool stub consists of:

- A shebang line: #!/usr/bin/env -S mise tool-stub
- TOML configuration specifying the tool, version, and options
- Optional comments describing the tool's purpose

Example stub file:

toml

```
#!/usr/bin/env -S mise tool-stub
# Node.js v20 development environment

tool = "node"
version = "20.0.0"
bin = "node"
```

The stub will automatically install the specified tool version if missing and execute it with any arguments passed to the stub.

For more information, see: <https://mise.jdx.dev/dev-tools/tool-stubs.html>

## Arguments [​](#arguments)

- **`<FILE>`** — Path to the TOML tool stub file to execute

  The stub file must contain TOML configuration specifying the tool and version to run. At minimum, it should specify a 'version' field. Other common fields include 'tool', 'bin', and backend-specific options.
- **`[ARGS]…`** — Arguments to pass to the tool

  All arguments after the stub file path will be forwarded to the underlying tool. Use '--' to separate mise arguments from tool arguments if needed.

## Related documentation [​](#related-documentation)

- [Portable tool stubs](https://mise.jdx.dev/dev-tools/tool-stubs.html).
- [All commands](https://mise.jdx.dev/cli/).
- [Global flags and argument syntax](https://mise.jdx.dev/cli/#global-flags).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/cli/tool-stub.md)

Last updated:

Pager

[Previous pagemise tool-alias unset](https://mise.jdx.dev/cli/tool-alias/unset.html)

[Next pagemise trust](https://mise.jdx.dev/cli/trust.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)