# Patches

Documentation for VSCodium patches applied on top of VS Code.

---

## How patches work

Each patch applies as a **git commit** in the `vscode/` checkout, on top of the
pristine upstream VS Code commit. Import and export are handled by the vendored
Electron patch core (`dev/lib/git.py`, `dev/lib/patches.py`; MIT-licensed, see
`dev/lib/NOTICE`) driven by a thin orchestrator (`dev/lib/stack.py`); the
`dev/*.sh` scripts wrap it.

### Directories and `.patches` manifests

Patches live in ordered directories, applied in sequence:

| Directory | When applied |
| --- | --- |
| `patches/` | always (root) |
| `patches/insider/` | `VSCODE_QUALITY=insider` |
| `patches/<os>/` | the OS being built (`linux`/`windows`/`osx`) |
| `patches/user/` | always (your own patches) |

Each directory carries a `.patches` file — an ordered list of its patch
filenames — which defines apply order (as in Electron), regenerated on every
export. Whole-file removals stay as `patches/*.json`, are applied first, and are
never re-exported. Patch files are plain git mailboxes with **no metadata
trailers**; at import each commit is tagged with a `Patch-Dir:` trailer (its
origin directory) so export can group commits back, and the trailer is stripped
from the written file.

### Freeform commits — no required message format

Edit the source, then commit however you like and export:

```bash
cd vscode
git reset --hard HEAD                 # drop the build's materialization (keeps your commits)
git add -A && git commit -m "whatever describes your change"
cd ..
./dev/export.sh
```

Export writes every commit in `refs/vscodium/base..HEAD` to a file: the filename
is derived from the commit subject, the directory from the `Patch-Dir:` trailer
(new commits default to `patches/user/`). **No commit is ever silently dropped** —
export walks to `HEAD` (never a stale ref), writes a file for every non-`.json`
commit (suffixing the filename if two commits share a subject), and self-verifies by
re-importing and asserting the tree still matches `HEAD`.

### Refs

| Ref | Meaning |
| --- | --- |
| `refs/vscodium/base` | pristine upstream commit (recorded by `get_repo.sh`) |
| `refs/vscodium/head` | the commit `patches/` reproduces — moved only by import and export |

Because only import and export move it, any commit past `refs/vscodium/head` is work
that no patch file holds yet, which is what the build refuses to discard.

### Two tree states

- **Authoring** — `git reset --hard HEAD`: drops the build's materialization and
  leaves a clean committed tree that still holds the `!!APP_NAME!!`-style
  placeholders (your own commits are kept). Edit patches here.
- **Build/run** — authoring plus a "materialize" pass (placeholder resolution,
  `product.json` branding, the asset overlay, and config-gated overlays such as the
  `DISABLE_UPDATE=yes` update-mode default). This is what a build or `npm run watch`
  sees. It is git-dirty by design and regenerated every build; `dev/export.sh`
  ignores it, reading the **commits** rather than the tree.

Placeholders live in the commits and are never resolved into them, so patch files
round-trip through import/export unchanged: no lossy reverse substitution of
branding strings.

### Guard rails

- The build refuses to discard uncommitted edits or commits not yet written to
  `patches/`, whether it would reclone or re-import the stack. Commit and run
  `./dev/export.sh` first, or pass `dev/build.sh -f` (`VSCODIUM_FORCE_RESET=1`) to discard.
- Import fails loudly if a patch directory has `.patch` files its `.patches`
  manifest does not cover, so a patch can never be silently skipped.

Always author from a clean tree (`git reset --hard HEAD` in `vscode/`). Committing a
tree a build has materialized would bake resolved branding into the patch in place of
the `!!TOKEN!!` placeholders.

### Variant patches

Most patches are commits imported with `git am`. The exception is the per-variant
patches under `patches/<os>/client/`, `patches/<os>/reh/`, and
`patches/<os>/reh/<arch>/`: the packaging scripts (`build/<os>/package_*.sh`)
apply them with `apply_patch` (`git apply`), not the commit stack.

Packaging untars the compiled artifact (`vscode.tar.gz`) into a fresh tree and
applies the delta for the build being packaged (client vs REH, per architecture).
That tree is not a git checkout, so there is no `HEAD` to `git am` onto, and it is
discarded after packaging. These patches stay plain diffs outside the stack.

### Commands

- `./dev/build.sh` / `./dev/build.sh -s` — build (import the stack / reuse it).
- `./dev/export.sh [--dry-run] [--no-verify]` — commits → patch files (self-verifying).
- `./dev/rebase.sh <commit>` — replay the stack onto a new upstream (3-way).
- `./dev/normalize.sh` — re-export all patches in canonical form.

See [howto-build.md](howto-build.md#patch-update-process) for the step-by-step
edit/add/rebase recipes.

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
