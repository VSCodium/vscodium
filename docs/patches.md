# Patches

Documentation for VSCodium patches applied on top of VS Code.

---

## Patch stack

Each patch is a git commit in `vscode/`, on top of `refs/vscodium/base` (the
upstream commit, recorded by `get_repo.sh`). `refs/vscodium/head` is the commit
`patches/` reproduces; only import and export move it, so commits past it are not
in any patch file yet. Import and export use Electron's patch tooling, vendored in
`dev/lib/` (MIT, see `dev/lib/NOTICE`) and driven by `dev/lib/stack.py`.

Patch directories apply in order: `patches/`, `patches/insider/`
(`VSCODE_QUALITY=insider`), `patches/<os>/` (`OS_NAME`), `patches/user/`. Each
directory's `.patches` file lists its `.patch` and `.json` files in apply order.
Export regenerates it, and a file missing from it fails the import. A `.patch` is
a git mailbox applied with `git am`. A `.json` lists paths to remove
(`[{"action": "remove", "paths": [...]}]`).

The commit subject's tag names the patch file: `[00-foo] description` exports to
`00-foo.patch` in its current directory, `[linux/00-foo]` to `patches/linux/`, an
untagged commit to `patches/user/<subject>.patch`. The text after the tag heads
the patch file and the rest of the message is kept below it. Rename a patch by
editing the tag. Binary changes belong in `src/<quality>/`; export refuses them.

The tree has two states. A committed tree keeps the `!!APP_NAME!!`-style
placeholders; edit and commit patches there, and `git -C vscode reset --hard HEAD`
returns the tracked files to it. A built tree has them substituted, `product.json`
branded, `src/<quality>/` overlaid and `patches/00-update-disable.patch.yet`
applied when `DISABLE_UPDATE=yes`; every build regenerates it and it is never
committed. Export reads commits, not the tree.

The build reuses the imported stack when `patches/`, quality and OS are
unchanged, else re-imports. The build, a new rebase and normalize refuse to
discard uncommitted edits, commits past `refs/vscodium/head`, or a rebase in
progress; `dev/build.sh -f` (`VSCODIUM_FORCE_RESET=1`) overrides, as does
`rebase.sh --abort -f`. Export writes one file per commit and self-verifies by
re-importing.

`patches/{linux,alpine,windows,osx}/client/` and `reh/[<arch>/]` are not part of
the stack: `build/<os>/package_*.sh` apply them with `git apply` to the unpacked
build artifact, which is not a git checkout.

- `./dev/build.sh [-i] [-s] [-f]` — build; `-i` insider, `-s` skips the clone,
  `-f` discards unsaved work.
- `./dev/export.sh [--dry-run] [--no-verify]` — commits to patch files;
  `--dry-run` reports drift.
- `./dev/rebase.sh [<commit>] [--until <patch>]` — replay `patches/` onto a
  commit (default: `upstream/<quality>.json`; re-applies onto base when there is
  no exported stack).
- `./dev/rebase.sh --continue | --skip [<patch>] | --redo | --abort [-f] | --status`
- `./dev/verify.sh` — list imports the stack broke; run after a rebase.
- `./dev/normalize.sh` — re-export every OS of the current quality.

A rebase stops on the first conflict, with the failed hunks in `<file>.rej`. Its
state and a backup of `patches/` (restored by `--abort`) live in
`vscode/.git/vscodium-rebase/`. rerere is on: a conflict you already resolved is
replayed and only needs review. Step-by-step recipes are in
[howto-build.md](howto-build.md#patch-update-process).

---
## fix-policies

**Replace `@vscode/policy-watcher` with `@vscodium/policy-watcher`**

VS Code uses `@vscode/policy-watcher` to enforce Group Policy Objects (GPOs) on
Windows. That package reads from:

```
HKLM\SOFTWARE\Policies\Microsoft\<productName>
```

VSCodium forks this into `@vscodium/policy-watcher`, which takes a separate
`vendorName` argument. The `createWatcher()` call becomes:

```ts
createWatcher('VSCodium', this.productName, ...)
```

Because VSCodium sets `product.nameLong = 'VSCodium'` (via `prepare_vscode.sh`),
`this.productName` resolves to `'VSCodium'` at runtime. Therefore, the final
Windows registry key that VSCodium reads policies from is:

```
HKLM\SOFTWARE\Policies\VSCodium\VSCodium\<PolicyName>
```

(or `HKCU\SOFTWARE\Policies\VSCodium\VSCodium\<PolicyName>` for per-user policies)

This differs from VS Code's path (`Microsoft\VSCode`) and is the root cause of
[issue #2714](https://github.com/VSCodium/vscodium/issues/2714) where users mirror
VS Code's registry structure and find their GPOs ignored. Enterprise admins must
use the VSCodium-specific registry path.

### References

- [VSCodium issue #2714](https://github.com/VSCodium/vscodium/issues/2714)
- [VSCodium/policy-watcher — RegistryPolicy.hh](https://github.com/VSCodium/policy-watcher/blob/main/src/windows/RegistryPolicy.hh)
