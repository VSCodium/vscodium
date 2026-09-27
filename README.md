<div align="center">
   <h1>VSLight</h1>
   <h3>A pure local code editor — edit / files / search / Git / terminal / extensions</h3>
</div>

VSLight is a lightweight build of the VS Code source (via the VSCodium build pipeline),
rebranded and stripped of everything that is not local editing:

- **kept**: editor, file explorer, search, Git, integrated terminal (+ tasks), the
  extension mechanism with the open-vsx marketplace, languages/themes/auth extensions
- **removed**: remote development (reh server, tunnels, Remote Explorer), AI Chat,
  Debug subsystem, Notebooks, sessions/agent host, and the Rust tunnel CLI

## Download/Install

Releases: <https://github.com/vslight/vslight/releases>

macOS (Apple Silicon) is the verified platform; Linux and Windows keep build
capability but are not part of the acceptance scope of this release.

## Migrating from VSCodium / VS Code

VSLight is a separate product with its own data directories — nothing is migrated
in place. See [docs/vslight-migration.md](docs/vslight-migration.md) for how to move
settings, keybindings, snippets and extensions.

## Build

```bash
./dev/run-build.sh        # full build (clone upstream, patch, build, package)
./dev/run-build.sh -s     # reuse existing vscode/ tree
```

See [docs/howto-build.md](docs/howto-build.md) for details. Acceptance smoke:
`./dev/smoke.sh` (see its header for the spec).

## Why

Editor-only footprint: faster builds (no reh/CLI), smaller install, no remote/AI
surface. Telemetry is disabled by the inherited VSCodium patches.

## License

[MIT](LICENSE)
