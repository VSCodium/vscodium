Backend Architecture

Backend Architecture [​](#backend-architecture)

A backend resolves a tool's versions, installs it, and supplies its executable paths and environment. The [registry](https://mise.jdx.dev/registry.html) maps short names such as `node` and `ripgrep` to backends. Start with those names; choose an explicit backend when you need a particular distribution or a tool outside the registry.

## What are Backends? [​](#what-are-backends)

In `github:BurntSushi/ripgrep`, `github` is the backend and `BurntSushi/ripgrep` identifies the upstream project. These are separate from the version request after `@`:

sh

```
mise ls-remote github:BurntSushi/ripgrep
mise use github:BurntSushi/ripgrep@latest
mise exec -- rg --version
```

Installing a tool through a backend does not add a new entry to mise's registry. Explicit backend syntax works directly in your own configuration.

## The Backend Trait System [​](#the-backend-trait-system)

Built-in backends implement the Rust [`Backend` trait](https://github.com/jdx/mise/blob/main/src/backend/mod.rs). The installation flow uses that interface to:

1. List versions or resolve a request such as a prefix or channel.
2. Identify installation dependencies and tool options.
3. Download or build the requested version and perform the verification supported by that distribution.
4. Record the installation and expose executable paths and environment variables.

Version strings are not necessarily semantic versions. Backends can support date releases, vendor prefixes, tags, and rolling channels; the backend determines what `latest` means. A lockfile records a concrete resolution. See [version ordering](https://mise.jdx.dev/dev-tools/#version-ordering) and [mise.lock](https://mise.jdx.dev/dev-tools/mise-lock.html).

For extension APIs, see [tool plugins](https://mise.jdx.dev/tool-plugin-development.html) and [backend plugins](https://mise.jdx.dev/backend-plugin-development.html). Their hook interfaces are separate from the internal Rust trait.

## Backend Types [​](#backend-types)

| Distribution method | Examples | What to check |
| --- | --- | --- |
| Built-in language support | Node.js, Python, Java, Rust | Language-specific options, system libraries, and any build tools required |
| Signed release manifests | `packslip:` | Published manifest, trusted signer, and supported platform |
| Registry-described downloads | `aqua:` | Package entry and its per-version download/verification rules |
| Forge releases | `github:`, `gitlab:`, `forgejo:` | Matching release assets for the target platform |
| Direct artifacts | `http:`, `s3:` | Artifact location, authentication, platform mapping, and integrity information |
| Language packages | `npm:`, `pipx:`, `cargo:`, `gem:`, `go:`, `dotnet:` | Required runtime or toolchain and package-manager behavior |
| Other package sources | `conda:`, `pkgx:`, `spm:` | Backend-specific platform support and dependencies |
| External plugins | asdf, vfox tool plugins, backend plugins | Plugin code, prerequisites, and supported platforms |

The [backend reference](https://mise.jdx.dev/dev-tools/backends/) lists available backends and their options. Built-in language guides are under **Languages** in the sidebar.

## How Backend Selection Works [​](#how-backend-selection-works)

An explicit identifier such as `core:node` expresses a backend choice. A short name such as `node` also depends on configuration and local state:

- `[tool_alias]` and `[plugins]` can select another source.
- A matching lockfile entry can preserve the backend used for that resolution.
- An installed external plugin can override a registry shorthand, including a built-in language tool. Disabled backends and existing installations also affect this choice.
- Otherwise, the registry supplies the preferred available backend, which can depend on the requested version and platform.

Use `mise tool <name>` to inspect the effective backend instead of inferring it from the tool's short name. The [resolution implementation](https://github.com/jdx/mise/blob/main/src/cli/args/backend_arg.rs) contains the detailed precedence rules.

### Environment Variable Overrides [​](#environment-variable-overrides)

`MISE_BACKENDS_<TOOL>` overrides the backend for that identifier. Convert the name to uppercase and replace hyphens with underscores. For example, in a POSIX shell:

sh

```
MISE_BACKENDS_NODE=core:node mise tool node
```

An exported override affects subsequent commands and can override configuration choices. Check your environment when two machines resolve the same shorthand differently.

### Registry System [​](#registry-system)

Inspect a registry mapping with `mise registry node`. To commit a backend choice without changing the registry, use an [alias](https://mise.jdx.dev/dev-tools/aliases.html):

mise.toml

toml

```
[tool_alias]
node = "core:node"

[tools]
node = "24"
```

## Backend Capabilities Comparison [​](#backend-capabilities-comparison)

Verification and platform support depend on both the backend and the particular tool. A backend supporting Windows does not imply every package it installs has a Windows release. Likewise, downloading a checksum does not establish the publisher's identity unless that checksum is authenticated.

Consult each backend's verification options and the [security guide](https://mise.jdx.dev/security.html). For example, packslip verifies signed manifests, and aqua can apply the verification methods declared by its registry entry. External plugin code runs locally and must be trusted along with the tool itself.

## When to Use Each Backend [​](#when-to-use-each-backend)

Start with a registry shorthand for supported tools. For another source:

- Use `packslip:` when the publisher provides signed release manifests.
- Use `aqua:` when its registry describes the required tool and releases.
- Use a forge backend for release assets, or `http:` or `s3:` for artifacts you distribute directly.
- Use a language package backend when you need that ecosystem's package and can supply its runtime or build dependencies.
- Use a plugin when installation or environment setup needs custom logic.

Deprecated backend

`ubi:` is deprecated. Use the corresponding `github:` or `gitlab:` backend and review its options when migrating; see the [ubi migration guide](https://mise.jdx.dev/dev-tools/backends/ubi.html).

## Backend Dependencies [​](#backend-dependencies)

Backends may need another tool during installation. Declare the required tools alongside the package so mise can install them in order:

mise.toml

toml

```
[tools]
node = "24"
"npm:prettier" = "3"
```

A dependency relationship does not automatically add missing tools to your configuration. A matching configured tool is installed first; an unconfigured dependency may be satisfied by a suitable executable on the existing `PATH`. Otherwise installation fails. See [tool dependencies](https://mise.jdx.dev/dev-tools/#tool-dependencies) for explicit `depends` declarations.

## Configuration and Overrides [​](#configuration-and-overrides)

### Disable Backends [​](#disable-backends)

Use the global settings file to prevent installation through selected backends:

\~/.config/mise/config.toml

toml

```
[settings]
disable_backends = ["asdf", "vfox"]
```

Disabled backends are excluded from tool resolution and new installs. Existing installations are left on disk and become available again if the backend is re-enabled.

### Force Backend for Tool [​](#force-backend-for-tool)

An explicit identifier can be used directly as a tool key:

mise.toml

toml

```
[tools]
"core:node" = "24"
"aqua:BurntSushi/ripgrep" = "latest"
```

### Backend-Specific Settings [​](#backend-specific-settings)

Read the selected backend's reference before adding options. For example, this selects an optional extra from a Python package:

mise.toml

toml

```
[tools]
python = "3.14"
uv = "latest"
"pipx:black" = { version = "latest", extras = ["jupyter"] }
```

The [pipx backend](https://mise.jdx.dev/dev-tools/backends/pipx.html) can use uv or pipx. Backend options are not interchangeable with options for another distribution of the same tool.

## Troubleshooting Backend Issues [​](#troubleshooting-backend-issues)

### Debug Backend Selection [​](#debug-backend-selection)

sh

```
mise tool node       # effective backend and tool information
mise plugins ls      # external plugins that may override defaults
mise config ls       # configuration files contributing to this directory
mise ls --current    # selected versions and their sources
mise doctor          # installation and activation diagnostics
```

If selection is correct but installation fails, check the backend's prerequisites, platform support, and authentication requirements. `MISE_DEBUG=1 mise install node` adds diagnostic output; review logs for credentials before sharing them.

[Edit this page](https://github.com/jdx/mise/edit/main/docs/dev-tools/backend_architecture.md)

Last updated:

Pager

[Previous pageDeps](https://mise.jdx.dev/dev-tools/deps.html)

[Next pageCore tools](https://mise.jdx.dev/core-tools.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)