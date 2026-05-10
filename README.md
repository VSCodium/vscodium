# ShadowIDE

**Shadowtrack's internal agentic IDE.** A branded, customized distribution of Visual Studio Code, built from Microsoft's open-source `vscode` repository, with the Cline agent pre-bundled as the default coding assistant.

This repository contains the build scripts that:

1. Clone Microsoft's [`vscode`](https://github.com/microsoft/vscode) source.
2. Apply Shadowtrack patches (branding, defaults, Cline pre-install, telemetry disabled).
3. Produce signed binaries for macOS, Linux, and Windows under the `ShadowIDE` brand.

It is a fork of [VSCodium](https://github.com/VSCodium/vscodium) — the upstream credit and license remain unchanged.

## Status

Early-stage internal project. Distribution channels (Homebrew, winget, Snap, etc.) and a public GitHub release pipeline are **not yet set up**. Build locally for now.

## Identity

| | |
|---|---|
| App name | ShadowIDE |
| CLI binary | `shadow` |
| macOS bundle ID | `com.shadowtrack.shadowide` |
| User data folder | `~/.shadowide` |
| URL protocol | `shadowide://` |
| Vendor | Shadowtrack |

## Build (macOS / Linux / Windows)

Prerequisites — see [`docs/howto-build.md`](docs/howto-build.md). Short version on macOS:

```bash
brew install jq node@22 python@3.11 rustup
rustup-init -y
export PATH="/opt/homebrew/opt/node@22/bin:/opt/homebrew/opt/python@3.11/libexec/bin:$HOME/.cargo/bin:$PATH"

./dev/build.sh
```

The built app lands in `VSCode-darwin-arm64/ShadowIDE.app` (path retains the upstream directory name; the bundle inside is rebranded).

```bash
open VSCode-darwin-arm64/ShadowIDE.app
```

## Cline integration

ShadowIDE will ship with [Cline](https://github.com/cline/cline) (`saoudrizwan.claude-dev`) pre-installed as the default agent. The pre-bundle hook lives in the build pipeline and pulls a pinned `.vsix`. In the long term, Shadowtrack will maintain a fork of Cline with custom prompts, default `.shadowrules`, and pre-configured MCP tools.

## Why a fork?

Owning the distribution lets us:

- Pre-bundle and lock down the agent (Cline) as the default.
- Ship Shadowtrack defaults — model preferences, MCP servers, harness rules, `.shadowrules`.
- Modify branding, telemetry, and update channels.
- Remove or replace anything we don't want in the editor surface.

## Upstream

ShadowIDE tracks VSCodium (which tracks Microsoft's `vscode`). Periodic merges from upstream pull in new VS Code releases. The Shadowtrack-specific changes live in:

- `prepare_vscode.sh` — branding identifiers injected into `product.json`
- `utils.sh` — `APP_NAME`, `BINARY_NAME`, etc.
- `patches/user/` — Shadowtrack-specific patches against vscode source
- `product.json` — extension policy overrides

## License

[MIT](LICENSE). The build scripts in this repository are MIT (inherited from VSCodium). The `ShadowIDE` name and logo are trademarks of Shadowtrack.
