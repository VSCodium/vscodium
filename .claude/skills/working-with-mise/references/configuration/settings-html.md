Settings

Settings [​](#settings)

Settings control mise itself, such as installation concurrency and task output. Application environment variables belong in [`[env]`](https://mise.jdx.dev/environments/).

## Change a setting [​](#change-a-setting)

The settings command writes to the global config by default. Use `--local` to write to the project's selected config file:

sh

```
mise settings set jobs 4          # personal default
mise settings set --local jobs 2  # project setting
mise settings unset --local jobs  # remove the project override
```

The equivalent TOML is:

toml

```
[settings]
jobs = 4
```

Use `mise settings ls --all` to inspect effective settings, including defaults. `mise settings ls --json-extended` includes source information for configured values. A setting's reference below lists its type, default, and environment variable when available. Some settings also have global CLI flags.

## Early initialization [​](#early-initialization)

Some settings control config discovery and are read before `mise.toml`. These must be set through their environment variable or, where supported, a [`.miserc.toml` file](https://mise.jdx.dev/configuration/environments.html#setting-mise-env-in-miserc-toml). Follow the individual setting's instructions; putting an early setting under `[settings]` can be too late to affect discovery.

## Reference [​](#reference)

## `activate_aggressive`[](#activate_aggressive)

- Type: `boolean`
- Env: `MISE_ACTIVATE_AGGRESSIVE`
- Default: `false`

Pushes tools' bin-paths to the front of PATH instead of allowing modifications of PATH after activation to take precedence. For example, if you have the following in your `mise.toml`:

```toml
[tools]
node = '20'
python = '3.12'
```

But you also have this in your `~/.zshrc`:

```sh
eval "$(mise activate zsh)"
PATH="/some/other/python:$PATH"
```

What will happen is `/some/other/python` will be used instead of the python installed by mise. This means you typically want to put `mise activate` at the end of your shell config so nothing overrides it.

If you want to always use the mise versions of tools despite what is in your shell config, set this to `true`. In that case, using this example again, `/some/other/python` will be after mise's python in PATH.

## `activate_shims`[](#activate_shims)

- Type: `boolean`
- Env: `MISE_ACTIVATE_SHIMS`
- Default: `true`

Set to false to keep the user and system tool shim directories out of `PATH` during `mise activate` and subsequent shell hooks, even when automatic installation or lazy tools would otherwise add them:```sh
mise settings set activate_shims false
```

Restart your shell after changing this setting. For an environment-variable override, set `MISE_ACTIVATE_SHIMS=false` before running `mise activate`.

Shims support missing-version auto-installation and first-use installation of lazy tools. Disabling them can prevent these commands from being found; use `mise install` or `mise exec` explicitly instead. Installed tools still get their real bin directories added to `PATH`.

Configured command wrappers, such as `cargo` through [mr-boxington](https://github.com/jdx/mr-boxington), use a separate `command-wrappers/bin` directory and remain active. Explicit `mise activate --shims` also continues to add shims regardless of this setting.

## `all_compile`[](#all_compile)

- Type: `boolean`(optional)
- Env: `MISE_ALL_COMPILE`
- Default: `None`

Default: false unless running Alpine or NixOS. Both automatic defaults are deprecated: affected source installs warn beginning in mise 2026.8.0, and the defaults will be removed in mise 2027.8.0. Afterward, users who require source builds must set `all_compile = true` explicitly.

Do not use precompiled binaries for all languages. Useful if running on a Linux distribution like Alpine that does not use glibc and therefore likely won't be able to run precompiled binaries.

This needs to be set up for each language. File a ticket if you notice a language that is not working with this config.

## `always_keep_download`[](#always_keep_download)

- Type: `boolean`
- Env: `MISE_ALWAYS_KEEP_DOWNLOAD`
- Default: `false`

Keeps downloaded archive/source files under `~/.local/share/mise/downloads` after install/uninstall so you can inspect them while debugging backend/plugin install behavior.

This is not a supported download cache. Some backends may skip a download when the expected file already exists, but that behavior is backend-specific and not guaranteed. Cache `~/.local/share/mise/installs` instead if you want to avoid reinstalling tools in CI or offline workflows.

## `always_keep_install`[](#always_keep_install)

- Type: `boolean`
- Env: `MISE_ALWAYS_KEEP_INSTALL`
- Default: `false`

should mise keep install files after installation even if the installation fails

## `arch`[](#arch)

- Type: `string`
- Env: `MISE_ARCH`
- Default: `"x86_64" | "aarch64" | "arm" | "loongarch64" | "riscv64"`

Architecture to use for precompiled binaries. This is used to determine which precompiled binaries to download. If unset, mise will use the system's architecture.

## `auto_env`[](#auto_env)

- Type: `boolean`(optional)
- Env: `MISE_AUTO_ENV`
- Default: `None`

When enabled, mise treats the following as active config environments (in addition to any explicit `MISE_ENV`): `unix` (on unix-family platforms), the OS name (`linux`/`macos`/`windows`), and `{os}-{arch}` (e.g. `macos-arm64`, `windows-x64`, using mise's remapped arch names: `x86_64` -> `x64`, `aarch64` -> `arm64`).

This causes config files such as `mise.windows.toml`, `mise/config.macos-arm64.toml`, or `mise.unix.toml` to be loaded automatically, and matching `mise.<env>.lock` lockfiles to be selected. Platform environments have lower precedence than explicit `MISE_ENV` entries; the full precedence order is `unix` < `{os}` < `{os}-{arch}` < explicit `MISE_ENV` entries. Platform environments do not affect the `{{ mise_env }}` template variable or the `MISE_ENV` variable passed to subprocesses.

When unset, this currently defaults to `false`. Starting with mise 2027.6.0 it will default to `true`; set it to `false` to keep the old behavior, or `true` to adopt the new behavior early.

This is an early-init setting: it must be set in `.miserc.toml` or via the `MISE_AUTO_ENV` environment variable. Setting it in `mise.toml` will have no effect because config file discovery has already occurred by the time `mise.toml` is read.

See [Configuration Environments](https://mise.jdx.dev/configuration/environments.html) for more details.

## `auto_install`[](#auto_install)

- Type: `boolean`
- Env: `MISE_AUTO_INSTALL`
- Default: `true`

Automatically install missing tools when running `mise x`, `mise run`, or as part of the 'not found' handler.

## `auto_install_disable_tools`[](#auto_install_disable_tools)

- Type: `string[]`(optional)
- Env: `MISE_AUTO_INSTALL_DISABLE_TOOLS`(comma separated)
- Default: `None`

List of tools to skip automatically installing when running `mise x`, `mise run`, or as part of the 'not found' handler.

## `auto_update`[](#auto_update)

- Type: `boolean`
- Env: `MISE_AUTO_UPDATE`
- Default: `false`

When enabled, mise periodically checks for a newer release before running commands that permit network access. If an update is available, mise installs it without updating plugins, then re-runs the original command with the new binary.

Automatic updates are skipped in CI, offline and prefer-offline modes, non-interactive sessions, shell integration commands, and installations whose packager disabled self-update. This setting is global-only so a project's configuration cannot opt users into replacing their mise binary.

## `auto_update_check_duration`[](#auto_update_check_duration)

- Type: `string`
- Env: `MISE_AUTO_UPDATE_CHECK_DURATION`
- Default: `7d`

How often to check for a new mise release when auto-update is enabled.

## `cache_prune_age`[](#cache_prune_age)

- Type: `string`
- Env: `MISE_CACHE_PRUNE_AGE`
- Default: `30d`

The age of the cache before it is considered stale. mise will occasionally delete cache files which have not been accessed in this amount of time.

Set to `0s` to keep cache files indefinitely.

## `ceiling_paths`[](#ceiling_paths)

- Type: `string[]`
- Env: `MISE_CEILING_PATHS`
- Default: `[]`

Directories where mise stops searching for config files. By default, mise will search from the current directory up to the root of the filesystem.

Setting this to a list of directories will stop the search when one of those directories is reached. Config files **in** the ceiling directory itself are excluded—only directories below it are searched. For example, if `MISE_CEILING_PATHS="/home/user"`, then `/home/user/mise.toml` is **not** loaded, but `/home/user/projects/myapp/mise.toml` is.

This follows the same semantics as Git's `GIT_CEILING_DIRECTORIES`.

This is an early-init setting: it must be set in `.miserc.toml`, environment variables, or CLI flags. Setting it in `mise.toml` will have no effect because config file discovery has already occurred by the time `mise.toml` is read.

Paths are separated by the OS path separator when using the environment variable, `mise settings set`, or `mise settings add` (`:` on Unix, `;` on Windows).

## `color`[](#color)

- Type: `boolean`
- Env: `MISE_COLOR`
- Default: `true`

Use color in mise terminal output

## `color_theme`[](#color_theme)

- Type: `string`
- Env: `MISE_COLOR_THEME`
- Default: `default`
- Choices:
  - `auto`
  - `default`
  - `charm`
  - `base16`
  - `catppuccin`
  - `dracula`

Sets the color theme for interactive prompts like `mise run` task selection. Available themes:
- `auto` (or `default`) - Auto-detect the terminal background (via `COLORFGBG`) and use a light-friendly theme ( `base16`) on light terminals, otherwise `charm`
- `charm` - The charm theme, works well on dark terminals (no auto-detection)
- `base16` - Base16 theme, works well on light terminals
- `catppuccin` - Catppuccin theme
- `dracula` - Dracula theme

`default` is an alias for `auto`: when left unset (or set to `auto`/`default`), mise auto-detects a light terminal background via `COLORFGBG` and switches to `base16` for readability. Set an explicit theme (e.g. `charm`) to disable auto-detection.

When colors are disabled (`color=false`, `NO_COLOR`, or `CLICOLOR=0`), interactive prompts are rendered without any styling regardless of this setting.

## `default_config_filename`[](#default_config_filename)

- Type: `string`
- Env: `MISE_DEFAULT_CONFIG_FILENAME`
- Default: `mise.toml`

The default config filename read. `mise use` and other commands that create new config files will use this value. This must be an env var.

## `default_tool_versions_filename`[](#default_tool_versions_filename)

- Type: `string`
- Env: `MISE_DEFAULT_TOOL_VERSIONS_FILENAME`
- Default: `.tool-versions`

The default .tool-versions filename read. This will not ignore .tool-versions—use override\_tool\_versions\_filename for that. This must be an env var.

## `disable_backends`[](#disable_backends)

- Type: `string[]`
- Env: `MISE_DISABLE_BACKENDS`(comma separated)
- Default: `[]`

Backends to exclude from tool resolution and new installs, such as `asdf`, `pypi`, or a vfox-backend plugin name. Existing installations are left on disk and become available again if the backend is re-enabled.

## `disable_default_registry`[](#disable_default_registry)

- Type: `boolean`
- Env: `MISE_DISABLE_DEFAULT_REGISTRY`
- Default: `false`

Disable the default mapping of short tool names like `php` -> `asdf:mise-plugins/asdf-php`. This parameter disables only for the backends `vfox` and `asdf`.

## `disable_hints`[](#disable_hints)

- Type: `string[]`
- Env: `MISE_DISABLE_HINTS`
- Default: `[]`

Turns off helpful hints when using different mise features

## `disable_tools`[](#disable_tools)

- Type: `string[]`
- Env: `MISE_DISABLE_TOOLS`
- Default: `[]`

Tools defined in mise.toml that should be ignored

## `disable_update_warning`[](#disable_update_warning)

- Type: `boolean`
- Env: `MISE_DISABLE_UPDATE_WARNING`
- Default: `false`

Disables mise update notices in `mise version`, `mise --version`, and `mise doctor`. Other warnings are unaffected. This does not disable `mise self-update` or automatic updates enabled with [`auto_update`](#auto_update).

## `enable_tools`[](#enable_tools)

- Type: `string[]`(optional)
- Env: `MISE_ENABLE_TOOLS`
- Default: `None`

When unset, all tools are enabled unless they appear in [`disable_tools`](https://mise.jdx.dev/configuration/settings.html#disable_tools).

When explicitly set, this is the complete allowlist and `disable_tools` is not applied. Setting this to `[]` or `MISE_ENABLE_TOOLS=` disables all tools.

## `env`[](#env)

- Type: `string[]`
- Env: `MISE_ENV`(comma separated)
- Default: `[]`

Enables profile-specific config files such as `.mise.development.toml`. Use this for different env vars or different tool versions in development/staging/production environments. See [Configuration Environments](https://mise.jdx.dev/configuration/environments.html) for more on how to use this feature.

Multiple envs can be set by separating them with a comma, e.g. `MISE_ENV=ci,test`. They will be read in order, with the last one taking precedence.

This is an early-init setting: it must be set in `.miserc.toml`, environment variables, or CLI flags (`-E`/`--env`). Setting it in `mise.toml` will have no effect because `MISE_ENV` determines which config files to load.

## `env_cache`[](#env_cache)

- Type: `boolean`
- Env: `MISE_ENV_CACHE`
- Default: `false`

Cache computed environments (variables and PATH) to disk. This can reduce repeated work in nested commands such as `mise x -- mise env`.

`mise activate` and `mise exec` establish a session key (`__MISE_ENV_CACHE_KEY`) inherited by child processes. Cache files are encrypted on disk; a process with the key can decrypt them. An unrelated session may have a different key and will recompute the environment.

The cache key includes configuration paths and modification times, resolved tool versions, relevant settings, the base PATH, and the mise version. Entries also expire after `env_cache_ttl`, and plugin-declared watched files can invalidate them. Changes to dotenv files or sourced scripts may still leave a nested command using a cached environment; clear or disable the cache when those changes are not reflected.

Env plugins can return `cacheable = true` and `watch_files` from their `MiseEnv` hook. See [Env Plugin Development](https://mise.jdx.dev/env-plugin-development.html) for the Lua return format.

Ordinary environment directives do not currently support a per-value `cacheable = false` option. Set `MISE_ENV_CACHE=0` before starting mise when a command must recompute values. Changes in an external service do not invalidate the cache by themselves; choose a suitable TTL or disable caching for those workflows.

See [Environment caching](https://mise.jdx.dev/cache-behavior.html#environment-caching) for cache location and refresh behavior.

## `env_cache_ttl`[](#env_cache_ttl)

- Type: `string`
- Env: `MISE_ENV_CACHE_TTL`
- Default: `1h`

How long cached environments remain valid before being regenerated. Accepts duration strings like "1h", "30m", "1d".

Even with a valid TTL, caches are still invalidated when config files, tool versions, settings, or watched files change.

## `env_conf_d`[](#env_conf_d)

- Type: `boolean`(optional)
- Env: `MISE_ENV_CONF_D`
- Default: `None`

When enabled, files in `.mise/conf.d` and `.config/mise/conf.d` use environment suffixes: `tools.development.toml` loads only when `development` is active, and `tools.development.local.toml` is its local variant.

This behavior is opt-in during the migration period. When disabled or unset, all non-hidden TOML files in `conf.d` continue to load unconditionally. Dots in unconditional fragment names are deprecated; rename `node.tools.toml` to `node-tools.toml` before mise 2027.8.10.

This is an early-init setting: it must be set in a `miserc.toml` file or via the `MISE_ENV_CONF_D` environment variable. Setting it in `mise.toml` has no effect because config file discovery has already occurred by the time `mise.toml` is read.

## `env_file`[](#env_file)

- Type: `string`(optional)
- Env: `MISE_ENV_FILE`
- Default: `None`

Path to a file containing environment variables to automatically load.

## `env_shell_expand`[](#env_shell_expand)

- Type: `boolean`
- Env: `MISE_ENV_SHELL_EXPAND`
- Default: `true`

Controls shell-style variable expansion in `mise.toml` `[env]` values:```toml
[env]
FOO = "hello"
BAR = "$FOO-world"        # "hello-world"
BAZ = "${FOO}_suffix"     # "hello_suffix"
QUX = "${UNDEF:-fallback}" # "fallback"
```
- `true` or unset — enable shell expansion
- `false` — disable shell expansion

Expansion happens after Tera template rendering, so both syntaxes can be mixed. Undefined variables are left unexpanded (e.g., `$MISSING` stays as `$MISSING`) and produce a warning. Use `${MISSING:-}` to suppress the warning.

## `exec_auto_install`[](#exec_auto_install)

- Type: `boolean`
- Env: `MISE_EXEC_AUTO_INSTALL`
- Default: `true`

Automatically install missing tools when running `mise x`.

## `experimental`[](#experimental)

- Type: `boolean`
- Env: `MISE_EXPERIMENTAL`
- Default: `false`

Enables experimental features. I generally will publish new features under this config which needs to be enabled to use them. While a feature is marked as "experimental" its behavior may change or even disappear in any release.

The idea is experimental features can be iterated on this way so we can get the behavior right, but once that label goes away you shouldn't expect things to change without a proper deprecation—and even then it's unlikely.

Also, I very often will use experimental as a beta flag as well. New functionality that I want to test with a smaller subset of users I will often push out under experimental mode even if it's not related to an experimental feature.

If you'd like to help me out, consider enabling it even if you don't have a particular feature you'd like to try. Also, if something isn't working right, try disabling it if you can.

## `fetch_remote_versions_cache`[](#fetch_remote_versions_cache)

- Type: `string`
- Env: `MISE_FETCH_REMOTE_VERSIONS_CACHE`
- Default: `1h`

duration that remote version cache is kept for "fast" commands (represented by PREFER\_STALE), these are always cached. For "slow" commands like `mise ls-remote` or `mise install`:

- if MISE\_FETCH\_REMOTE\_VERSIONS\_CACHE is set, use that
- if MISE\_FETCH\_REMOTE\_VERSIONS\_CACHE is not set, use HOURLY

## `fetch_remote_versions_timeout`[](#fetch_remote_versions_timeout)

- Type: `string`
- Env: `MISE_FETCH_REMOTE_VERSIONS_TIMEOUT`
- Default: `20s`

Fast commands using `prefer_offline` cap this timeout at 3 seconds so shims and shell activation do not block for a long time when cached data is insufficient and the network is unavailable.

## `github_attestations`[](#github_attestations)

- Type: `boolean`
- Env: `MISE_GITHUB_ATTESTATIONS`
- Default: `true`

Enable/disable GitHub Artifact Attestations verification globally. When enabled, mise will verify the authenticity and integrity of downloaded tools using GitHub's artifact attestation system for tools that support it (e.g., Ruby precompiled binaries).

## `global_config_file`[](#global_config_file)

- Type: `string`(optional)
- Env: `MISE_GLOBAL_CONFIG_FILE`
- Default: `None`

Path to the global mise config file. Default is `~/.config/mise/config.toml`. This must be an env var.

## `global_config_root`[](#global_config_root)

- Type: `string`(optional)
- Env: `MISE_GLOBAL_CONFIG_ROOT`
- Default: `None`

Path which is used as `{{config_root}}` for the global config file. Default is `$HOME`. This must be an env var.

## `gpg_verify`[](#gpg_verify)

- Type: `boolean`(optional)
- Env: `MISE_GPG_VERIFY`
- Default: `None`

Verify OpenPGP signatures for all tools (built-in, no external gpg required). Set to false to disable.

## `http_download_timeout`[](#http_download_timeout)

- Type: `string`
- Env: `MISE_HTTP_DOWNLOAD_TIMEOUT`
- Default: `30m`

Limits the complete wall-clock time for downloading one artifact, including all retry attempts and backoff delays. This is separate from `http_timeout`, which detects stalled connections by timing out individual reads.

When this budget is exhausted, mise reports the URL, active attempt, bytes received during that attempt, and this setting name. If the server supplies a strong ETag or Last-Modified validator, the validated partial download is kept for the next attempt or mise invocation.

## `http_retries`[](#http_retries)

- Type: `integer`
- Env: `MISE_HTTP_RETRIES`
- Default: `3`

Retries are attempted only on transient errors: HTTP 5xx (server errors), 408 (Request Timeout), 429 (Too Many Requests), and network-layer failures (connect refused, timeout, mid-stream body drops). Other 4xx responses (e.g. 404) are treated as permanent and not retried.

Backoff schedule with jitter: \~200ms / \~1s / \~4s / \~15s. Set to 0 to disable retries entirely.

Retries are automatically disabled for fast commands using `prefer_offline`, including shims and shell activation. These paths make one network attempt when cached data is insufficient, then fail or fall back immediately.

When a retry rescues a request, a warning is logged with the original error so flaky infrastructure doesn't silently mask itself.

Artifact downloads resume from validated partial files when the server supports byte ranges and supplies a strong ETag or Last-Modified value. Servers without a safe validator restart downloads from the beginning. Changing the request URL or request headers also discards the previous partial download.

## `http_timeout`[](#http_timeout)

- Type: `string`
- Env: `MISE_HTTP_TIMEOUT`
- Default: `30s`

This timeout applies to the connection phase and to each individual response read. The read timer resets whenever data is received, so long-running artifact downloads are bounded separately by `http_download_timeout`.

## `idiomatic_version_file_disable_files`[](#idiomatic_version_file_disable_files)

- Type: `string[]`
- Env: `MISE_IDIOMATIC_VERSION_FILE_DISABLE_FILES`
- Default: `[]`

Use `tool:filename` pairs to exclude individual idiomatic version files without disabling other files for the tool or other tools that read the same file.

For example, this keeps `.nvmrc` enabled for node while preventing node from reading `devEngines.runtime` in `package.json`:

```
mise settings add idiomatic_version_file_disable_files node:package.json
```

## `idiomatic_version_file_enable_tools`[](#idiomatic_version_file_enable_tools)

- Type: `string[]`
- Env: `MISE_IDIOMATIC_VERSION_FILE_ENABLE_TOOLS`
- Default: `[]`

By default, idiomatic version files are disabled. You can enable them for specific tools with this setting.

For example, to enable idiomatic version files for node and python:```
mise settings add idiomatic_version_file_enable_tools node
mise settings add idiomatic_version_file_enable_tools python
```

See [Idiomatic Version Files](https://mise.jdx.dev/configuration.html#idiomatic-version-files) for more information.

## `ignored_config_paths`[](#ignored_config_paths)

- Type: `string[]`
- Env: `MISE_IGNORED_CONFIG_PATHS`
- Default: `[]`

This is a list of config paths that mise will ignore.

This is an early-init setting: it must be set in `.miserc.toml`, environment variables, or CLI flags. Setting it in `mise.toml` will have no effect because config file discovery has already occurred by the time `mise.toml` is read.

Paths are separated by the OS path separator when using the environment variable, `mise settings set`, or `mise settings add` (`:` on Unix, `;` on Windows).

Relative paths in `.miserc.toml` are resolved from the directory containing that file. Relative paths from the environment or CLI are resolved from the directory where mise was invoked. Glob patterns are supported, including recursive `**` patterns. Paths without glob metacharacters retain directory-prefix matching.

## `jobs`[](#jobs)

- Type: `integer`
- Env: `MISE_JOBS`
- Default: `8`

How many jobs to run concurrently such as tool installs. Values below 1 are treated as 1.

## `libc`[](#libc)

- Type: `string`
- Env: `MISE_LIBC`
- Default: `"glibc" | "musl"`
- Choices:
  - `glibc`
  - `gnu`
  - `musl`

Libc implementation to use for precompiled Linux binaries, for backends that publish separate glibc and musl builds.

mise detects the host libc, but only a musl result is carried through: a glibc host is left unqualified rather than pinned to glibc. That distinction matters when a backend selects an asset by name, because an unqualified target can still match a musl artifact on a glibc host. Set this to `gnu` when you need the glibc build specifically — for example when a package publishes both glibc and musl builds and the musl one misbehaves:```toml
[settings]
libc = "gnu"
```

`gnu` is accepted as an alias for `glibc`.

## `locked`[](#locked)

- Type: `boolean`
- Env: `MISE_LOCKED`
- Default: `false`

> \[!NOTE] This setting requires [lockfile](#lockfile) to be enabled.

When enabled, `mise install` will fail if tools don't have pre-resolved URLs in the lockfile for the current platform. This prevents API calls to GitHub, aqua registry, etc. and ensures reproducible installations.

This is useful in CI/CD environments where you want to:
- Avoid GitHub API rate limits
- Ensure deterministic builds using pre-resolved URLs
- Fail fast if the lockfile is incomplete

To generate lockfile URLs, run:```sh
mise lock
```

Equivalent to passing `--locked` to `mise install`.

## `locked_scopes`[](#locked_scopes)

- Type: `string[]`
- Env: `MISE_LOCKED_SCOPES`
- Default: `[ "global", "project", "system" ]`
- Choices:
  - `project`
  - `global`
  - `system`

Restrict invocation-wide locked mode (`--locked`, `MISE_LOCKED=1`, or `locked = true`) to tools originating in the selected config scopes. Valid scopes are `project`, `global` (the user config), and `system`.

For example, distributions that declare rolling tools in system config can exclude those tools while retaining strict locking for project and user-global tools:```toml
[settings]
locked_scopes = ["project", "global"]
```

To lock only project tools, set `locked_scopes = ["project"]`. Explicit tool arguments and environment-supplied tool versions remain subject to invocation-wide locked mode because they do not belong to a config scope. Config-root policy set with `[tool_config] locked = true` is always enforced, even when that scope is absent from this list. Excluding a scope relaxes locked mode for that scope; it does not prevent mise from reading an existing lockfile.

This is a global-only setting so project configuration cannot weaken a user's locked-mode policy. Set it in user-global or system config, or with `MISE_LOCKED_SCOPES`.

## `locked_verify_provenance`[](#locked_verify_provenance)

- Type: `boolean`
- Env: `MISE_LOCKED_VERIFY_PROVENANCE`
- Default: `false`

When enabled, `mise install` will re-verify provenance (SLSA, cosign, minisign, GitHub artifact attestations) at install time even when the lockfile already contains both a checksum and a provenance entry.

By default, when a lockfile has a checksum and provenance type recorded, `mise install` trusts the lockfile and skips re-verification to avoid redundant API calls (e.g., to GitHub). Enabling this setting forces re-verification every time, which provides stronger security guarantees at the cost of additional network requests.

This is automatically enabled when `paranoid` is set to `true`.

## `lockfile`[](#lockfile)

- Type: `boolean`(optional)
- Env: `MISE_LOCKFILE`
- Default: `None`

Read/update lockfiles for tool versions. This is useful when you'd like to have loose versions in mise.toml like this:```toml
[tools]
node = "22"
gh = "latest"
```

But you'd like the versions installed to be consistent within a project. When this is enabled, mise will update mise.lock files next to mise.toml files containing pinned versions. When installing tools, mise will reference this lockfile if it exists and this setting is enabled to resolve versions.

When set to `true` in a TOML settings file, project lockfiles are created and maintained automatically. When unset, existing lockfiles are read and updated but new lockfiles are not created. `MISE_LOCKFILE=1` retains this existing-lockfile behavior for backwards compatibility. To generate one explicitly, run:```sh
mise lock
```

Global lockfiles are only created with `mise lock --global`.

The lockfile is named the same as the config file but with `.lock` instead of `.toml` as the extension, e.g.:
- `mise.toml` -> `mise.lock`
- `mise.local.toml` -> `mise.local.lock`
- `.config/mise.toml` -> `.config/mise.lock`

When set to `true`, project lockfiles are created, read, and written. When set to `false`, lockfiles are explicitly disabled—this will cause an error if `locked = true` is also set, since locked mode requires reading lockfiles. When unset (the default), existing lockfiles are read and written, but new lockfiles are not created.

## `lockfile_mode`[](#lockfile_mode)

- Type: `string`
- Env: `MISE_LOCKFILE_MODE`
- Default: `merge`
- Choices:
  - `merge`
  - `generate`

Set to `generate` to trial complete lockfile generation and concurrent locking during installation. The initial default is `merge`. This setting does not enable lockfile creation: use `lockfile = true` or `mise lock` for that.

## `lockfile_platforms`[](#lockfile_platforms)

- Type: `string[]`(optional)
- Env: `MISE_LOCKFILE_PLATFORMS`(comma separated)
- Default: `None`

Restricts which platforms are included when auto-locking (triggered by `mise install`/`mise use`) or when running `mise lock` without `--platform`. By default (unset), mise targets all common platforms (linux-x64, linux-x64-musl, linux-arm64, linux-arm64-musl, macos-x64, macos-arm64, windows-x64) plus the current platform.

Setting this avoids resolving checksums/URLs for platforms you don't need, keeping lockfiles smaller and `mise install`/`mise use` faster.

Does NOT override explicit `mise lock --platform` flags.```toml
[settings]
lockfile_platforms = ["macos-arm64", "linux-x64"]
```

The current platform is always included in addition to any configured platforms.

Platform format: `os-arch` or `os-arch-qualifier` (e.g., `linux-x64`, `linux-x64-musl`, `macos-arm64`).

## `minimum_release_age`[](#minimum_release_age)

- Type: `string`
- Env: `MISE_MINIMUM_RELEASE_AGE`
- Default: `24h`

Filter tool versions by release date to limit supply chain risk. Similar to Renovate's [minimum release age](https://docs.renovatebot.com/key-concepts/minimum-release-age/), this ensures newly published versions are ignored until they've been available for a configurable amount of time — giving the community time to discover compromised releases. This name matches pnpm's `minimumReleaseAge` setting, though mise accepts both relative durations and absolute cutoff dates.

Supports:

- Relative durations: `7d` (7 days ago), `90d` (90 days ago), `6mo` (6 months ago), `1y` (1 year ago)
- Absolute dates: `2024-06-01`, `2024-06-01T12:00:00Z`

Example:

```toml
[settings]
minimum_release_age = "7d"  # default is 24h
```

Capability depends on what each backend can report or pass through:
- Top-level version filtering: applies to fuzzy version requests when the backend provides release timestamps, such as `aqua:`, `cargo:`, `github:`, `gitlab:`, `go:`, `npm:`, `pypi:`, and many core tools. Versions without timestamps are included by default.
- Transitive dependency filtering during install: only `npm:` and `pypi:` currently forward the cutoff to the package manager. Other backends may still select an older top-level tool version, but they do not constrain dependencies fetched by the tool's installer/compiler.

**Behavior**: For most backends, this filter only applies when resolving fuzzy version requests like `node@20` or `latest`. Explicitly pinned versions like `node@22.5.0` are not filtered, allowing you to selectively use newer versions for specific tools while keeping others behind the cutoff date. Versions selected from `mise.lock` are also not filtered because the lockfile records an already-reviewed top-level selection that must remain reproducible. The `npm:` and `pypi:` backends still apply the cutoff to unpinned transitive dependencies during installation.

For `npm:` and `pypi:` package-manager support details, see the backend docs.

Defaults to `24h`. Set `minimum_release_age = "0s"` to effectively disable the delay.

Can be overridden with the `--minimum-release-age` CLI flag or per-tool with the `minimum_release_age` tool option.```toml
[tools.trivy]
version = "latest"
minimum_release_age = "7d"  # override for this tool only
```

## `minimum_release_age_excludes`[](#minimum_release_age_excludes)

- Type: `string[]`
- Env: `MISE_MINIMUM_RELEASE_AGE_EXCLUDES`(comma separated)
- Default: `[]`

Exclude tools or backends from the global/default [`minimum_release_age`](#minimum_release_age) setting. This is useful for tools where newly published releases are time-sensitive.

Exclusions match any of:
- Backend wildcard: `npm:*`, `pypi:*`, `github:*`
- Registry tool shorthand: `trivy`, `node`
- Full backend ID: `npm:prettier`, `aqua:aquasecurity/trivy`

Example:

```toml
[settings]
minimum_release_age = "7d"
minimum_release_age_excludes = ["trivy", "npm:*"]
```

This excludes matching tools from the global setting and built-in default. A per-tool `minimum_release_age` option or the `--minimum-release-age` CLI flag still applies to matching tools.

Values from multiple configuration files are merged and deduplicated, so a project can add exclusions without repeating exclusions from the global configuration. The environment variable replaces the merged file value.

## `netrc`[](#netrc)

- Type: `boolean`
- Env: `MISE_NETRC`
- Default: `true`

When enabled, mise will read credentials from the netrc file and apply HTTP Basic authentication for matching hosts. This is useful for accessing private artifact repositories like Artifactory or Nexus.

On Unix/macOS, the default path is `~/.netrc`. On Windows, mise looks for `%USERPROFILE%\_netrc` first, then falls back to `%USERPROFILE%\.netrc`.

The netrc file format is:```
machine artifactory.example.com
  login myuser
  password mytoken
```

You can also specify a custom netrc file path using the `netrc_file` setting.

## `netrc_file`[](#netrc_file)

- Type: `string`(optional)
- Env: `MISE_NETRC_FILE`
- Default: `None`

Override the default netrc file path. This is useful if you want to use a different netrc file for mise or if your netrc file is in a non-standard location.

## `no_env`[](#no_env)

- Type: `boolean`(optional)
- Env: `MISE_NO_ENV`
- Default: `None`

Do not load environment variables from config files.

## `no_hooks`[](#no_hooks)

- Type: `boolean`(optional)
- Env: `MISE_NO_HOOKS`
- Default: `None`

Do not execute hooks from config files.

## `not_found_auto_install`[](#not_found_auto_install)

- Type: `boolean`
- Env: `MISE_NOT_FOUND_AUTO_INSTALL`
- Default: `true`

Set to false to disable the "command not found" handler to autoinstall missing tool versions. Disable this if experiencing strange behavior in your shell when a command is not found.

The handler works out which tool provides a command from the `bins` metadata in mise's registry, so it can install a tool that is configured but has never been installed — not only a missing version of a tool you already have.

**Limitation**: this only covers tools mise's registry knows. A tool configured by a raw backend spec (`ubi:owner/repo`, `cargo:…`, `npm:…`) carries no bin metadata, so a command name cannot be traced back to it. Install those explicitly instead — `mise install`, or [`mise x`](https://mise.jdx.dev/cli/exec) to install and run in one step — since both materialise the whole configured toolset whatever the backend. The tool also has to be configured in a config file that applies to the current directory: mise will not install something you have not asked for.

This also runs in shims.

## `not_found_system_fallback`[](#not_found_system_fallback)

- Type: `boolean`
- Env: `MISE_NOT_FOUND_SYSTEM_FALLBACK`
- Default: `true`

When a shim cannot resolve a mise-managed tool, it falls back to the first same-named executable found on `PATH` outside the shims directory. That is useful for tools you also want to work outside of mise, but it means a configured-but-uninstalled version can silently run an unrelated system binary instead of erroring — common for tools the OS also ships, like `python3`.

Set to false, alongside [`not_found_auto_install`](#not_found_auto_install), to make an unresolvable shim fail loudly instead.

## `offline`[](#offline)

- Type: `boolean`
- Env: `MISE_OFFLINE`
- Default: `false`

When enabled, mise will never make HTTP requests. This is useful for air-gapped environments, VPN issues, or when you want to ensure mise only uses locally cached data.

Note: Commands like `hook-env`, `activate`, `exec`, `env`, and shims already avoid most network requests via the `prefer_offline` behavior. Set `offline = true` to completely block all HTTP requests for commands like `mise install` or `mise ls-remote` as well.

Can also be set with the `--offline` CLI flag.

## `os`[](#os)

- Type: `string`
- Env: `MISE_OS`
- Default: `"linux" | "macos" | "windows"`

OS to use for precompiled binaries.

## `override_config_filenames`[](#override_config_filenames)

- Type: `string[]`
- Env: `MISE_OVERRIDE_CONFIG_FILENAMES`(colon separated)
- Default: `[]`

If set, mise will ignore default config files like `mise.toml` and use these filenames instead.

This is an early-init setting: it must be set in `.miserc.toml`, environment variables, or CLI flags. Setting it in `mise.toml` will have no effect because config file discovery has already occurred by the time `mise.toml` is read.

## `override_tool_versions_filenames`[](#override_tool_versions_filenames)

- Type: `string[]`
- Env: `MISE_OVERRIDE_TOOL_VERSIONS_FILENAMES`(colon separated)
- Default: `[]`

If set, mise will ignore .tool-versions files and use these filenames instead. Can be set to `none` to disable .tool-versions entirely.

This is an early-init setting: it must be set in `.miserc.toml`, environment variables, or CLI flags. Setting it in `mise.toml` will have no effect because config file discovery has already occurred by the time `mise.toml` is read.

## `paranoid`[](#paranoid)

- Type: `boolean`
- Env: `MISE_PARANOID`
- Default: `false`

Enables extra-secure behavior. See [Paranoid](https://mise.jdx.dev/paranoid.html).

## `pin`[](#pin)

- Type: `boolean`
- Env: `MISE_PIN`
- Default: `false`

This sets `--pin` by default when running `mise use` in mise.toml files. This can be overridden by passing `--fuzzy` on the command line.

## `plugin_autoupdate_last_check_duration`[](#plugin_autoupdate_last_check_duration)

- Type: `string`
- Env: `MISE_PLUGIN_AUTOUPDATE_LAST_CHECK_DURATION`
- Default: `7d`

How long to wait before updating plugins automatically (note this isn't currently implemented).

## `prefer_offline`[](#prefer_offline)

- Type: `boolean`
- Env: `MISE_PREFER_OFFLINE`
- Default: `false`

When enabled, mise will prefer locally cached data and avoid remote version fetching when possible. Unlike `offline`, this still allows network requests as a fallback.

This is automatically enabled for fast commands like `hook-env`, `activate`, `exec`, `env`, `ls`, `current`, `where`, `which`, and shims.

## `prereleases`[](#prereleases)

- Type: `boolean`
- Env: `MISE_PRERELEASES`
- Default: `false`

By default, releases flagged `prerelease: true` on GitHub/Forgejo are excluded from `mise ls-remote`, `latest` resolution, and fuzzy version matching. Per-tool opt-in is available via the `prerelease = true` tool option (currently honored by the `github:`, `forgejo:`, `aqua:`, and `dotnet:` backends).

Set `prereleases = true` (or `MISE_PRERELEASES=1`) to opt in globally for every tool — equivalent to setting `prerelease = true` on each one. Useful for build pipelines that mirror the full release catalog (e.g. https://github.com/jdx/mise-versions) and for users who want pre-release tags to surface in `mise ls-remote` without per-tool config.

Can also be set with the `--prerelease` flag on `mise ls-remote`.

Has no effect on backends that don't carry an upstream pre-release flag (e.g. `github_tag` version source). Draft releases are always excluded.

## `provenance_api_failures_fatal`[](#provenance_api_failures_fatal)

- Type: `boolean`
- Env: `MISE_PROVENANCE_API_FAILURES_FATAL`
- Default: `true`

When enabled, mise treats provenance API failures as install errors. This keeps provenance strict by default: if a remote attestation or release-provenance API cannot be reached or queried, mise will fail instead of silently installing without provenance.

Set this to `false` to warn and continue when provenance API checks fail. This does not ignore checksum failures, provenance verification mismatches, or lockfiles that already require provenance for the tool being installed.

## `quiet`[](#quiet)

- Type: `boolean`
- Env: `MISE_QUIET`
- Default: `false`

Suppress all output except errors.

## `raw`[](#raw)

- Type: `boolean`
- Env: `MISE_RAW`
- Default: `false`

Connect stdin/stdout/stderr to child processes.

A raw command holds an exclusive lock for as long as it runs, so no other command runs alongside it. Enabling this globally therefore serializes task execution whatever `jobs` is set to: the parallel execution engine still schedules the tasks, but only one of them can be running a command at a time. `mise run --raw` goes further and sets the scheduler itself to a single job.

## `registry_cache_ttl`[](#registry_cache_ttl)

- Type: `string`
- Env: `MISE_REGISTRY_CACHE_TTL`
- Default: `1h`

How long the downloaded mise registry remains fresh when [`registry_floating`](#registry_floating) is enabled. Set to `0s` to check for registry updates every time.

## `registry_floating`[](#registry_floating)

- Type: `boolean`
- Env: `MISE_REGISTRY_FLOATING`
- Default: `false`

Fetch the latest released official mise registry and the current aqua registry, with the snapshots baked into this mise release used as a fallback when a remote registry cannot be loaded.

This is disabled by default because each mise release is tested with its bundled registry snapshots. It can be useful on distributions whose mise package updates lag behind registry changes.

The downloaded mise registry is refreshed only for commands that allow network access and is cached according to [`registry_cache_ttl`](#registry_cache_ttl). Fast and offline commands never refresh it. The downloaded aqua registry uses [`aqua.registry_cache_ttl`](https://mise.jdx.dev/configuration/settings.html#aqua.registry_cache_ttl).

## `safe`[](#safe)

- Type: `boolean`
- Env: `MISE_SAFE`
- Default: `false`

Safe mode is a hard boundary against repo-controlled code execution, designed for running mise against untrusted project configuration — for example a bot that updates `mise.lock` on pull request branches (`mise lock --bump`), or CI jobs that resolve tool versions from configs the operator did not author.

When enabled, mise refuses (with an error, never a silent fallback) to:
- run `exec()` or `read_file()` in config templates
- run hooks
- run tasks
- execute asdf plugin scripts
- install plugins (already-installed and embedded vfox plugins still work — their code was chosen by the operator, not the repository)

It also ignores environment and shell configuration from project (non-global) config — `[env]` values, `_.path`, `_.file`, and `[shell_alias]` entries — since those would be applied to the host environment (env vars and aliases are emitted through `hook-env`) and to subprocesses mise spawns during resolution, an indirect code-execution vector. Global/system config is operator-owned and still applies. `_.source` runs a shell script (code execution rather than env injection), so it is ignored regardless of source.

Version resolution still works for every HTTP-based backend (core, aqua, github, gitlab, http, cargo, pipx, gem, dotnet, npm) as well as `go` (which runs with `GOTOOLCHAIN=local` so a project `go.mod` cannot trigger a toolchain download). Refreshing `mise.lock` and listing installed tools work normally.

## `shared_install_dirs`[](#shared_install_dirs)

- Type: `string[]`(optional)
- Env: `MISE_SHARED_INSTALL_DIRS`
- Default: `None`

A list of additional directories to search for installed tool versions. These directories are checked after the primary install directory (`~/.local/share/mise/installs`) when looking for installed tools. They are read-only—mise will never install tools into these directories.

The system directory `/usr/local/share/mise/installs` (or `MISE_SYSTEM_DATA_DIR/installs`) is always checked automatically when it exists—you do not need to add it here. To populate it, run: `mise install --system node@20`

This is useful for shared environments like Docker containers or bastion hosts where a base set of tools is pre-installed in a shared location, and users can install additional tools in their own directory.

Paths are separated by the OS path separator when using the environment variable, `mise settings set`, or `mise settings add` (`:` on Unix, `;` on Windows).

## `shims_dir`[](#shims_dir)

- Type: `string`(optional)
- Env: `MISE_SHIMS_DIR`
- Default: `None`

The user shim farm. Lazy tools declared in user config publish their bootstrap shims here. The directory must be absolute after `~` expansion. `mise reshim` may publish into a shared executable directory such as `~/.local/bin`; it only replaces or removes entries it recognizes as mise shims. Other mise features filter this directory as one PATH entry, so use a dedicated directory with activation and internal dependency lookups.

## `silent`[](#silent)

- Type: `boolean`
- Env: `MISE_SILENT`
- Default: `false`

Suppress all `mise run|watch` output except errors—including what tasks output.

## `slsa`[](#slsa)

- Type: `boolean`
- Env: `MISE_SLSA`
- Default: `true`

Enable/disable SLSA provenance verification globally for all backends that support it. When enabled, mise will verify the supply-chain integrity of downloaded tools using SLSA provenance attestations.

## `system_config_file`[](#system_config_file)

- Type: `string`(optional)
- Env: `MISE_SYSTEM_CONFIG_FILE`
- Default: `None`

Path to the system mise config file. Default is `/etc/mise/config.toml`. This must be an env var.

## `system_deps`[](#system_deps)

- Type: `string`
- Env: `MISE_SYSTEM_DEPS`
- Default: `prompt`
- Choices:
  - `prompt`
  - `auto`
  - `warn`
  - `ignore`

Controls what mise does when a plugin declares system prerequisites (build tools, libraries, ...) via `PLUGIN.systemDependencies` and one or more are missing before the tool is compiled/installed.

Detection is always the source of truth: a prerequisite that mise can already find on the machine (via any means — Homebrew, apt, nix, MacPorts, from source) is never questioned. This setting only governs what happens for the *missing* subset:
- `prompt` (default) — report the missing capabilities and offer to install them via the first available system package manager. Falls back to `warn` when not running interactively.
- `auto` — install the missing packages without asking (implies the package manager's own non-interactive install; may use sudo per `system_packages.sudo`).
- `warn` — print the missing capabilities and copy-pasteable install commands, then continue with the install anyway.
- `ignore` — do nothing; skip the check entirely.

Missing *optional* dependencies never prompt or fail — they surface as a single informational line regardless of this setting.

## `system_installs_dir`[](#system_installs_dir)

- Type: `string`(optional)
- Env: `MISE_SYSTEM_INSTALLS_DIR`
- Default: `None`

The destination used by `mise install --system` and lazy tools declared in system config. Defaults to `$MISE_SYSTEM_DATA_DIR/installs`. The directory must be absolute after `~` expansion.

## `system_shims_dir`[](#system_shims_dir)

- Type: `string`(optional)
- Env: `MISE_SYSTEM_SHIMS_DIR`
- Default: `None`

The system shim farm populated by `mise reshim --system` and system installs. Defaults to `$MISE_SYSTEM_DATA_DIR/shims`. It may equal `shims_dir`; when it does, mise reconciles one combined farm. The directory must be absolute after `~` expansion.

## `tera_v1`[](#tera_v1)deprecated

- Type: `boolean`
- Env: `MISE_TERA_V1`
- Default: `false`
- Deprecated: tera\_v1 is a temporary compatibility escape hatch for templates that still need Tera v1 behavior. Update templates to Tera v2 syntax instead.

Use Tera v1 instead of Tera v2 for template rendering.

This is a temporary escape hatch for users whose templates still rely on Tera v1 behavior that cannot be fully emulated by mise's Tera v2 compatibility helpers, such as Tera v1 macros or looser undefined variable handling.

For shared `mise.toml` files, prefer setting `MISE_TERA_V1 = true` under `[env]` while migrating. Older mise releases treat that as a regular environment variable instead of failing on an unknown setting.

New templates should use Tera v2 syntax. This setting is scheduled for removal in mise 2027.4.0.

## `terminal_progress`[](#terminal_progress)

- Type: `boolean`
- Env: `MISE_TERMINAL_PROGRESS`
- Default: `true`

Enable terminal progress indicators using OSC 9;4 escape sequences. This provides native progress bars in the terminal window chrome for terminals that support it, including Ghostty, iTerm2, VS Code's integrated terminal, Windows Terminal, and VTE-based terminals (GNOME Terminal, Ptyxis, etc.).

When enabled, mise will send progress updates to the terminal during operations like tool installations. The progress bar appears in the terminal's window UI, separate from the text output.

mise automatically detects whether your terminal supports OSC 9;4 and will only send these sequences if supported. Terminals like Alacritty, WezTerm, and kitty do not support OSC 9;4 and will not receive these sequences.

Set to false to disable this feature if you prefer not to see these indicators.

## `truncate`[](#truncate)

- Type: `boolean`
- Env: `MISE_TRUNCATE`
- Default: `true`

Set to `false` to preserve complete values in terminal-width-aware output such as table cells and task command lines. This does not disable safety limits on captured command output, HTTP response bodies, or history data.

AI coding agents automatically receive untruncated presentation output regardless of this setting. Commands that support truncation also accept `--truncate` and `--no-truncate` for a one-off override.

## `trusted_config_paths`[](#trusted_config_paths)

- Type: `string[]`
- Env: `MISE_TRUSTED_CONFIG_PATHS`
- Default: `[]`

This is a list of config paths that mise will automatically mark as trusted. Any config files under these paths will be trusted without prompting. Set to `["/"]` to trust all config files, effectively disabling the trust mechanism. Paths are separated by the OS path separator when using the environment variable, `mise settings set`, or `mise settings add` (`:` on Unix, `;` on Windows).

## `unix_default_file_shell_args`[](#unix_default_file_shell_args)

- Type: `string`
- Env: `MISE_UNIX_DEFAULT_FILE_SHELL_ARGS`
- Default: `sh`

Default shell arguments for Unix to be used for file commands. For example, `sh` for sh.

## `unix_default_inline_shell_args`[](#unix_default_inline_shell_args)

- Type: `string`
- Env: `MISE_UNIX_DEFAULT_INLINE_SHELL_ARGS`
- Default: `sh -o errexit -c`

Default shell arguments for Unix to be used for inline commands. For example, `sh -c` for sh.

## `url_replacements`[](#url_replacements)

- Type: `object`(optional)
- Env: `MISE_URL_REPLACEMENTS`
- Default: `None`

Map of URL patterns to replacement URLs. This feature supports both simple hostname replacements and advanced regex-based URL transformations for download mirroring and custom registries.

See [URL Replacements](https://mise.jdx.dev/url-replacements.html) for more information.

## `use_file_shell_for_executable_tasks`[](#use_file_shell_for_executable_tasks)

- Type: `boolean`
- Env: `MISE_USE_FILE_SHELL_FOR_EXECUTABLE_TASKS`
- Default: `false`

Determines whether to use a specified shell for executing tasks in the tasks directory. When set to true, the shell defined in the file will be used, or the default shell specified by `windows_default_file_shell_args` or `unix_default_file_shell_args` will be applied. If set to false, tasks will be executed directly as programs.

## `use_versions_host`[](#use_versions_host)

- Type: `boolean`
- Env: `MISE_USE_VERSIONS_HOST`
- Default: `true`

Set to "false" to disable using [mise-versions](https://mise-versions.jdx.dev) as a shared cache for version lists, public GitHub release metadata, and GitHub artifact attestations.

This host regularly grabs all the latest versions of core and community plugins. It's faster than running a plugin's `list-all` command and gets around GitHub rate limiting problems when using it. For tools distributed through public GitHub releases, mise also uses this host before calling GitHub's releases and artifact attestation APIs directly. This avoids the anonymous GitHub API rate limit in normal installs, including Docker builds and CI jobs that do not have a GitHub token configured.

If the versions host does not have the requested metadata yet, mise falls back to GitHub's API. Private repositories, GitHub Enterprise, custom GitHub API URLs, and users who disable this setting still need normal GitHub authentication when they would otherwise exceed GitHub's rate limits.

mise-versions itself also struggles with rate limits but you can help it to fetch more frequently by authenticating with its [GitHub app](https://github.com/apps/mise-versions). It does not require any permissions since it simply fetches public repository information.

See [Troubleshooting](https://mise.jdx.dev/troubleshooting.html#new-version-of-a-tool-is-not-available) for more information.

## `use_versions_host_track`[](#use_versions_host_track)

- Type: `boolean`
- Env: `MISE_USE_VERSIONS_HOST_TRACK`
- Default: `true`

When enabled, mise sends anonymous download statistics to mise-versions.jdx.dev after successfully installing a tool. This helps show tool popularity on [mise-versions.jdx.dev](https://mise-versions.jdx.dev).

Data collected:
- Tool name and version
- OS and architecture (from User-Agent)
- Hashed IP address (for daily deduplication, not stored raw)

This is automatically disabled if `use_versions_host` is set to false. Set to false to opt-out of anonymous statistics collection.

## `verbose`[](#verbose)

- Type: `boolean`
- Env: `MISE_VERBOSE`
- Default: `false`

Shows more verbose output such as installation logs when installing tools.

## `windows_default_file_shell_args`[](#windows_default_file_shell_args)

- Type: `string`
- Env: `MISE_WINDOWS_DEFAULT_FILE_SHELL_ARGS`
- Default: `cmd /c`

Default shell arguments for Windows to be used for file commands. For example, `cmd /c` for cmd.exe.

## `windows_default_inline_shell_args`[](#windows_default_inline_shell_args)

- Type: `string`
- Env: `MISE_WINDOWS_DEFAULT_INLINE_SHELL_ARGS`
- Default: `cmd /c`

Default shell arguments for Windows to be used for inline commands. For example, `cmd /c` for cmd.exe.

## `windows_executable_extensions`[](#windows_executable_extensions)

- Type: `string[]`
- Env: `MISE_WINDOWS_EXECUTABLE_EXTENSIONS`(comma separated)
- Default: `[ "exe", "bat", "cmd", "com", "ps1", "vbs" ]`

List of executable extensions for Windows. For example, `exe` for .exe files, `bat` for .bat files, and so on.

## `windows_powershell_no_profile`[](#windows_powershell_no_profile)

- Type: `boolean`
- Env: `MISE_WINDOWS_POWERSHELL_NO_PROFILE`
- Default: `true`

When mise runs a task or inline command through PowerShell, it passes `-NoProfile` so the shell does not load the user's PowerShell profile. This matches the non-interactive behavior of `sh -c` / `zsh -c` on Unix, which do not source interactive startup files.

Profiles that mutate `PATH` — for example a mise activation snippet that prepends the shims directory — can otherwise shadow a task's own installed tools and produce confusing `cannot find binary path` errors.

Set to `false` if your tasks rely on side effects from your PowerShell profile (environment variables, functions, aliases). This only affects `pwsh` and `powershell`; it has no effect on `cmd` or on non-Windows shells.

## `windows_shim_mode`[](#windows_shim_mode)

- Type: `string`
- Env: `MISE_WINDOWS_SHIM_MODE`
- Default: `exe`

- values:
  - `exe`: Copies a native executable shim ( `mise-shim.exe`) as `<tool>.exe`. Recommended. Works with all shells, package managers, and `where.exe`. Requires `mise-shim.exe` alongside `mise.exe`.
  - `file`: Creates a `.cmd` batch file shim and an extensionless bash script for Git Bash/Cygwin.
  - `hardlink`: Uses Windows NTFS Hardlink, required on same filesystems. Need run `mise reshim --force` after upgrade mise.
  - `symlink`: Uses Windows NTFS SymbolicLink. Requires Windows Vista or later with admin privileges or enabling "Developer Mode" in Windows 10/11.

## `yes`[](#yes)

- Type: `boolean`
- Env: `MISE_YES`
- Default: `false`

This will automatically answer yes or no to prompts. This is useful for scripting.

## `age`[](#age)

### `age.identity_files`[](#age.identity_files)

- Type: `string[]`(optional)
- Env: `MISE_AGE_IDENTITY_FILES`
- Default: `None`

List of age identity files to use for decryption (encrypted shared dotfiles and the experimental `[env]` age directives).

### `age.key_file`[](#age.key_file)

- Type: `string`
- Env: `MISE_AGE_KEY_FILE`
- Default: `~/.config/mise/age.txt`

Path to the age private key file to use for encryption/decryption: the default recipient and identity for encrypted shared dotfiles and the key for the experimental `[env]` age directives.

### `age.ssh_identity_files`[](#age.ssh_identity_files)

- Type: `string[]`(optional)
- Env: `MISE_AGE_SSH_IDENTITY_FILES`
- Default: `None`

List of SSH identity files to use for age decryption (encrypted shared dotfiles and the experimental `[env]` age directives).

### `age.strict`[](#age.strict)

- Type: `boolean`
- Env: `MISE_AGE_STRICT`
- Default: `true`

If true, fail when age decryption fails (including when age is not available, the key is missing, or the key is invalid). If false, skip decryption and continue in these cases.

## `aqua`[](#aqua)

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

## `cargo`[](#cargo)

### `cargo.binstall`[](#cargo.binstall)

- Type: `boolean`
- Env: `MISE_CARGO_BINSTALL`
- Default: `true`

If true, mise will use `cargo binstall` instead of `cargo install` if [`cargo-binstall`](https://crates.io/crates/cargo-binstall) is installed and on PATH. This makes installing CLIs with cargo *much* faster by downloading precompiled binaries.

When `cargo-binstall` installs a prebuilt binary, Cargo build settings and `cargo install` behavior do not affect the downloaded artifact. Set `cargo.binstall = false` to force `cargo install` when you need Cargo settings to control the install.

When mise invokes external `cargo-binstall`, it disables cargo-binstall's `compile` strategy. If cargo-binstall reports that no prebuilt artifact is available (exit code 94), mise runs `cargo install` itself. Other cargo-binstall errors do not trigger this fallback. When `cargo.binstall_only = true`, Cargo tools without an explicit Git source must be installed by cargo-binstall: mise does not fall back to `cargo install`, and options that require `cargo install` produce an error. Explicit Git sources are unaffected because they always use `cargo install --git`.

You can install it with mise:```sh
mise use -g cargo-binstall
```

### `cargo.binstall_native`[](#cargo.binstall_native)

- Type: `boolean`(optional)
- Env: `MISE_CARGO_BINSTALL_NATIVE`
- Default: `None`

Controls mise's native cargo binary installer, which downloads precompiled binaries using conventional GitHub release artifact names from the crate's linked repository or `package.metadata.binstall` from its `Cargo.toml` when `cargo-binstall` is not installed.
- If `true`: Try mise's native cargo binary installer first, fall back to `cargo install` if unavailable.
- If `false`: Do not use mise's native cargo binary installer.
- If unset: Native installs are disabled for now. Starting in mise `2027.1.0`, mise will warn when a cargo package could have been installed from a native binary artifact. In mise `2027.7.0`, unset will default to native binary installs and this setting will become a two-way switch.

Set `cargo.binstall = false` to force `cargo install` instead of either `cargo-binstall` or mise's native cargo binary installer.

This is a best-effort fast path. If neither compatible metadata nor a conventionally named GitHub release artifact is available, or the install uses Cargo build options that would change the resulting binary, mise falls back to `cargo install`.

### `cargo.binstall_only`[](#cargo.binstall_only)

- Type: `boolean`
- Env: `MISE_CARGO_BINSTALL_ONLY`
- Default: `false`

Require cargo-binstall for Cargo tools without an explicit Git source. Fail if no prebuilt binary is available or if tool options require cargo install.

### `cargo.binstall_quickinstall`[](#cargo.binstall_quickinstall)

- Type: `boolean`
- Env: `MISE_CARGO_BINSTALL_QUICKINSTALL`
- Default: `false`

If true, mise allows the external `cargo-binstall` binary to use artifacts from the third-party [cargo-quickinstall](https://github.com/cargo-bins/cargo-quickinstall) host. These artifacts are separate from crate-author GitHub releases and artifacts declared in `package.metadata.binstall`.

By default, mise passes `--disable-strategies compile,quick-install` when invoking the external `cargo-binstall` binary. The `compile` strategy is always disabled; setting this to `true` changes the flag to `--disable-strategies compile`. This setting does not affect mise's `cargo.binstall_native` path, which does not use quickinstall.

This only controls external `cargo-binstall`'s quick-install strategy. To disable binstall, set `cargo.binstall = false`.

### `cargo.registry_name`[](#cargo.registry_name)

- Type: `string`(optional)
- Env: `MISE_CARGO_REGISTRY_NAME`
- Default: `None`

Packages are installed from the official cargo registry.

You can set this to a different registry name if you have a custom feed or want to use a different source.

Please follow the [cargo alternative registries documentation](https://doc.rust-lang.org/cargo/reference/registries.html#using-an-alternate-registry) to configure your registry.

## `conda`[](#conda)

### `conda.channel`[](#conda.channel)

- Type: `string`
- Env: `MISE_CONDA_CHANNEL`
- Default: `conda-forge`

Default conda channel when installing packages with the conda backend. Override per-package with `conda:package[channel=bioconda]`.

The most common channels are:
- `conda-forge` - Community-maintained packages (default)
- `bioconda` - Bioinformatics packages
- `nvidia` - NVIDIA CUDA packages

## `dotfiles`[](#dotfiles)

### `dotfiles.default_mode`[](#dotfiles.default_mode)

- Type: `string`
- Env: `MISE_DOTFILES_DEFAULT_MODE`
- Default: `symlink`

Default mode for dotfile entries when mode is omitted. Options: `symlink`, `symlink-each`, `copy`, `template`.

### `dotfiles.root`[](#dotfiles.root)

- Type: `string`
- Env: `MISE_DOTFILES_ROOT`
- Default: `~/.dotfiles`

Root directory used for implied dotfile sources.

## `dotnet`[](#dotnet)

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

## `erlang`[](#erlang)

### `erlang.compile`[](#erlang.compile)

- Type: `boolean`(optional)
- Env: `MISE_ERLANG_COMPILE`
- Default: `None`

If true, compile erlang from source. If false, use precompiled binaries. If not set, use precompiled binaries if available.

### `erlang.precompiled_os`[](#erlang.precompiled_os)

- Type: `string`(optional)
- Env: `MISE_ERLANG_PRECOMPILED_OS`
- Default: `None`

Ubuntu release target to use for precompiled Erlang builds from builds.hex.pm.

## `forgejo`[](#forgejo)

### `forgejo.credential_command`[](#forgejo.credential_command)

- Type: `string`
- Env: `MISE_FORGEJO_CREDENTIAL_COMMAND`
- Default:

When set, mise executes this command via `sh -c` and reads the token from stdout. The hostname is exposed as `MISE_CREDENTIAL_HOST`, making the command host-aware for self-hosted Forgejo environments. This replaces the `git credential fill` fallback and does not require `forgejo.use_git_credentials` to be enabled.

The command should print a single token to stdout. Trailing whitespace is trimmed.

Example: `op read "op://Private/Forgejo Token/credential"`

### `forgejo.fj_cli_tokens`[](#forgejo.fj_cli_tokens)

- Type: `boolean`
- Env: `MISE_FORGEJO_FJ_CLI_TOKENS`
- Default: `true`

When enabled, mise will read tokens from the fj CLI keys file (`~/.local/share/forgejo-cli/keys.json` on Linux, `~/Library/Application Support/forgejo-cli.forgejo-cli/keys.json` on macOS, with the legacy `Cyborus.forgejo-cli` location as a fallback). This is used as a fallback when no `FORGEJO_TOKEN` or `MISE_FORGEJO_TOKEN` environment variable is set.

Set to `false` to disable this behavior.

### `forgejo.use_git_credentials`[](#forgejo.use_git_credentials)

- Type: `boolean`
- Env: `MISE_FORGEJO_USE_GIT_CREDENTIALS`
- Default: `false`

When enabled, mise will run `git credential fill` to obtain Forgejo tokens using the credential helpers configured in your `.gitconfig`.

This covers tokens stored in system keyrings (macOS Keychain, Windows Credential Manager), and any other git credential helper.

Used as a last resort — after environment variables, `forgejo_tokens.toml`, and fj CLI tokens are checked. Results are cached per host for the duration of the session.

Set to `true` to enable this behavior.

## `github`[](#github)

### `github.credential_command`[](#github.credential_command)

- Type: `string`
- Env: `MISE_GITHUB_CREDENTIAL_COMMAND`
- Default:

When set, mise executes this command via `sh -c` and reads the token from stdout. The hostname is exposed as `MISE_CREDENTIAL_HOST`, making the command host-aware for GitHub Enterprise environments. This replaces the `git credential fill` fallback and does not require `github.use_git_credentials` to be enabled.

The command should print a single token to stdout. Trailing whitespace is trimmed.

Example: `op read "op://Private/GitHub Token/credential"`

### `github.gh_cli_tokens`[](#github.gh_cli_tokens)

- Type: `boolean`
- Env: `MISE_GITHUB_GH_CLI_TOKENS`
- Default: `true`

When enabled, mise will read OAuth tokens from the gh CLI config file (`~/.config/gh/hosts.yml` or `$GH_CONFIG_DIR/hosts.yml`) as a fallback when no `GITHUB_TOKEN` or `MISE_GITHUB_TOKEN` environment variable is set.

This supports multiple GitHub Enterprise instances since the gh CLI stores per-host tokens.

Set to `false` to disable this behavior.

### `github.github_attestations`[](#github.github_attestations)

- Type: `boolean`
- Env: `MISE_GITHUB_GITHUB_ATTESTATIONS`
- Default: `true`

Enable/disable GitHub Artifact Attestations verification for github backend tools. When enabled, mise will verify the authenticity and integrity of downloaded tools using GitHub's artifact attestation system.

Attestations are only verified when the tool resolves to the public GitHub API (`https://api.github.com`). Tools that set a custom `api_url` (e.g. GitHub Enterprise Server) skip attestation verification automatically since GHE Server does not implement the attestations endpoint.

### `github.oauth_api_url`[](#github.oauth_api_url)

- Type: `string`
- Env: `MISE_GITHUB_OAUTH_API_URL`
- Default: `https://api.github.com`

GitHub API base URL used to validate native OAuth tokens and associate them with the configured host.

### `github.oauth_auth_url`[](#github.oauth_auth_url)

- Type: `string`
- Env: `MISE_GITHUB_OAUTH_AUTH_URL`
- Default: `https://github.com/login`

OAuth endpoint base URL used by native GitHub device flow. The default is for github.com. Set this for GitHub Enterprise instances that support device flow.

### `github.oauth_client_id`[](#github.oauth_client_id)

- Type: `string`
- Env: `MISE_GITHUB_OAUTH_CLIENT_ID`
- Default:

When set, mise can create short-lived GitHub App user access tokens using GitHub's OAuth device flow. This does not require a GitHub App private key, client secret, personal access token, or external credential helper.

Run `mise token github --oauth` once to authorize and cache a token. mise will reuse the cached token for GitHub API calls and refresh it when possible.

Inspired by [ghtkn](https://github.com/suzuki-shunsuke/ghtkn).

### `github.oauth_export_env`[](#github.oauth_export_env)

- Type: `string`
- Env: `MISE_GITHUB_OAUTH_EXPORT_ENV`
- Default: `GITHUB_TOKEN`

When `github.oauth_client_id` is configured and a cached or refreshable token is available, mise exports the token under this environment variable so other tools (`gh`, `git`, `cargo`, etc.) can pick it up without an explicit `$(mise token github --oauth --raw)` call. Set to `GH_TOKEN` to use the gh CLI's preferred name, or to an empty string to disable the auto-export.

### `github.oauth_open_browser`[](#github.oauth_open_browser)

- Type: `boolean`
- Env: `MISE_GITHUB_OAUTH_OPEN_BROWSER`
- Default: `true`

When enabled, `mise token github --oauth` will attempt to open GitHub's verification URL in the default browser when the device-code flow is triggered.

### `github.oauth_scopes`[](#github.oauth_scopes)

- Type: `string`
- Env: `MISE_GITHUB_OAUTH_SCOPES`
- Default:

Optional OAuth scope string passed to GitHub's device-code endpoint. GitHub App user access tokens are primarily governed by the app's permissions and installation access, so this usually remains empty.

### `github.slsa`[](#github.slsa)

- Type: `boolean`
- Env: `MISE_GITHUB_SLSA`
- Default: `true`

Enable/disable SLSA provenance verification for github backend tools. When enabled, mise will verify the supply-chain integrity of downloaded tools using SLSA provenance attestations.

### `github.use_git_credentials`[](#github.use_git_credentials)

- Type: `boolean`
- Env: `MISE_GITHUB_USE_GIT_CREDENTIALS`
- Default: `false`

When enabled, mise will run `git credential fill` to obtain GitHub tokens using the credential helpers configured in your `.gitconfig`.

This covers tokens stored in system keyrings (macOS Keychain, Windows Credential Manager), and any other git credential helper.

Used as a last resort — after environment variables, `github_tokens.toml`, and gh CLI tokens are checked. Results are cached per host for the duration of the session.

Set to `true` to enable this behavior.

## `github_relay`[](#github_relay)

### `github_relay.concurrency`[](#github_relay.concurrency)

- Type: `integer`
- Env: `MISE_GITHUB_RELAY_CONCURRENCY`
- Default: `8`

Maximum simultaneous GitHub relay requests (1-32); excess requests fail closed.

### `github_relay.log_format`[](#github_relay.log_format)

- Type: `string`
- Env: `MISE_GITHUB_RELAY_LOG_FORMAT`
- Default: `text`

GitHub relay request and summary output format: text or jsonl.

### `github_relay.log_requests`[](#github_relay.log_requests)

- Type: `boolean`
- Env: `MISE_GITHUB_RELAY_LOG_REQUESTS`
- Default: `false`

Log sanitized GitHub relay requests on the initiating machine's stderr.

### `github_relay.max_duration`[](#github_relay.max_duration)

- Type: `string`
- Env: `MISE_GITHUB_RELAY_MAX_DURATION`
- Default: `0s`

Maximum borrowed GitHub access duration; 0s means until the session ends.

### `github_relay.request_timeout`[](#github_relay.request_timeout)

- Type: `string`
- Env: `MISE_GITHUB_RELAY_REQUEST_TIMEOUT`
- Default: `5m`

Total time limit for a relayed request, including response streaming.

## `gitlab`[](#gitlab)

### `gitlab.credential_command`[](#gitlab.credential_command)

- Type: `string`
- Env: `MISE_GITLAB_CREDENTIAL_COMMAND`
- Default:

When set, mise executes this command via `sh -c` and reads the token from stdout. The hostname is exposed as `MISE_CREDENTIAL_HOST`, making the command host-aware for self-managed GitLab environments. This replaces the `git credential fill` fallback and does not require `gitlab.use_git_credentials` to be enabled.

The command should print a single token to stdout. Trailing whitespace is trimmed.

Example: `op read "op://Private/GitLab Token/credential"`

### `gitlab.glab_cli_tokens`[](#gitlab.glab_cli_tokens)

- Type: `boolean`
- Env: `MISE_GITLAB_GLAB_CLI_TOKENS`
- Default: `true`

When enabled, mise will read tokens from the glab CLI config file (`~/.config/glab-cli/config.yml` or `$GLAB_CONFIG_DIR/config.yml`) as a fallback when no `GITLAB_TOKEN` or `MISE_GITLAB_TOKEN` environment variable is set.

Set to `false` to disable this behavior.

### `gitlab.use_git_credentials`[](#gitlab.use_git_credentials)

- Type: `boolean`
- Env: `MISE_GITLAB_USE_GIT_CREDENTIALS`
- Default: `false`

When enabled, mise will run `git credential fill` to obtain GitLab tokens using the credential helpers configured in your `.gitconfig`.

This covers tokens stored in system keyrings (macOS Keychain, Windows Credential Manager), and any other git credential helper.

Used as a last resort — after environment variables, `gitlab_tokens.toml`, and glab CLI tokens are checked. Results are cached per host for the duration of the session.

Set to `true` to enable this behavior.

## `go`[](#go)

### `go.default_packages_file`[](#go.default_packages_file)deprecated

- Type: `string`
- Env: `MISE_GO_DEFAULT_PACKAGES_FILE`
- Default: `~/.default-go-packages`
- Deprecated: Default go package files are deprecated. Use tool-level postinstall hooks for packages that should be installed into every go version, or use the go: backend for CLI tools.

Path to a file containing default go packages to install when installing go.

### `go.download_mirror`[](#go.download_mirror)

- Type: `string`
- Env: `MISE_GO_DOWNLOAD_MIRROR`
- Default: `https://dl.google.com/go`

Mirror to download go sdk tarballs from.

### `go.repo`[](#go.repo)

- Type: `string`
- Env: `MISE_GO_REPO`
- Default: `https://github.com/golang/go`

URL to fetch go from.

### `go.set_gobin`[](#go.set_gobin)

- Type: `boolean`(optional)
- Env: `MISE_GO_SET_GOBIN`
- Default: `None`

Defaults to `~/.local/share/mise/installs/go/.../bin`. Set to `true` to override GOBIN if previously set. Set to `false` to not set GOBIN (default is `${GOPATH:-$HOME/go}/bin`).

### `go.set_gopath`[](#go.set_gopath)deprecated

- Type: `boolean`
- Env: `MISE_GO_SET_GOPATH`
- Default: `false`
- Deprecated: mise no longer manages GOPATH. Set GOPATH in \[env] if you need a specific value.

\[deprecated] Set to true to set GOPATH=\~/.local/share/mise/installs/go/.../packages.

### `go.set_goroot`[](#go.set_goroot)

- Type: `boolean`
- Env: `MISE_GO_SET_GOROOT`
- Default: `true`

Sets GOROOT=\~/.local/share/mise/installs/go/.../.

### `go.skip_checksum`[](#go.skip_checksum)

- Type: `boolean`
- Env: `MISE_GO_SKIP_CHECKSUM`
- Default: `false`

Set to true to skip checksum verification when downloading go sdk tarballs.

## `history`[](#history)

### `history.allow_plaintext_history`[](#history.allow_plaintext_history)

- Type: `boolean`
- Env: `MISE_HISTORY_ALLOW_PLAINTEXT_HISTORY`
- Default: `false`

Skips the plaintext history check when manual commands or the history watcher publish or apply setup history. Older unencrypted contents can reach this machine or be published to the origin. New saves still follow each file's encryption policy. Set this in global settings, or use `mise dot sync --allow-plaintext-history` for one publication.

### `history.describe_command`[](#history.describe_command)

- Type: `string`
- Env: `MISE_HISTORY_DESCRIBE_COMMAND`
- Default:

The checkpoint is saved before the command runs and keeps its computed description when the command fails, prints nothing, or takes longer than 30 seconds. It runs once per checkpoint the watcher saved, never per filesystem event or retry, one at a time. Excluded files are not captured or named, and encrypted files never have their contents sent.

### `history.enabled`[](#history.enabled)

- Type: `boolean`
- Env: `MISE_HISTORY_ENABLED`
- Default: `true`

With explicit enrollment or existing tracked history, `mise bootstrap` and `mise bootstrap <part> apply` record before/after commits. `mise bootstrap dotfiles save` explicitly commits tracked changes. Git history lives under `$MISE_STATE_DIR/history/repo.git`; `mise bootstrap dotfiles history` lists and compares its file versions. Bootstrap without tracking does not start a committed history, and dry runs never record. Set to `false` to turn recording off without deleting existing commits.

### `history.fetch_interval`[](#history.fetch_interval)

- Type: `string`
- Env: `MISE_HISTORY_FETCH_INTERVAL`
- Default: `15m`

How often the history watcher fetches the origin branch. Values below one second use one second; use history.sync = 'manual' to disable automatic synchronization.

### `history.notify`[](#history.notify)

- Type: `boolean`
- Env: `MISE_HISTORY_NOTIFY`
- Default: `true`

On Linux, notifications require `notify-send`. On macOS, allow notifications for mise when prompted. Unofficial macOS builds, such as Homebrew, warn when connecting a setup repository because notifications are unavailable. Unsupported platforms log the conflict only. `mise bootstrap dotfiles status` and `mise doctor` show the same conflicts without notifications.

### `history.sync`[](#history.sync)

- Type: `string`
- Env: `MISE_HISTORY_SYNC`
- Default: `sync`
- Choices:
  - `sync`
  - `fetch-only`
  - `manual`

Chosen and disclosed by `mise bootstrap dotfiles origin set`. Publication happens at most every `history.sync_interval` after a save, fetching every `history.fetch_interval`; failures back off (one minute doubling to an hour) and local saves continue meanwhile. Applying never runs `mise bootstrap`, installs packages, or renders templates: when incoming configuration changes declarations, `mise bootstrap dotfiles status` says to run `mise bootstrap`.

### `history.sync_interval`[](#history.sync_interval)

- Type: `string`
- Env: `MISE_HISTORY_SYNC_INTERVAL`
- Default: `5m`

How soon after a save the history watcher publishes to the setup repository, at most this often.

### `history.watch.debounce`[](#history.watch.debounce)

- Type: `string`
- Env: `MISE_HISTORY_WATCH_DEBOUNCE`
- Default: `2s`

How long a changed file must stay quiet before the history watcher saves it (the base autosave interval). A file that keeps changing is stretched on its own and never delays the others.

### `history.watch.max_interval`[](#history.watch.max_interval)

- Type: `string`
- Env: `MISE_HISTORY_WATCH_MAX_INTERVAL`
- Default: `24h`

Ordinary edits are saved after `history.watch.debounce`. A file that keeps being rewritten is still saved periodically, ever more rarely, up to this interval; other files are never delayed by it. Constantly rewritten application state, logs, caches, and databases are better excluded (`mise bootstrap dotfiles exclude`); a file that genuinely holds configuration but changes constantly can be tracked with `autosave = false` and saved explicitly. Nothing is excluded or switched to manual saving automatically.

### `history.watch.reconcile`[](#history.watch.reconcile)

- Type: `string`
- Env: `MISE_HISTORY_WATCH_RECONCILE`
- Default: `10m`

How often the history watcher rescans the whole tracked set for changes its watches missed. `0` disables periodic reconciliation (startup and configuration changes still reconcile).

## `hook_env`[](#hook_env)

### `hook_env.cache_ttl`[](#hook_env.cache_ttl)

- Type: `string`
- Env: `MISE_HOOK_ENV_CACHE_TTL`
- Default: `0s`

On slow filesystems (like NFS with cold cache), mise's hook-env can be slow due to multiple filesystem stat operations. Setting this to a positive value (e.g., "5s") will cache the results of directory traversal and only re-check after the TTL expires.

When set to "0s" (default), no caching is performed and every hook-env call will check the filesystem for changes. This is the safest option but slowest on NFS.

Note: When caching is enabled, newly created config files may not be detected until the TTL expires. Use `mise hook-env --force` to bypass the cache.

### `hook_env.chpwd_only`[](#hook_env.chpwd_only)

- Type: `boolean`
- Env: `MISE_HOOK_ENV_CHPWD_ONLY`
- Default: `false`

When enabled, mise will only perform full config file checks when the directory changes (chpwd), not on every shell prompt (precmd). This significantly reduces filesystem operations on slow filesystems like NFS.

With this enabled, changes to config files will not be detected until you change directories. Use `mise hook-env --force` to manually trigger a full update.

This setting is useful when:
- You're working on an NFS filesystem with slow stat operations
- Config files rarely change during a session
- You want the fastest possible shell prompt response time

## `java`[](#java)

### `java.shorthand_vendor`[](#java.shorthand_vendor)

- Type: `string`
- Env: `MISE_JAVA_SHORTHAND_VENDOR`
- Default: `openjdk`

Shorthand for Java. Used when installing Java without a vendor prefix.

## `node`[](#node)

### `node.apply_patches`[](#node.apply_patches)

- Type: `string`(optional)
- Env: `MISE_NODE_APPLY_PATCHES`
- Default: `None`

Newline-separated list of patch files or URLs, applied to the extracted node source before `./configure` runs.

They only reach a source build. `node.compile = true` forces one; failing that, they still apply whenever no precompiled archive exists for the version and mise falls back to compiling on its own. When a precompiled binary is what gets installed, mise warns rather than dropping the patches silently.

### `node.cflags`[](#node.cflags)

- Type: `string`(optional)
- Env: `MISE_NODE_CFLAGS`
- Default: `None`

Additional CFLAGS options (e.g., to override -O3).

### `node.compile`[](#node.compile)

- Type: `boolean`(optional)
- Env: `MISE_NODE_COMPILE`
- Default: `None`

Compile node from source.

### `node.concurrency`[](#node.concurrency)

- Type: `integer`
- Env: `MISE_NODE_CONCURRENCY`
- Default: `Number of physical CPUs (unless ninja is enabled)`

Number of parallel jobs for node compilation. Defaults to the number of physical CPU cores when using make. When ninja is enabled, this defaults to unset (ninja handles concurrency automatically).

### `node.configure_opts`[](#node.configure_opts)

- Type: `string`(optional)
- Env: `MISE_NODE_CONFIGURE_OPTS`
- Default: `None`

Additional ./configure options.

### `node.corepack`[](#node.corepack)

- Type: `boolean`
- Env: `MISE_NODE_COREPACK`
- Default: `false`

Installs the default corepack shims after installing any node version.

### `node.default_packages_file`[](#node.default_packages_file)deprecated

- Type: `string`
- Env: `MISE_NODE_DEFAULT_PACKAGES_FILE`
- Default: `~/.default-npm-packages`
- Deprecated: Default npm package files are deprecated. Use tool-level postinstall hooks for packages that should be installed into every node version, or use the npm: backend for CLI tools.

Path to a file containing packages to install with npm after installing a new Node.js version. Defaults to `~/.default-npm-packages`. Also checks `~/.default-nodejs-packages` and `~/.default-node-packages` for backwards compatibility.

Format: one package per line, with optional version specifier:```
lodash
typescript@latest
@types/node@^20
```

### `node.flavor`[](#node.flavor)

- Type: `string`(optional)
- Env: `MISE_NODE_FLAVOR`
- Default: `None`

Install a specific node flavor like glibc-217 or musl. Use with unofficial node build repo.

### `node.gpg_verify`[](#node.gpg_verify)

- Type: `boolean`(optional)
- Env: `MISE_NODE_GPG_VERIFY`
- Default: `None`

Verify OpenPGP signatures for node (built-in, no external gpg required). Set to false to disable.

### `node.make`[](#node.make)

- Type: `string`(optional)
- Env: `MISE_NODE_MAKE`
- Default: `None`

Make command to use.

### `node.make_install_opts`[](#node.make_install_opts)

- Type: `string`(optional)
- Env: `MISE_NODE_MAKE_INSTALL_OPTS`
- Default: `None`

Additional make install options.

### `node.make_opts`[](#node.make_opts)

- Type: `string`(optional)
- Env: `MISE_NODE_MAKE_OPTS`
- Default: `None`

Additional make options.

### `node.mirror_url`[](#node.mirror_url)

- Type: `string`(optional)
- Env: `MISE_NODE_MIRROR_URL`
- Default: `None`

Mirror to download node tarballs from.

### `node.ninja`[](#node.ninja)

- Type: `boolean`
- Env: `MISE_NODE_NINJA`
- Default: `Auto-detected: true if ninja is on PATH`

If true, use ninja build system instead of make for faster compilation. Defaults to true if `ninja` is found on PATH, false otherwise.

Ninja is generally faster than make for incremental builds.

### `node.nodenv_root`[](#node.nodenv_root)

- Type: `string`
- Env: `NODENV_ROOT`
- Default: `~/.nodenv`

Directory for nodenv.

### `node.npm_shim`[](#node.npm_shim)

- Type: `boolean`
- Env: `MISE_NODE_NPM_SHIM`
- Default: `true`

Install a bash wrapper at bin/npm that triggers `mise reshim` after `npm install -g`. Disable to let corepack or a global `npm install -g npm@...` manage `bin/npm` directly.

### `node.nvm_dir`[](#node.nvm_dir)

- Type: `string`
- Env: `NVM_DIR`
- Default: `~/.nvm`

Directory for nvm.

### `node.verify`[](#node.verify)

- Type: `boolean`
- Env: `MISE_NODE_VERIFY`
- Default: `true`

Verify the downloaded assets using GPG.

## `npm`[](#npm)

### `npm.package_manager`[](#npm.package_manager)

- Type: `string`
- Env: `MISE_NPM_PACKAGE_MANAGER`
- Default: `auto`
- Choices:
  - `auto`
  - `npm`
  - `aube`
  - `aube_cli`
  - `bun`
  - `pnpm`

Package manager to use for installing npm packages. The default, `auto`, uses mise's embedded `aube` package manager. Set this to `aube_cli` to invoke a standalone aube executable, or to `npm`, `bun`, or `pnpm` to invoke that package manager instead.

### `npm.shell_out`[](#npm.shell_out)

- Type: `boolean`
- Env: `MISE_NPM_SHELL_OUT`
- Default: `false`

By default, mise handles `npm:` tools without needing node/npm installed: version metadata (`mise ls-remote`, `latest` resolution) is queried directly from the npm registry over HTTP, and packages are installed with mise's embedded [aube](https://github.com/jdx/aube) package manager. Both honor the registry, scoped registries, and auth tokens configured in `~/.npmrc` and `NPM_CONFIG_*` environment variables.

Enable this setting to shell out to the npm CLI instead — `npm view` for metadata and `npm install -g` for installs. Use it if your setup relies on npm-specific configuration the built-in implementation does not support (such as `cafile`, client certificates, or an auth token helper). When enabled, npm must be installed.

This applies to the default/`auto` package manager. Explicitly selecting a package manager with [`npm.package_manager`](https://mise.jdx.dev/configuration/settings.html#npm.package_manager) (`aube_cli`, `bun`, `pnpm`, or `npm`) always shells out to that tool regardless of this setting.

## `oci`[](#oci)

### `oci.default_from`[](#oci.default_from)

- Type: `string`
- Env: `MISE_OCI_DEFAULT_FROM`
- Default: `debian:bookworm-slim`

Default base image reference used by `mise oci build` when the `mise.toml` does not set `[oci].from` and `--from` is not passed on the CLI. Must be a glibc-based image for most mise tool installs (Node, Python, Ruby prebuilt binaries) to work.

Common overrides:
- `debian:bookworm-slim` (default) — glibc, \~30MB compressed
- `ubuntu:24.04` — glibc, slightly larger, familiar
- `gcr.io/distroless/cc-debian12` — glibc, no shell (not recommended for dev)

Alpine-based images are **not** recommended because their musl libc breaks glibc-linked prebuilt binaries that most tools ship.

### `oci.default_mount_point`[](#oci.default_mount_point)

- Type: `string`
- Env: `MISE_OCI_DEFAULT_MOUNT_POINT`
- Default: `/mise`

Path inside the built image where mise tool installs and shims are placed. Defaults to `/mise`. The resulting image sets `MISE_DATA_DIR` to this path.

### `oci.insecure_registries`[](#oci.insecure_registries)

- Type: `string[]`(optional)
- Env: `MISE_OCI_INSECURE_REGISTRIES`(comma separated)
- Default: `None`

Registries that `mise oci push` / `mise oci build --from` contact over plain HTTP instead of HTTPS, matching docker's `insecure-registries` daemon option. Loopback registries (`localhost:5000`, `127.0.0.1:5000`) are always treated as insecure and don't need to be listed. Entries match on exact `host` or `host:port`:

```toml
[settings.oci]
insecure_registries = ["registry.lan:5000", "10.0.0.8:5000"]
```

## `packslip`[](#packslip)

### `packslip.exec`[](#packslip.exec)

- Type: `boolean`
- Env: `MISE_PACKSLIP_EXEC`
- Default: `false`

Allow resource generation that runs the installed vendor executable during installation, such as a command that prints an agent skill's `SKILL.md`. Fetched files do not need this setting.

On-demand shell completions are separate: mise may run a declared completion command when the shell requests it, or when you run `mise completion --tool`, and caches successful output per version, executable, and shell. Disabling this setting does not disable on-demand completion generation.

See [completions and skills](https://mise.jdx.dev/dev-tools/packslip-resources.html) for setup, source selection, and execution limits.

### `packslip.stampers`[](#packslip.stampers)

- Type: `string[]`(optional)
- Env: `MISE_PACKSLIP_STAMPERS`(comma separated)
- Default: `None`

A stamping host, a registry, a mirror, or a scanning service, publishes a signed release list per vendor project at `https://<host>/.well-known/packslip/<project>.json`, naming the versions it checked and what it checked. When this setting names hosts, mise installs a packslip tool only at a version one of them lists: a version no trusted host stamped is not offered and not installed, however valid the vendor's own manifest is. Any one host's non-yanked approval suffices: one host withdrawing its approval does not veto another's. A vendor withdrawal still excludes the version regardless of stamps. Each accepted list must remain available, unexpired, and at or above its highest previously accepted sequence.

Each entry is `host=PIN`, where the pin is the minisign-format public key the host signs with, the path of that `.pub` file, or, for a host that signs keylessly from GitHub, an identity prefix such as `https://github.com/org/registry/`:

```toml
[settings.packslip]
stampers = [
  "registry.example.com=/path/to/stamper.pub",
  "stamps.example.com=https://github.com/example/stamps/",
]
```

A tool whose options say `trust = "vendor"` takes the vendor's own manifest under the vendor's pin, with no stamp:```toml
[tools]
"packslip:github.com/jdx/mise" = { version = "latest", trust = "vendor" }
```

Unset, no stamps are required. The example hosts and key path are placeholders; configure a real service and a pin you trust. A stamp never replaces verification of the vendor signature. See [stamps](https://mise.jdx.dev/dev-tools/backends/packslip.html#stamps).

## `pipx`[](#pipx)

## `pypi`[](#pypi)

### `pypi.registry_url`[](#pypi.registry_url)

- Type: `string`(optional)
- Env: `MISE_PYPI_REGISTRY_URL`
- Default: `None`

Package registry URL for Python tools (pipx.registry\_url is a compatibility alias).

### `pypi.uvx`[](#pypi.uvx)

- Type: `boolean`(optional)
- Env: `MISE_PYPI_UVX`
- Default: `None`

Use uv for Python tools when available (pipx.uvx is a compatibility alias).

## `python`[](#python)

### `python.compile`[](#python.compile)

- Type: `boolean`(optional)
- Env: `MISE_PYTHON_COMPILE`
- Default: `None`

- Values:
  - `true` - always compile with python-build instead of downloading [precompiled binaries](https://mise.jdx.dev/lang/python.html#precompiled-python-binaries).
  - `false` - always download precompiled binaries.
  - \[undefined] - use precompiled binary if one is available for the current platform, compile otherwise.

### `python.default_packages_file`[](#python.default_packages_file)deprecated

- Type: `string`(optional)
- Env: `MISE_PYTHON_DEFAULT_PACKAGES_FILE`
- Default: `None`
- Deprecated: Default python package files are deprecated. Use tool-level postinstall hooks for packages that should be installed into every python version, or use the pypi: backend for CLI tools.

Path to a file containing default python packages to install when installing a python version.

### `python.github_attestations`[](#python.github_attestations)

- Type: `boolean`(optional)
- Env: `MISE_PYTHON_GITHUB_ATTESTATIONS`
- Default: `None`

Override the global `github_attestations` setting for Python precompiled binaries. When enabled, mise will verify the authenticity of precompiled Python binaries from astral-sh/python-build-standalone.

Defaults to the global `github_attestations` setting if not specified.

### `python.patch_url`[](#python.patch_url)

- Type: `string`(optional)
- Env: `MISE_PYTHON_PATCH_URL`
- Default: `None`

URL to fetch python patches from to pass to python-build.

### `python.patches_directory`[](#python.patches_directory)

- Type: `string`(optional)
- Env: `MISE_PYTHON_PATCHES_DIRECTORY`
- Default: `None`

Directory to fetch python patches from.

### `python.precompiled_arch`[](#python.precompiled_arch)

- Type: `string`
- Env: `MISE_PYTHON_PRECOMPILED_ARCH`
- Default: `"x86_64_v3" | "aarch64"`

Specify the architecture to use for precompiled binaries. If on an old CPU, you may want to set this to "x86\_64" for the most compatible binaries. See https://gregoryszorc.com/docs/python-build-standalone/main/running.html for more information.

### `python.precompiled_flavor`[](#python.precompiled_flavor)

- Type: `string`
- Env: `MISE_PYTHON_PRECOMPILED_FLAVOR`
- Default: `install_only_stripped`

Specify the flavor to use for precompiled binaries.

Options are available here: <https://gregoryszorc.com/docs/python-build-standalone/main/running.html>

### `python.precompiled_os`[](#python.precompiled_os)

- Type: `string`
- Env: `MISE_PYTHON_PRECOMPILED_OS`
- Default: `"apple-darwin" | "unknown-linux-gnu" | "unknown-linux-musl"`

Specify the OS to use for precompiled binaries.

### `python.pyenv_repo`[](#python.pyenv_repo)

- Type: `string`
- Env: `MISE_PYENV_REPO`
- Default: `https://github.com/pyenv/pyenv.git`

URL to fetch pyenv from for compiling python with python-build.

### `python.uv_venv_auto`[](#python.uv_venv_auto)

- Type: `boolean | string`
- Env: `MISE_PYTHON_UV_VENV_AUTO`
- Default: `false`
- Choices:
  - `false` – disable uv venv integration
  - `source` – only source an existing `.venv`
  - `create|source` – create the venv if missing and source it
  - `true` – (create|source) with UV\_PYTHON export (deprecated)

Controls how mise handles uv project venvs when a uv.lock file is present.

The legacy `true` value is deprecated: it warns since mise 2026.7.0 and will be removed in mise 2027.7.0. It is treated like "create|source", with one difference: mise also exports `UV_PYTHON` to force uv to use the python version managed by mise. Prefer "source" or "create|source".

### `python.uv_venv_create_args`[](#python.uv_venv_create_args)

- Type: `string[]`(optional)
- Env: `MISE_PYTHON_UV_VENV_CREATE_ARGS`(colon separated)
- Default: `None`

Arguments to pass to uv when creating a venv.

### `python.venv_create_args`[](#python.venv_create_args)

- Type: `string[]`(optional)
- Env: `MISE_PYTHON_VENV_CREATE_ARGS`(colon separated)
- Default: `None`

Arguments to pass to python when creating a venv. (not used for uv venv creation)

### `python.venv_stdlib`[](#python.venv_stdlib)

- Type: `boolean`
- Env: `MISE_VENV_STDLIB`
- Default: `false`

Prefer to use venv from Python's standard library.

## `ruby`[](#ruby)

### `ruby.apply_patches`[](#ruby.apply_patches)

- Type: `string`(optional)
- Env: `MISE_RUBY_APPLY_PATCHES`
- Default: `None`

A list of patch files or URLs to apply to ruby source.

### `ruby.compile`[](#ruby.compile)

- Type: `boolean`(optional)
- Env: `MISE_RUBY_COMPILE`
- Default: `None`

Controls whether Ruby is compiled from source or downloaded as precompiled binaries.
- If `false`: Only use precompiled binaries. Installs error out instead of falling back to ruby-build, and version listings only include versions that have a precompiled binary for the current platform.
- If `true`: Always compile from source using ruby-build
- If unset: Try precompiled binaries first, fall back to compiling if unavailable

This setting has no effect on Windows, which installs Ruby from RubyInstaller2.

### `ruby.default_packages_file`[](#ruby.default_packages_file)deprecated

- Type: `string`
- Env: `MISE_RUBY_DEFAULT_PACKAGES_FILE`
- Default: `~/.default-gems`
- Deprecated: Default ruby gem files are deprecated. Use tool-level postinstall hooks for gems that should be installed into every ruby version, or use the gem: backend for CLI tools.

Path to a file containing default ruby gems to install when installing ruby.

### `ruby.github_attestations`[](#ruby.github_attestations)

- Type: `boolean`(optional)
- Env: `MISE_RUBY_GITHUB_ATTESTATIONS`
- Default: `None`

Override the global `github_attestations` setting for Ruby precompiled binaries. When enabled, mise will verify the authenticity of precompiled Ruby binaries from jdx/ruby.

Defaults to the global `github_attestations` setting if not specified.

### `ruby.precompiled_arch`[](#ruby.precompiled_arch)

- Type: `string`(optional)
- Env: `MISE_RUBY_PRECOMPILED_ARCH`
- Default: `None`

Override architecture identifier for precompiled Ruby binaries.

### `ruby.precompiled_os`[](#ruby.precompiled_os)

- Type: `string`(optional)
- Env: `MISE_RUBY_PRECOMPILED_OS`
- Default: `None`

Override OS identifier for precompiled Ruby binaries.

### `ruby.precompiled_url`[](#ruby.precompiled_url)

- Type: `string`
- Env: `MISE_RUBY_PRECOMPILED_URL`
- Default: `jdx/ruby`

Can be either:
- A GitHub repo shorthand: `"jdx/ruby"` or `"yourorg/ruby"`
- A full URL template with variables: `{version}`, `{platform}`, `{os}`, `{arch}`

Examples:

```toml
[settings.ruby]
# Use a different GitHub repo
precompiled_url = "yourorg/ruby"

# Or use a custom URL template
precompiled_url = "https://my-mirror.example.com/ruby-{version}.{platform}.tar.gz"
```

### `ruby.ruby_build_cli_opts`[](#ruby.ruby_build_cli_opts)

- Type: `string`(optional)
- Env: `MISE_RUBY_BUILD_CLI_OPTS`
- Default: `None`

CLI options passed directly to ruby-build before the version and install prefix.

### `ruby.ruby_build_opts`[](#ruby.ruby_build_opts)

- Type: `string`(optional)
- Env: `MISE_RUBY_BUILD_OPTS`
- Default: `None`

Configure arguments passed through ruby-build after `--`.

### `ruby.ruby_build_repo`[](#ruby.ruby_build_repo)

- Type: `string`
- Env: `MISE_RUBY_BUILD_REPO`
- Default: `https://github.com/rbenv/ruby-build.git`

The URL used to fetch ruby-build. This accepts either a Git repository or a ZIP archive.

### `ruby.ruby_install`[](#ruby.ruby_install)

- Type: `boolean`
- Env: `MISE_RUBY_INSTALL`
- Default: `false`

Use ruby-install instead of ruby-build.

### `ruby.ruby_install_opts`[](#ruby.ruby_install_opts)

- Type: `string`(optional)
- Env: `MISE_RUBY_INSTALL_OPTS`
- Default: `None`

Options to pass to ruby-install.

### `ruby.ruby_install_repo`[](#ruby.ruby_install_repo)

- Type: `string`
- Env: `MISE_RUBY_INSTALL_REPO`
- Default: `https://github.com/postmodern/ruby-install.git`

The URL used to fetch ruby-install. This accepts either a Git repository or a ZIP archive.

### `ruby.verbose_install`[](#ruby.verbose_install)

- Type: `boolean`(optional)
- Env: `MISE_RUBY_VERBOSE_INSTALL`
- Default: `None`

Set to true to enable verbose output during ruby installation.

## `rust`[](#rust)

### `rust.cargo_home`[](#rust.cargo_home)

- Type: `string`(optional)
- Env: `MISE_CARGO_HOME`
- Default: `None`

Path to the cargo home directory. Defaults to `~/.cargo` or `%USERPROFILE%\.cargo`

### `rust.default_host`[](#rust.default_host)

- Type: `string`(optional)
- Env: `MISE_RUST_DEFAULT_HOST`
- Default: `None`

Default host triple to pass to `rustup init` via `--default-host`.

### `rust.rustup_home`[](#rust.rustup_home)

- Type: `string`(optional)
- Env: `MISE_RUSTUP_HOME`
- Default: `None`

Path to the rustup home directory. Defaults to `~/.rustup` or `%USERPROFILE%\.rustup`

## `sandbox`[](#sandbox)

### `sandbox.deny_all`[](#sandbox.deny_all)

- Type: `boolean`
- Env: `MISE_SANDBOX_DENY_ALL`
- Default: `false`

Deny filesystem reads and writes, network access, and environment variable inheritance by default for `mise run` and `mise exec`.

### `sandbox.deny_env`[](#sandbox.deny_env)

- Type: `boolean`
- Env: `MISE_SANDBOX_DENY_ENV`
- Default: `false`

Deny environment variable inheritance by default for `mise run` and `mise exec`.

### `sandbox.deny_net`[](#sandbox.deny_net)

- Type: `boolean`
- Env: `MISE_SANDBOX_DENY_NET`
- Default: `false`

Deny network access by default for `mise run` and `mise exec`.

### `sandbox.deny_read`[](#sandbox.deny_read)

- Type: `boolean`
- Env: `MISE_SANDBOX_DENY_READ`
- Default: `false`

Deny filesystem reads by default for `mise run` and `mise exec`.

### `sandbox.deny_write`[](#sandbox.deny_write)

- Type: `boolean`
- Env: `MISE_SANDBOX_DENY_WRITE`
- Default: `false`

Deny filesystem writes by default for `mise run` and `mise exec`.

## `self_update`[](#self_update)

### `self_update.api_url`[](#self_update.api_url)

- Type: `string`
- Env: `MISE_SELF_UPDATE_API_URL`
- Default: `https://api.github.com`

The HTTPS API base URL for the GitHub repository that supplies mise releases. For GitHub Enterprise, include the API path, such as `https://github.example.com/api/v3`.

This setting is global-only so a project configuration cannot redirect updates of the mise binary.

### `self_update.repository`[](#self_update.repository)

- Type: `string`
- Env: `MISE_SELF_UPDATE_REPOSITORY`
- Default: `jdx/mise`

The repository must contain official mise release archives with their original names and embedded signatures. This can be set to a private repository that mirrors only releases approved by an organization. Authentication uses mise's existing GitHub token resolution settings.

The configured repository is also used for version notifications and automatic updates. This setting is global-only so a project configuration cannot redirect updates of the mise binary.

## `shims`[](#shims)

### `shims.exclude`[](#shims.exclude)

- Type: `string[]`
- Env: `MISE_SHIMS_EXCLUDE`
- Default: `[]`

Names listed here are skipped when mise generates shims, and any existing shims with those names are removed on the next reshim. mise still installs and manages the tool — it just never generates a shim for that name, so nothing in the shim directory intercepts the command and it resolves to whatever else `PATH` provides.

This is useful when a tool's unversioned command is also provided by the OS and other software depends on getting the system one. On Arch Linux, for example, `/usr/bin/python` is the distro interpreter and its modules live in a matching `site-packages` directory, so a project that pins `python` also changes which interpreter a `#!/usr/bin/env python` script gets:```
mise settings shims.exclude=python,python3,pip,pip3
```

With that set, `python` and `python3` always resolve to the system interpreter, while a version-qualified shim such as `python3.12` still resolves to the version a config selects.

Excluding `python3` means `python3 -m venv` builds a virtualenv from the system interpreter rather than the configured one. Use the version-qualified command (for example `python3.12 -m venv`) when you want the mise-managed version.

This only affects the shims mise generates, including lazy-tool bootstrap shims and plugin-provided shims. Two things are deliberately not covered: under `mise activate` without `--shims` a tool's bin directory joins `PATH` as a whole, so excluded names are still visible there; and command wrappers publish to their own directory from an explicit declaration, so an excluded name you also declare as a wrapper still resolves to the wrapper.

## `skills`[](#skills)

### `skills.auto_sync`[](#skills.auto_sync)

- Type: `boolean`
- Env: `MISE_SKILLS_AUTO_SYNC`
- Default: `false`

When on, mise runs the equivalent of `mise skills sync` after every install and after `mise use` changes a version, so the links under [`skills.dir`](#skills.dir) always point at the versions that are active in the project. Only projects with a mise config get links; nothing is written outside a project root. Links mise made are the only ones it touches, and stale ones are removed only when [`skills.prune`](#skills.prune) is on.

### `skills.dir`[](#skills.dir)

- Type: `string`
- Env: `MISE_SKILLS_DIR`
- Default: `.claude/skills`

The directory an agent reads skills from, relative to the project root, or to the home directory for `mise skills sync --global`. An absolute path is used as it is. `--dir` on the command line overrides it for one run. Set it to `.agents/skills` or wherever the agents you use look.

### `skills.fetch`[](#skills.fetch)

- Type: `boolean`
- Env: `MISE_SKILLS_FETCH`
- Default: `true`

A packslip may declare agent skills beside the tool's executables. mise fetches them at install time so every installed version carries its own copy. Turn this off to skip fetching skills during installation. This does not delete previously fetched skills or existing links. See [agent skills](https://mise.jdx.dev/dev-tools/packslip-resources.html#skills) for synchronization and pruning.

### `skills.prune`[](#skills.prune)

- Type: `boolean`
- Env: `MISE_SKILLS_PRUNE`
- Default: `false`

`mise skills sync` leaves links for skills of versions that are no longer active unless told to prune them. This makes pruning the default, for the command and for [`skills.auto_sync`](#skills.auto_sync). Only links mise made, recorded beside them and pointing into its installs directory, are ever removed.

## `sops`[](#sops)

### `sops.age_key`[](#sops.age_key)

- Type: `string`(optional)
- Env: `MISE_SOPS_AGE_KEY`
- Default: `None`

The age private key to use for sops secret decryption. Takes precedence over standard SOPS\_AGE\_KEY environment variable.

### `sops.age_key_file`[](#sops.age_key_file)

- Type: `string`
- Env: `MISE_SOPS_AGE_KEY_FILE`
- Default: `~/.config/mise/age.txt`

Path to the age private key file for sops secret decryption. Takes precedence over standard SOPS\_AGE\_KEY\_FILE environment variable.

### `sops.age_recipients`[](#sops.age_recipients)

- Type: `string`(optional)
- Env: `MISE_SOPS_AGE_RECIPIENTS`
- Default: `None`

The age public keys to use for sops secret encryption.

### `sops.rops`[](#sops.rops)

- Type: `boolean`
- Env: `MISE_SOPS_ROPS`
- Default: `true`

Use rops to decrypt sops files. Disable to shell out to `sops` which will slow down mise but sops may offer features not available in rops. Required for TOML SOPS files because the sops CLI does not support TOML.

### `sops.strict`[](#sops.strict)

- Type: `boolean`
- Env: `MISE_SOPS_STRICT`
- Default: `true`

If true, fail when sops decryption fails (including when sops is not available, the key is missing, or the key is invalid). If false, skip decryption and continue in these cases.

## `spm`[](#spm)

### `spm.artifactbundle_only`[](#spm.artifactbundle_only)

- Type: `boolean`
- Env: `MISE_SPM_ARTIFACTBUNDLE_ONLY`
- Default: `false`

Only use SwiftPM artifact bundles for installation, fail if no matching bundle is available.

## `status`[](#status)

### `status.missing_tools`[](#status.missing_tools)

- Type: `string`
- Env: `MISE_STATUS_MESSAGE_MISSING_TOOLS`
- Default: `if_other_versions_installed`

| Choice | Description |
| --- | --- |
| `if_other_versions_installed` \[default] | Show the warning only when the tool has at least 1 other version installed |
| `always` | Always show the warning |
| `never` | Never show the warning |

Show a warning if tools are not installed when entering a directory with a `mise.toml` file.

Disable tools with [`disable_tools`](#disable_tools).

### `status.show_deps_stale`[](#status.show_deps_stale)

- Type: `boolean`
- Env: `MISE_STATUS_SHOW_DEPS_STALE`
- Default: `true`

Show warning when deps providers have stale dependencies.

### `status.show_env`[](#status.show_env)

- Type: `boolean`
- Env: `MISE_STATUS_MESSAGE_SHOW_ENV`
- Default: `false`

Show configured env vars when entering a directory with a mise.toml file.

### `status.show_tools`[](#status.show_tools)

- Type: `boolean`
- Env: `MISE_STATUS_MESSAGE_SHOW_TOOLS`
- Default: `false`

Show configured tools when entering a directory with a mise.toml file.

### `status.truncate`[](#status.truncate)

- Type: `boolean`
- Env: `MISE_STATUS_MESSAGE_TRUNCATE`
- Default: `true`

Truncate status messages.

## `swift`[](#swift)

### `swift.gpg_verify`[](#swift.gpg_verify)

- Type: `boolean`(optional)
- Env: `MISE_SWIFT_GPG_VERIFY`
- Default: `None`

Verify OpenPGP signatures for swift (built-in, no external gpg required). Set to false to disable.

### `swift.platform`[](#swift.platform)

- Type: `string`
- Env: `MISE_SWIFT_PLATFORM`
- Default: `"osx" | "windows10" | "ubuntu24.04" | "debian12" | "fedora41" | "amazonlinux2023" | "ubi9"`

Override the distro build to use for precompiled binaries. By default the distro is detected and matched against what the Swift release actually publishes, which changes from release to release. Set this to force a specific build, or to install without reaching swift.org's release index.

## `system_packages`[](#system_packages)

### `system_packages.managers`[](#system_packages.managers)

- Type: `string[]`(optional)
- Env: `MISE_SYSTEM_PACKAGES_MANAGERS`(comma separated)
- Default: `None`

Restrict which system package managers mise will use.

By default mise acts on every manager in `[bootstrap.packages]` that is available on the current machine. When more than one could apply (e.g. several package managers installed on one machine, or a shared config listing managers you don't want on this machine), set this to the subset you want:```toml
[settings]
system_packages.managers = ["apt"]
```

This composes well with platform-specific config files (`mise.macos.toml`, `mise.linux.toml`) for per-OS defaults.

### `system_packages.sudo`[](#system_packages.sudo)

- Type: `boolean`
- Env: `MISE_SYSTEM_PACKAGES_SUDO`
- Default: `true`

Allow `mise bootstrap` and `mise install --system` to invoke sudo when root permissions are needed. Enabled by default.

For bootstrap, elevation applies to explicit apply operations. For [`mise install --system`](https://mise.jdx.dev/dev-tools/index.html#system-installations), mise prepares supported tools as your user and elevates only to write the installation and its links into protected system directories.

Set this to `false` to disable automatic elevation. Operations that require root permissions then fail unless mise is already running as root. Operations that do not need elevation, such as installing into a user-writable directory, still work.

mise logs each elevated command before running it. Interactive sessions can prompt for a sudo password; noninteractive sessions require sudo to work without a password prompt. When already running as root, mise skips sudo.

## `task`[](#task)

### `task.auto_infer`[](#task.auto_infer)

- Type: `string[]`
- Env: `MISE_TASK_AUTO_INFER`
- Default: `[]`

List the workspace provider languages whose ecosystem tasks mise should import. For example, `["node"]` imports scripts from Node workspace `package.json` files. Inferred tasks use stable provider-scoped names and monorepo path aliases. Task inference is opt-in because ecosystem commands may overlap with explicit mise tasks.

### `task.cache.audit_report`[](#task.cache.audit_report)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_AUDIT_REPORT`
- Default: `None`

Write the complete report produced by [`cache.audit`](https://mise.jdx.dev/tasks/task-configuration.html#cache) to this file as JSON Lines, one `{"task", "kind", "path"}` object per undeclared path. Console warnings remain limited to the first 20 paths per task.

Truncation happens once per `mise` invocation: the first audited task in each invocation truncates the file and later audited tasks in that invocation append to it, so one file holds that run's report for every audited task and a later run replaces it rather than adding to it. Cached tasks do not execute and write nothing, leaving an earlier report in place. Relative paths resolve against mise's working directory.

### `task.cache.remote_mode`[](#task.cache.remote_mode)

- Type: `string`
- Env: `MISE_TASK_CACHE_REMOTE_MODE`
- Default: `read-write`
- Choices:
  - `read-write`
  - `read-only`
  - `write-only`

Control access to the remote cache used by task result and action caching:
- `read-write` reads remote misses and uploads successful local results.
- `read-only` reads remote misses without uploading results.
- `write-only` uploads results without reading remote entries.

The per-run `--task-cache=local-only` mode disables remote task-result access. Action-cache adapters may further restrict this mode. Remote writes are allowed only from protected-branch push pipelines in GitHub Actions and GitLab CI; pull requests, unprotected branches, other CI systems, and local developer runs are read-only. The server must independently enforce the same policy from verified OIDC claims.

### `task.cache.remote_namespace`[](#task.cache.remote_namespace)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_REMOTE_NAMESPACE`
- Default: `None`

Opaque repository or organization namespace used to isolate remote build-cache entries. This setting is required when [`task.cache.remote_url`](https://mise.jdx.dev/configuration/settings.html#task.cache.remote_url) is configured.

### `task.cache.remote_oidc_audience`[](#task.cache.remote_oidc_audience)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_REMOTE_OIDC_AUDIENCE`
- Default: `None`

Acquire a short-lived OIDC token for this audience when running in a supported workload identity environment. GitHub Actions is supported through its OIDC request environment variables. This setting is global-only so shared project configuration cannot choose a token audience.

### `task.cache.remote_token`[](#task.cache.remote_token)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_REMOTE_TOKEN`
- Default: `None`

Authenticate remote build-cache requests with an HTTP `Authorization: Bearer` header. Prefer the `MISE_TASK_CACHE_REMOTE_TOKEN` environment variable or a protected global configuration file; this setting is global-only so shared project configuration cannot supply credentials.

### `task.cache.remote_token_file`[](#task.cache.remote_token_file)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_REMOTE_TOKEN_FILE`
- Default: `None`

Read the remote build-cache bearer token from this file before each request. This supports rotating credentials such as Kubernetes projected service account tokens. This setting is global-only so shared project configuration cannot select a credential file.

### `task.cache.remote_url`[](#task.cache.remote_url)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_REMOTE_URL`
- Default: `None`

Enable the versioned HTTP remote build-cache protocol at this base URL. Remote access also requires [`task.cache.remote_namespace`](https://mise.jdx.dev/configuration/settings.html#task.cache.remote_namespace). Leave unset to use only local caches.

### `task.cache.stats_report`[](#task.cache.stats_report)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_STATS_REPORT`
- Default: `None`

Write a versioned JSON report describing Rust action-cache activity, transfer volume, restored outputs, and phase timings. Timing values use nanoseconds. Concurrent phase timings are cumulative work time and can exceed the end-to-end `session_duration_ns`; `prefetch_duration_ns` is the sum of wall-clock durations for each task prefetch run.

This is intended for CI qualification and benchmarking. Relative paths resolve against mise's working directory. The report is replaced atomically after each `mise run` invocation that creates an action-cache session.

### `task.cache_dir`[](#task.cache_dir)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_DIR`
- Default: `None`

Store task output cache artifacts in this directory instead of `MISE_CACHE_DIR/task-artifacts`. mise stores the current artifact format in a versioned subdirectory and includes custom locations in `mise cache clear` and manual and automatic cache pruning.

### `task.cache_max_age`[](#task.cache_max_age)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_MAX_AGE`
- Default: `None`

Remove task output cache entries that have not been accessed within this duration after a new entry is stored. This limit applies only to the task output cache and is independent of [`cache_prune_age`](https://mise.jdx.dev/configuration/settings.html#cache_prune_age). Set to `0s` or leave unset to disable the age limit.

### `task.cache_max_size`[](#task.cache_max_size)

- Type: `string`(optional)
- Env: `MISE_TASK_CACHE_MAX_SIZE`
- Default: `None`

Keep the task output cache at or below this size by removing least-recently-accessed entries after a new entry is stored. Values accept SI or IEC units such as `500MB` or `2GiB`. Set to `0` or leave unset to disable the size limit.

### `task.disable_paths`[](#task.disable_paths)

- Type: `string[]`
- Env: `MISE_TASK_DISABLE_PATHS`
- Default: `[]`

Paths that mise will not look for tasks in.

Relative paths set in a config file are resolved from that file's config root. Relative paths from the environment are resolved from the invocation's working directory.

Paths are separated by the OS path separator when using the environment variable, `mise settings set`, or `mise settings add` (`:` on Unix, `;` on Windows).

### `task.disable_spec_from_run_scripts`[](#task.disable_spec_from_run_scripts)

- Type: `boolean`
- Env: `MISE_TASK_DISABLE_SPEC_FROM_RUN_SCRIPTS`
- Default: `false`

When enabled, `arg()`, `option()`, and `flag()` Tera functions in run scripts will not contribute to the task's usage spec—only the explicit `usage` field is used.

This is useful for:
- Skipping the extra template pass over run scripts (performance)
- Avoiding two-pass parsing quirks where template functions return empty strings during spec collection
- Early opt-out before Tera template arguments are removed in 2026.11.0

### `task.monorepo_depth`[](#task.monorepo_depth)

- Type: `integer`
- Env: `MISE_TASK_MONOREPO_DEPTH`
- Default: `5`

When using monorepo mode (monorepo\_root = true), this controls how deep mise will search for task files in subdirectories.

**Depth levels:**

- 1 = immediate children only (monorepo\_root/projects/)
- 2 = grandchildren (monorepo\_root/projects/frontend/)
- 5 = default (5 levels deep)

**Performance tip:** Reduce this value if you have a very large monorepo and notice slow task discovery. For example, if your projects are all at `projects/*`, set to 2.

**Example:**

```toml
[settings]
task.monorepo_depth = 3  # Only search 3 levels deep
```

Or via environment variable:```bash
export MISE_TASK_MONOREPO_DEPTH=3
```

### `task.monorepo_exclude_dirs`[](#task.monorepo_exclude_dirs)

- Type: `string[]`
- Env: `MISE_TASK_MONOREPO_EXCLUDE_DIRS`(comma separated)
- Default: `[]`

If empty (default), uses default exclusions: node\_modules, target, dist, build. If you specify any patterns, ONLY those patterns will be excluded (defaults are NOT included). For example, setting to \[".temp", "vendor"] will exclude only those two directories.

### `task.monorepo_respect_gitignore`[](#task.monorepo_respect_gitignore)

- Type: `boolean`
- Env: `MISE_TASK_MONOREPO_RESPECT_GITIGNORE`
- Default: `true`

When enabled, mise will skip directories that are ignored by .gitignore files when discovering tasks in a monorepo.

### `task.output`[](#task.output)

- Type: `string`(optional)
- Env: `MISE_TASK_OUTPUT`
- Default: `None`
- Choices:
  - `prefix` – (default if jobs > 1) print by line with the prefix of the task name
  - `interleave` – (default if jobs == 1 or all tasks run sequentially) print output as it comes in
  - `keep-order` – stream one task's output live while buffering others, printing in definition order as tasks complete
  - `replacing` – replace stdout each time a line is printed-this uses similar logic as `mise install`
  - `timed` – only show stdout lines that take longer than 1s to complete
  - `quiet` – deprecated: interleave task output and suppress mise's own messages. Use `interleave` with the appropriate quiet setting or flag.
  - `silent` – print nothing from tasks or mise (nulls stdout and stderr)

Change output style when executing tasks. This controls the output of `mise run`.

This is the output *style* axis. Verbosity is a separate axis controlled by `task.quiet`/`silent` (as settings, `--quiet`/`--silent` flags, or per-task fields), so a style can be combined with quietness — e.g. `output = "prefix"` together with `task.quiet = true` keeps the task-name prefixes while suppressing mise's own task messages. The `quiet` and `silent` *values* below are kept for backwards compatibility and bundle a style with that verbosity.

::: warning Deprecated The `quiet` output value is deprecated. Warnings begin in mise `2026.9.3`, and support will be removed in `2027.9.3`. For a global task default, use `task.output = "interleave"` with `task.quiet = true`. For an individual task, use `output = "interleave"` with `quiet = true`. On the command line, use `--output interleave --quiet`. :::

### `task.quiet`[](#task.quiet)

- Type: `boolean`
- Env: `MISE_TASK_QUIET`
- Default: `false`

Suppress mise's own output while executing tasks without affecting other mise commands. Task stdout and stderr remain visible. This setting is independent of the `task.output` style, so it can be combined with `prefix`, `interleave`, or another output style.

### `task.remote_no_cache`[](#task.remote_no_cache)

- Type: `boolean`(optional)
- Env: `MISE_TASK_REMOTE_NO_CACHE`
- Default: `None`

Mise will always fetch the latest tasks from the remote, by default the cache is used.

### `task.run_auto_install`[](#task.run_auto_install)

- Type: `boolean`
- Env: `MISE_TASK_RUN_AUTO_INSTALL`
- Default: `true`

Automatically install missing tools when executing tasks.

### `task.show_full_cmd`[](#task.show_full_cmd)

- Type: `boolean`
- Env: `MISE_TASK_SHOW_FULL_CMD`
- Default: `false`

Disable truncation of command lines in task execution output. When true, the full command line will be shown.

### `task.skip`[](#task.skip)

- Type: `string[]`
- Env: `MISE_TASK_SKIP`
- Default: `[]`

Tasks to skip when running `mise run`.

### `task.skip_depends`[](#task.skip_depends)

- Type: `boolean`
- Env: `MISE_TASK_SKIP_DEPENDS`
- Default: `false`

Run only specified tasks skipping all dependencies.

### `task.source_freshness_equal_mtime_is_fresh`[](#task.source_freshness_equal_mtime_is_fresh)

- Type: `boolean`
- Env: `MISE_TASK_SOURCE_FRESHNESS_EQUAL_MTIME_IS_FRESH`
- Default: `false`

When source mtime equals output mtime, consider sources fresh (use <=). Default false uses strict < comparison.

### `task.source_freshness_hash_contents`[](#task.source_freshness_hash_contents)

- Type: `boolean`
- Env: `MISE_TASK_SOURCE_FRESHNESS_HASH_CONTENTS`
- Default: `false`

Use content hashing (blake3) instead of metadata for source freshness. More accurate but slower.

### `task.timeout`[](#task.timeout)

- Type: `string`(optional)
- Env: `MISE_TASK_TIMEOUT`
- Default: `None`

Sets a global default timeout for all tasks. Individual tasks can also specify their own `timeout`.

When both a global timeout and a per-task timeout are set, the **shorter** of the two always wins—a per-task timeout cannot extend beyond the global timeout. The `--timeout` CLI flag overrides this global setting.

### `task.timings`[](#task.timings)

- Type: `boolean`(optional)
- Env: `MISE_TASK_TIMINGS`
- Default: `None`

Show completion message with elapsed time for each task on `mise run`. Default shows when output type is `prefix`.

## `upgrade`[](#upgrade)

### `upgrade.auto_prune`[](#upgrade.auto_prune)

- Type: `boolean`
- Env: `MISE_UPGRADE_AUTO_PRUNE`
- Default: `true`

`mise upgrade` schedules the version it upgraded away from for removal after [`upgrade.prune_after`](https://mise.jdx.dev/configuration/settings.html#upgrade.prune_after). The install directory stays in place during that grace period so long-running processes can continue loading files from it. Set this to `false` when something outside of mise resolves through that path permanently — a virtualenv built from a mise-managed interpreter, for example — and the old version is left in place without a scheduled removal.

Versions that another tracked config or tool stub still needs are kept regardless of this setting. `mise upgrade --prune` removes the replaced version immediately, and `--no-prune` leaves it in place without scheduling removal.

### `upgrade.prune_after`[](#upgrade.prune_after)

- Type: `string`
- Env: `MISE_UPGRADE_PRUNE_AFTER`
- Default: `24h`

Replaced tool versions remain at their original paths for this long before mise removes them on a later invocation. This protects long-running commands that may continue loading files from an old install after an upgrade selects a new version.

Set this to `0s` to make the next mise invocation remove scheduled versions immediately. Use `mise upgrade --prune` or `mise prune` when removal must happen in the current invocation.

## `zig`[](#zig)

### `zig.use_community_mirrors`[](#zig.use_community_mirrors)

- Type: `boolean`
- Env: `MISE_ZIG_USE_COMMUNITY_MIRRORS`
- Default: `true`

This setting allows mise to fetch Zig from one of many community-maintained mirrors.

The ziglang.org website does not offer any uptime or speed guarantees, and it recommends to use the mirrors. The mirror list is cached and allows the installs to succeed even if the main server is unavailable.

The downloaded tarballs are always verified against Zig Software Foundation's public key, so there is no risk of third-party modifications. Read more on [ziglang.org](https://ziglang.org/download/community-mirrors/).

If you don't have the mirror list cached locally, you can place the newline-separated server list inside `mise cache path`, folder `zig` as `community-mirrors.txt`.

[Edit this page](https://github.com/jdx/mise/edit/main/docs/configuration/settings.md)

Last updated:

Pager

[Previous pageProject Diagnostics](https://mise.jdx.dev/configuration/project-diagnostics.html)

[Next pageConfiguration Environments](https://mise.jdx.dev/configuration/environments.html)

MIT License·Copyright © 2026· [![](https://github.com/jdx.png?size=96)jdx.dev](https://jdx.dev)