---
slug: shadow-ide/architecture/tech-stack
project_slug: shadow-ide
kind: architecture
audience: [agent, dev]
version: 1
last_updated: 2026-05-10
mapped_date: 2026-05-10
status: complete
tags: [tech-stack, dependencies, tooling]
---

# Tech Stack

> Shadow-IDE uses Bash, GitHub Actions, upstream VS Code's Node/TypeScript build system, Rust for the CLI, and platform packaging/signing tools.

## Languages and runtimes

| Area | Technology | Notes |
|------|------------|-------|
| Orchestration | Bash | Primary scripts at repo root, `build/`, `dev/`, and `stores/`. |
| JSON processing | `jq`, Node.js | Used for product metadata, version metadata, and workflow outputs. |
| Upstream build | Node.js and npm | Node version is controlled by `.nvmrc`; upstream VS Code build uses npm/gulp. |
| Helper tooling | TypeScript | `font-size/generate-css.ts` and upstream VS Code build scripts. |
| CLI/tunnel | Rust/Cargo | `build_cli.sh` builds the VS Code CLI binary after upstream source is prepared. |
| Knowledge base | Markdown, Python, TypeScript MCP | kbmap wiki plus generated read-only MCP server. |

## Local dependency baseline

`docs/howto-build.md` lists common dependencies:

- Node.js from `.nvmrc`
- `jq`
- `git`
- Python 3.11
- `rustup`

Linux builds also need compilers, package tooling, `libx11-dev`, `libxkbfile-dev`, `libsecret-1-dev`, `libkrb5-dev`, `fakeroot`, `rpm`, `rpmbuild`, `dpkg`, ImageMagick, and Snapcraft.

## Platform packaging tools

| Platform | Tools and outputs |
|----------|-------------------|
| Linux | Docker build images, deb, rpm, AppImage, snap, tar.gz, REH tarballs, CLI tarball |
| macOS | GitHub macOS runner or self-hosted ARM64 runner, dmg/zip, keychain certificate signing |
| Windows | Git Bash, PowerShell helper, WiX MSI tooling, Inno/exe assets, SignPath signing, zip |

## External services

- [[integrations/microsoft-vscode-source]] - Source repository and update API.
- [[integrations/github-releases-and-actions]] - CI runner, artifacts, releases, dispatch, and release assets.
- [[integrations/open-vsx-registry]] - Extension marketplace defaults.
- [[integrations/electron-and-node-build-assets]] - Electron, ffmpeg, npm packages, Playwright suppression flags.
- [[integrations/signpath-and-codesigning]] - Windows and macOS signing.
- [[integrations/package-manager-ecosystem]] - Snapcraft, WinGet, AppImage, and package-manager metadata.

## Important environment variables

| Variable | Role |
|----------|------|
| `APP_NAME` | Product display/release asset name. Currently defaults to `VSCodium` in tracked scripts/workflows. |
| `BINARY_NAME` | Command/binary name, currently `codium` by default. |
| `VSCODE_QUALITY` | `stable` or `insider`; controls overlays, version suffixes, and release routes. |
| `OS_NAME` | `linux`, `osx`, `windows`, or `alpine`; selects platform build paths. |
| `VSCODE_ARCH` | Target architecture such as `x64`, `arm64`, `armhf`, `riscv64`, `loong64`, or `ppc64le`. |
| `SHOULD_BUILD` | Gate used by CI to stop early when a release already exists. |
| `RELEASE_VERSION` | Release asset version. Derived when not provided. |
| `MS_TAG` and `MS_COMMIT` | Selected upstream VS Code tag and commit. |
| `ASSETS_REPOSITORY` | GitHub repository where release assets are published. |
| `VERSIONS_REPOSITORY` | Repository where update-service metadata is pushed. |
| `DISABLE_UPDATE` | Enables update-disable patching and packaging paths. |

## Build security posture

The repo pins many GitHub Actions by commit SHA and includes `lint-zizmor.yml` plus `.github/zizmor.yml` for workflow linting. Runtime build scripts still execute network installs and release/signing operations, so credentialed actions should be run only from trusted CI or an intentionally prepared local environment.

## Related pages

- [[architecture/overview]]
- [[components/github-actions-pipelines]]
- [[components/platform-build-packaging]]
- [[features/cross-platform-build-and-packaging]]
- [[index]]
