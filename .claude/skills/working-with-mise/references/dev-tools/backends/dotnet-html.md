.NET Tool Backend

.NET Tool Backend [​](#net-tool-backend)

The `dotnet:` backend installs command-line tool packages from NuGet using `dotnet tool install`. The unprefixed `dotnet` tool installs the SDK; see the [.NET language guide](https://mise.jdx.dev/lang/dotnet.html) for SDK selection and `global.json`.

## Dependencies [​](#dependencies)

Install a .NET SDK and the runtime required by the selected tool package. A newer SDK alone does not guarantee that an older tool can run: .NET's runtime selection rules still apply. Use `mise exec -- dotnet --list-runtimes` to inspect what is installed.

## Usage [​](#usage)

This example pairs .NET 8 with a GitVersion release that includes a .NET 8 tool:

sh

```
mise use dotnet@8 dotnet:GitVersion.Tool@6.0.5
mise exec -- dotnet-gitversion /version
```

Both entries are written to the **project's** `mise.toml`:

toml

```
[tools]
dotnet = "8"
"dotnet:GitVersion.Tool" = "6.0.5"
```

Add `-g` to `mise use` for global configuration. To choose another release, run `mise ls-remote dotnet:GitVersion.Tool` and check that release's runtime requirements. `mise use dotnet:GitVersion.Tool` records a `latest` request.

mise installs each tool into its own directory with `--tool-path`; it does not create or update a project's `.config/dotnet-tools.json` manifest.

## Private feeds [​](#private-feeds)

`dotnet.registry_url` selects the NuGet service index used for version discovery. The `dotnet` CLI handles installation separately, using its NuGet configuration and credentials. Configure the installation source in `NuGet.Config` as well; changing the discovery endpoint alone does not add a source to the CLI.

## Settings [​](#settings)

Set these with `mise settings set [VARIABLE]=[VALUE]` or by setting the environment variable listed.

### `dotnet.cli_telemetry_optout`[](#dotnet.cli_telemetry_optout)

- Type: `boolean`(optional)
- Env: `MISE_DOTNET_CLI_TELEMETRY_OPTOUT`
- Default: `None`

When set to true, the `DOTNET_CLI_TELEMETRY_OPTOUT` environment variable is set to `1`, disabling .NET CLI telemetry. When set to false, it is set to `0`.

When unset (default), mise does not set the variable and .NET uses its own default behavior.

### `dotnet.dotnet_root`[](#dotnet.dotnet_root)

- Type: `string`(optional)
- Env: `MISE_DOTNET_ROOT`
- Default: `None`

All .NET SDK versions are installed side-by-side under this directory, matching .NET's native multi-version model.

By default, mise uses `~/.local/share/mise/dotnet-root`. Set this to override the location.

### `dotnet.isolated`[](#dotnet.isolated)

- Type: `boolean`
- Env: `MISE_DOTNET_ISOLATED`
- Default: `false`

When true, each SDK version is installed in its own directory under mise's installs path, like most other tools. `dotnet --list-sdks` will only show the active version.

When false (default), all SDK versions share a single `DOTNET_ROOT` directory and `dotnet --list-sdks` shows all installed versions, matching .NET's native side-by-side model.

### `dotnet.package_flags`[](#dotnet.package_flags)deprecated

- Type: `string[]`
- Env: `MISE_DOTNET_PACKAGE_FLAGS`(comma separated)
- Default: `[]`
- Deprecated: Use the \`prerelease = true\` tool option or the global \`prereleases\` setting instead.

Deprecated. Use the `prerelease = true` tool option on a `dotnet:` tool, or the global `prereleases` setting, to include pre-release versions.

This legacy setting is a list of flags to extend the search and install abilities of dotnet tools. Because it is global, remove it before relying on `prerelease = false` per-tool opt-outs. The only supported flag is:
- 'prerelease' : include pre-release versions in search and install

### `dotnet.registry_url`[](#dotnet.registry_url)

- Type: `string`
- Env: `MISE_DOTNET_REGISTRY_URL`
- Default: `https://api.nuget.org/v3/index.json`

URL of the NuGet service index used to discover tool versions. The default is the public [NuGet service index](https://api.nuget.org/v3/index.json).

Installation runs `dotnet tool install`, which reads its own `NuGet.Config` and credentials. Configure a private feed there as well; this setting does not add an installation source to the dotnet CLI.

## Tool Options [​](#tool-options)

The following [tool-options](https://mise.jdx.dev/dev-tools/#tool-options) are available for the `dotnet` backend—these go in `[tools]` in `mise.toml`.

### `install_env` [​](#install-env)

Set environment variables for the `dotnet tool install` command:

toml

```
[tools]
"dotnet:GitVersion.Tool" = { version = "latest", install_env = { DOTNET_CLI_TELEMETRY_OPTOUT = "1" } }
```

### `prerelease` [​](#prerelease)

By default, NuGet pre-release versions are excluded from `mise ls-remote` and from `latest` resolution. Set `prerelease = true` to include them:

toml

```
[tools]
"dotnet:GitVersion.Tool" = { version = "latest", prerelease = true }
```

The legacy `dotnet.package_flags = ["prerelease"]` setting is deprecated. Prefer the per-tool `prerelease = true` option, or the global `prereleases` setting when every tool should include pre-release versions. Because `dotnet.package_flags` is global, remove it before relying on per-tool `prerelease = false` opt-outs.

## Troubleshooting [​](#troubleshooting)

- **SDK not found:** check `mise exec -- dotnet --info` and any `global.json` that constrains SDK selection.
- **Required framework missing:** install a compatible runtime/SDK or select a tool release that targets the runtime you have.
- **Package not found:** verify that the package is a .NET tool and that both discovery and installation can access its feed.

Implementation: [`src/backend/dotnet.rs`](https://github.com/jdx/mise/blob/main/src/backend/dotnet.rs).

[Edit this page](https://github.com/jdx/mise/edit/main/docs/dev-tools/backends/dotnet.md)

Last updated:

Pager

[Previous pageconda](https://mise.jdx.dev/dev-tools/backends/conda.html)

[Next pageforgejo](https://mise.jdx.dev/dev-tools/backends/forgejo.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)