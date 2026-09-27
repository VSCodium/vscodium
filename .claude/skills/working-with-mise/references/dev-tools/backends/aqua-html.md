Aqua Backend

Aqua Backend [​](#aqua-backend)

[Aqua](https://aquaproj.github.io/) tools can be used natively in mise. aqua is a Tier 2 backend for tools without [packslip manifests](https://mise.jdx.dev/dev-tools/backends/packslip.html): it does not require plugins, it works on Windows, and it offers security features beyond checksums. Verification depends on the metadata provided for each package.

You do not need to install aqua separately. mise does not use the aqua CLI at all; it uses the [aqua registry](https://github.com/aquaproj/aqua-registry), which is compiled into the mise binary on release. Here is an example package entry: [`aqua:hashicorp/terraform`](https://github.com/aquaproj/aqua-registry/blob/main/pkgs/hashicorp/terraform/registry.yaml). mise has its own reimplementation of aqua that reads these files to install tools.

By default, the bundled snapshot is used. The opt-in [`registry_floating`](https://mise.jdx.dev/configuration/settings.html#registry_floating) setting checks the current official aqua registry first while retaining the bundled snapshot as a fallback. It also floats mise's shorthand registry; see [Floating registries](https://mise.jdx.dev/registry.html#floating-registries) for the tradeoffs and cache behavior.

If an entry has incorrect platform names, URLs, or verification metadata, report it to the aqua registry or contribute a correction. A mise release contains a snapshot, so a fix upstream may require a newer mise release or a custom registry.

Aqua recipes primarily download and extract published artifacts. Tools that need custom installation steps or environment setup may require another backend.

The code for this backend is in the mise repository at [`./src/backend/aqua.rs`](https://github.com/jdx/mise/blob/main/src/backend/aqua.rs).

## Custom Registry [​](#custom-registry)

Set [`aqua.registries`](https://mise.jdx.dev/configuration/settings.html#aqua.registries) to check custom aqua registry sources before the baked-in registry:

toml

```
[settings]
aqua.registries = ["https://github.com/my-org/aqua-registry"]
```

To check multiple registries before the baked registry, list them in order:

toml

```
[settings]
aqua.registries = [
  "https://github.com/my-org/internal-aqua-registry",
  "https://github.com/partner/aqua-registry",
]
```

Each source can be a repository URL, a direct URL to a `registry.yaml` or `registry.yml` file, or a local directory or registry file specified with an absolute `file://` URL:

toml

```
[settings]
aqua.registries = [
  "file:///absolute/path/to/aqua-registry",
  "file:///absolute/path/to/registry.yaml",
  "https://example.com/registry.yaml",
]
```

For repository and directory sources, mise loads `registry.yaml` from the source root, falling back to `registry.yml` if needed. Remote registry sources are cached under `MISE_CACHE_DIR` for [`aqua.registry_cache_ttl`](https://mise.jdx.dev/configuration/settings.html#aqua.registry_cache_ttl), which defaults to one week. Local `file://` sources bypass the downloaded source cache, so changes are read the next time the registry is loaded. In `MISE_AQUA_REGISTRIES`, separate multiple registry URLs with commas.

After a refreshed registry source is downloaded, mise hashes the source and uses that hash in the compiled registry cache path. When a new compiled cache is successfully loaded or written, older compiled caches for the same registry URL are pruned.

Packages are resolved by checking the configured registries in order. When `aqua.baked_registry` is enabled, the baked-in registry remains a fallback for packages missing from all configured registries. Aqua registry aliases are local to the registry that defines them; use [`[tool_alias]`](https://mise.jdx.dev/dev-tools/aliases.html) when you want a mise shorthand or alias to point at an aqua package from another registry.

The legacy [`aqua.registry_url`](https://mise.jdx.dev/configuration/settings.html#aqua.registry_url) setting is still supported for a single registry URL, but `aqua.registries` takes precedence when both are set.

## Usage [​](#usage)

Install ripgrep in your project and verify the executable without requiring shell activation:

sh

```
mise use aqua:BurntSushi/ripgrep
mise exec -- rg --version
```

This writes the following to `mise.toml`. Add `-g` to `mise use` for a global tool.

toml

```
[tools]
"aqua:BurntSushi/ripgrep" = "latest"
```

Use `mise ls-remote aqua:BurntSushi/ripgrep` to inspect available versions. `mise registry ripgrep` shows the backends configured for its shorthand.

## Tool Options [​](#tool-options)

### `symlink_bins` [​](#symlink-bins)

Some tools bundle extra executables that you may not want exposed on PATH. For example, `aws-cli` bundles Python, which can conflict with your intended Python version.

Setting `symlink_bins = true` creates a filtered `.mise-bins` directory and exposes only the binaries intended for that aqua package, instead of every executable discovered in the install.

toml

```
[tools]
aws-cli = { version = "latest", symlink_bins = true }
```

When enabled:

- If the aqua registry defines a `files` field, only those binaries are exposed (e.g., `aws` and `aws_completer` for aws-cli)
- Otherwise, mise falls back to exposing the inferred primary binary for the package
- A `.mise-bins` subdirectory is created with symlinks to the exposed binaries
- Bundled dependencies and other extra executables, such as Python in `aws-cli`, are not added to PATH

### `vars` [​](#vars)

Some aqua registry entries define template variables (for example `{{.Vars.channel}}`). Set them via tool options using either top-level keys or a nested `vars` table:

toml

```
[tools]
"aqua:flutter/flutter" = { version = "3.32.8", channel = "stable" }
"aqua:scenarigo/scenarigo" = { version = "0.21.0", vars = { go_version = "1.24" } }
```

Vars with defaults are filled automatically. Vars marked as required in the aqua registry must be set unless the registry also provides a default.

### `prerelease` [​](#prerelease)

By default, releases flagged `prerelease: true` on GitHub are excluded from `mise ls-remote` and from `latest` resolution. Set `prerelease = true` to include them:

toml

```
[tools]
"aqua:owner/tool" = { version = "latest", prerelease = true }
```

When set, pre-release tags (e.g. `v1.0.0-rc1`, `v0.1.2-dev.86`) appear in `mise ls-remote`, `latest` resolves against the full list including pre-releases, and fuzzy version queries match pre-release tags. The option has no effect when a package uses the `github_tag` version source (git tags don't carry a prerelease flag). Draft releases are always excluded. See the [github backend docs](https://mise.jdx.dev/dev-tools/backends/github.html#prerelease) for more detail.

## Settings [​](#settings)

### `aqua.baked_registry`[](#aqua.baked_registry)

- Type: `boolean`
- Env: `MISE_AQUA_BAKED_REGISTRY`
- Default: `true`

Use baked-in aqua registry.

### `aqua.cosign`[](#aqua.cosign)

- Type: `boolean`
- Env: `MISE_AQUA_COSIGN`
- Default: `true`

Use cosign to verify aqua tool signatures.

### `aqua.github_attestations`[](#aqua.github_attestations)

- Type: `boolean`
- Env: `MISE_AQUA_GITHUB_ATTESTATIONS`
- Default: `true`

Enable/disable GitHub Artifact Attestations verification for aqua tools. When enabled, mise will verify the authenticity and integrity of downloaded tools using GitHub's artifact attestation system.

### `aqua.minisign`[](#aqua.minisign)

- Type: `boolean`
- Env: `MISE_AQUA_MINISIGN`
- Default: `true`

Use minisign to verify aqua tool signatures.

### `aqua.registries`[](#aqua.registries)

- Type: `string[]`(optional)
- Env: `MISE_AQUA_REGISTRIES`(comma separated)
- Default: `None`

Aqua registry sources to load before the baked-in registry. Each source can be a repository URL, a direct URL to a `registry.yaml` or `registry.yml` file, or an absolute `file://` URL to a local registry directory or file. For repository and directory sources, mise loads `registry.yaml` from the source root and falls back to `registry.yml` if needed.

A source that is not a URL is read as a filesystem path, resolved against the config root of the file that declared it. This is how you reference a registry committed alongside the project:```toml
[settings]
aqua.registries = ["registry.yaml"]
```

Path resolution applies only to sources set in a config file, since only those have a config root to resolve against. A path given via `MISE_AQUA_REGISTRIES` or the CLI must be an absolute `file://` URL.

Downloaded registries are cached according to `aqua.registry_cache_ttl`, which defaults to one week. To refresh sooner, run `mise cache clear`, set `aqua.registry_cache_ttl = "0s"`, or change `MISE_CACHE_DIR` to use a different cache location. Local `file://` sources bypass the downloaded source cache, so changes are read the next time the registry is loaded.

If this is set, mise checks the configured registries in order. When `aqua.baked_registry` is enabled, the baked-in aqua registry remains a fallback for packages missing from all configured registries.

By default, mise uses the baked-in official aqua registry when `aqua.baked_registry` is enabled. If the baked registry is disabled and no registries are configured, mise downloads the official registry: https://github.com/aquaproj/aqua-registry

### `aqua.registry_cache_ttl`[](#aqua.registry_cache_ttl)

- Type: `string`
- Env: `MISE_AQUA_REGISTRY_CACHE_TTL`
- Default: `1w`

How long downloaded aqua registry source files remain fresh before mise re-downloads them.

When the downloaded source changes, mise writes the new source cache atomically, compiles a new source-hash-scoped registry cache, and prunes older compiled caches for that registry URL after the new compiled cache is available.

Set to `0s` to re-download remote registries every time.

### `aqua.registry_url`[](#aqua.registry_url)deprecated

- Type: `string`(optional)
- Env: `MISE_AQUA_REGISTRY_URL`
- Default: `None`
- Deprecated: Use aqua.registries instead.

Deprecated. Use `aqua.registries` instead.

Legacy single aqua registry repository URL to fetch before the baked-in registry.

### `aqua.slsa`[](#aqua.slsa)

- Type: `boolean`
- Env: `MISE_AQUA_SLSA`
- Default: `true`

Use SLSA to verify aqua tool signatures.

## Security Verification [​](#security-verification)

mise implements checksum, GitHub artifact attestation, Cosign, SLSA, and Minisign verification natively. You do not need their separate CLI tools. **Support in the backend does not mean that every package supplies all of these checks.**

| Method | Required publisher or registry metadata |
| --- | --- |
| Checksums | An expected digest from registry metadata, a checksum file, the release API, or a lockfile. |
| GitHub artifact attestations | A registry attestation configuration identifying the expected workflow. |
| Cosign | A supported public-key or signature-bundle configuration; arbitrary Cosign CLI arguments are not executed. |
| SLSA | A registry provenance configuration and the publisher's provenance artifact. |
| Minisign | A signature and the expected public key. |

The corresponding `aqua.*` verification settings are enabled by default. Some checks also have a global setting, such as `github_attestations` or `slsa`. See [Settings](#settings) for the complete configuration.

A verified [lockfile](https://mise.jdx.dev/dev-tools/mise-lock.html) can reuse a previous provenance result while checking the artifact digest. Set [`locked_verify_provenance`](https://mise.jdx.dev/configuration/settings.html#locked_verify_provenance) to require provenance verification again during locked installation.

### Troubleshooting [​](#troubleshooting)

Start with the failing command and its verification error:

sh

```
MISE_DEBUG=1 mise install aqua:cli/cli
```

Check that the release publishes the expected signature or attestation, that the registry names the correct artifact and signer, and that your clock and network allow certificate and transparency-log verification. For private assets or API limits, check [GitHub authentication](https://mise.jdx.dev/dev-tools/github-tokens.html).

A digest mismatch requires investigating the artifact or expected digest. A missing or invalid signature requires checking the publisher and registry metadata. Disabling verification changes which artifacts you trust; it does not repair either problem. Report the affected version, platform, and verifier error with credentials removed.

## Common aqua issues [​](#common-aqua-issues)

These problems usually require a correction to the package entry in the aqua registry.

### Supported env missing [​](#supported-env-missing)

Compare the registry entry's `supported_envs` with the publisher's release assets. If a matching artifact exists but its platform is absent from the registry, update that entry. Adding a platform name alone cannot make an incompatible binary run.

### Using `version_filter` instead of `version_prefix` [​](#using-version-filter-instead-of-version-prefix)

Use `version_prefix` to remove a known tag prefix from the versions shown to users, and `version_filter` to exclude unrelated releases. Preserve the publisher's meaningful version identifiers; a version does not need to be a three-part semantic version.

For example, an entry may use a `version_filter` expression like `Version startsWith "atlascli/"`.

This causes the version to be `atlascli/1.2.3`, which is not what we want. The fix is to use `version_prefix` instead of `version_filter` and put the prefix (`atlascli/` in this example) in the `version_prefix` field. mise automatically strips the prefix and adds it back when needed, which it can't do with `version_filter`.

[Edit this page](https://github.com/jdx/mise/edit/main/docs/dev-tools/backends/aqua.md)

Last updated:

Pager

[Previous pageBackends](https://mise.jdx.dev/dev-tools/backends/)

[Next pageasdf](https://mise.jdx.dev/dev-tools/backends/asdf.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)