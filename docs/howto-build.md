<!-- order: 35 -->

# How to build VSCodium

## Table of Contents

- [Dependencies](#dependencies)
  - [Linux](#dependencies-linux)
  - [MacOS](#dependencies-macos)
  - [Windows](#dependencies-windows)
- [Build for Development](#build-dev)
- [Build for CI/Downstream](#build-ci)
- [Build Snap](#build-snap)
- [Working on Patches](#patch-update-process)
  - [Modify an existing patch](#modify-an-existing-patch)
  - [Add a new patch](#add-a-new-patch)
  - [Update patches to a new upstream VS Code (rebase)](#update-patches-to-a-new-upstream-vs-code-rebase)
  - [Regenerate / normalize patch files](#regenerate--normalize-patch-files)

## <a id="dependencies"></a>Dependencies

- node (check [.nvmrc](../.nvmrc) for version)
- jq
- git
- python3 3.11
- rustup

### <a id="dependencies-linux"></a>Linux

- gcc
- g++
- make
- pkg-config
- libx11-dev
- libxkbfile-dev
- libsecret-1-dev
- libkrb5-dev
- fakeroot
- rpm
- rpmbuild
- dpkg
- imagemagick (for AppImage)
- snapcraft

### <a id="dependencies-macos"></a>MacOS

see [the common dependencies](#dependencies)

### <a id="dependencies-windows"></a>Windows

The build scripts are written in Bash, so on Windows you must run them inside **Git Bash** (bundled with [Git for Windows](https://gitforwindows.org/)) or **WSL2**.

#### Required tools

- **Git for Windows** — provides Git Bash, `sed`, and POSIX utilities used by the build scripts:

  ```cmd
  winget install --id Git.Git -e
  ```

- **Node.js** — exact version is specified in [`.nvmrc`](../.nvmrc). Use [nvm-windows](https://github.com/coreybutler/nvm-windows) to manage versions:

  ```cmd
  nvm install <version-from-.nvmrc>
  nvm use <version-from-.nvmrc>
  ```

  Alternatively, download directly from [nodejs.org](https://nodejs.org/). During installation, enable **"Automatically install the necessary tools"** to get the C++ build tools (required for native Node addons).

- **jq** — JSON processor used throughout the build scripts:

  ```cmd
  winget install --id jqlang.jq -e
  ```

- **7-Zip** — used to package `.zip` archives:

  ```cmd
  winget install --id 7zip.7zip -e
  ```

- **Python 3.11** — required by the VS Code build system:

  ```cmd
  winget install --id Python.Python.3.11 -e
  ```

  Ensure `python` / `python3` is on your `PATH` after installation.

- **Rustup** — required to compile some native VS Code modules:

  ```cmd
  winget install --id Rustlang.Rustup -e
  ```

  Restart your shell afterwards so `cargo` and `rustc` are on your `PATH`.

#### Optional tools

- **WiX Toolset v3** _(only needed for `.msi` installer packaging, i.e., the `-p` flag)_:

  Download from [wixtoolset.org](https://wixtoolset.org/releases/) and ensure `candle.exe` / `light.exe` are on your `PATH`.

#### PATH verification

After installing all tools, verify each is discoverable from Git Bash:

```bash
node --version    # should match .nvmrc
npm --version
jq --version
python3 --version # should be 3.11.x
cargo --version
7z i 2>&1 | head -1
git --version
```

If any command is not found, add its install directory to your `PATH` via **System Properties → Environment Variables → Path**.

## <a id="build-dev"></a>Build for Development

A build helper script can be found at `dev/build.sh`.

- Linux: `./dev/build.sh`
- MacOS: `./dev/build.sh`
- Windows (Git Bash — **recommended**): `"C:\Program Files\Git\bin\bash.exe" ./dev/build.sh`
- Windows (PowerShell): `powershell -ExecutionPolicy ByPass -File .\dev\build.ps1`

> **Note for Windows users**: Git Bash is the recommended shell because the build scripts rely on POSIX utilities (`sed`, `grep`, `find`, etc.) bundled with Git for Windows. If you use WSL2, follow the Linux dependencies section instead.

### Insider

The `insider` version can be built with `./dev/build.sh -i` on the `insider` branch.
Use `-i` there: the patch stack tracks the insider pin, and a plain (stable) build
will not apply against `upstream/stable.json`'s older commit.

You can try the latest version with the command `./dev/build.sh -il` but the patches might not be up to date.

### Flags

The script `dev/build.sh` provides several flags:

- `-i`: build the Insiders version
- `-l`: build with latest version of Visual Studio Code
- `-o`: skip the build step
- `-p`: generate the packages/assets/installers
- `-s`: do not retrieve the source code of Visual Studio Code, it won't delete the existing build
- `-f`: discard uncommitted edits and unexported commits in `vscode/` (also honoured as `VSCODIUM_FORCE_RESET=1`); without it the build refuses to destroy them

## <a id="build-ci"></a>Build for CI/Downstream

Here is the base script to build VSCodium:

```bash
# Export necessary environment variables
export SHOULD_BUILD="yes"
export SHOULD_BUILD_REH="no"
export CI_BUILD="no"
export OS_NAME="linux"
export VSCODE_ARCH="${vscode_arch}"
export VSCODE_QUALITY="stable"
export RELEASE_VERSION="${version}"

. get_repo.sh
. build.sh
```

To go further, you should look at how we build it:

- Linux: https://github.com/VSCodium/vscodium/blob/master/.github/workflows/stable-linux.yml
- macOS: https://github.com/VSCodium/vscodium/blob/master/.github/workflows/stable-macos.yml
- Windows: https://github.com/VSCodium/vscodium/blob/master/.github/workflows/stable-windows.yml

The `./dev/build.sh` script is for development purpose and must be avoided for a packaging purpose.

## <a id="build-snap"></a>Build Snap

```
# for the stable version
cd ./stores/snapcraft/stable

# for the insider version
cd ./stores/snapcraft/insider

# create the snap
snapcraft --use-lxd

# verify the snap
review-tools.snap-review --allow-classic codium*.snap
```

## <a id="patch-update-process"></a>Working on Patches

Patches apply as **git commits** on top of the pristine VS Code
checkout, one commit per patch. `vscode/` is a real branch: edit it, rebuild, run
`npm run watch`, without deleting the clone. Full model in
[patches.md](patches.md); the essentials:

- `refs/vscodium/base` — pristine upstream commit.
- `refs/vscodium/base..HEAD` — the VSCodium patch stack; every commit exports to a file.
- `refs/vscodium/head` — the commit `patches/` reproduces; anything past it is unexported
  work, which the build refuses to discard.

`./dev/build.sh` creates the clone and imports the stack. Afterwards,
`./dev/build.sh -s` reuses it and keeps committed work; it refuses to discard
uncommitted edits.

### Modify an existing patch

```bash
cd vscode
git reset --hard HEAD                        # drop the build's materialization, keep commits
git log --oneline refs/vscodium/base..HEAD    # find the patch's commit
# ...edit the source files...
git add -A && git commit --fixup <that patch's commit>
git -c sequence.editor=: rebase -i --autosquash refs/vscodium/base
cd ..
./dev/export.sh                              # rewrite that patch file from the commit
```

To test before exporting, run `./dev/build.sh -s` (which materializes the branding)
and then `npm run watch` or `./scripts/code.sh` in `vscode/`. Running them on a bare
authoring tree leaves `!!APP_NAME!!` placeholders unresolved.

### Add a new patch

No trailers, no naming rules — commit however you like, then export:

```bash
cd vscode
git reset --hard HEAD                        # drop the build's materialization, keep commits
# ...make your change...
git add -A && git commit -m "describe your change"
cd ..
./dev/export.sh
```

The commit lands in `patches/user/`, its filename derived from the subject.
Export walks to `HEAD`, so a freeform commit can never be silently dropped.

### Update patches to a new upstream VS Code (rebase)

```bash
git -C vscode reset --hard HEAD   # rebase needs a clean tree
./dev/rebase.sh <new-ms-commit>   # or no arg to use upstream/<quality>.json
# run `git -C vscode status` and resolve each row by the label git gives it:
#   both modified    edit out the <<<<<<< markers, then `git add`
#   deleted by us    upstream deleted a file this patch edits — `git rm` it and drop
#                    that hunk (`git add` would resurrect the deleted file)
#   deleted by them  this patch deletes a file upstream edited — `git rm` to keep it deleted
./dev/rebase.sh --continue        # finishes the rebase and re-anchors the base ref
./dev/export.sh                   # regenerate patch files against the new base
```

Remember to bump `upstream/<quality>.json` to the new commit as well, so a fresh
clone builds against the upstream the patches were rebased onto.

### A patch failed to apply

The import names the failing patch file and the underlying `git am` error, then aborts
so the clone stays usable. After a version bump, re-sync the whole stack with
`./dev/rebase.sh` (above) rather than patching one file at a time.

To fix a single patch, edit the **patch file** and re-run the build — the clone is
rebuilt from `patches/` every time, so the patch file is the thing to correct:

```bash
# the import prints which file failed; fix that file, then re-import:
$EDITOR patches/<dir>/<the-failing-patch>
./dev/build.sh -s     # repeat until the stack applies
```

The clone is rebuilt from `patches/` on every import, so the patch file is the thing
to correct — there is no commit to amend until the stack applies again.

> `./dev/export.sh` rewrites `patches/` from the commits it finds, so run it only once
> the whole stack imports; exporting a partially-imported clone would drop the rest.

### Regenerate / normalize patch files

- `./dev/export.sh` — rewrite the current config's patches from the commits.
- `./dev/export.sh --dry-run` — check `patches/` still matches the commits, writing nothing.
- `./dev/normalize.sh` — rewrite **all** patches to the canonical format
  (run against the correct base; see the script header).

> The old `dev/patch.sh`, `dev/update_patches.sh` and `dev/merge-patches.sh`
> (with their `*.rej` / "VSCODIUM HELPER" workflow) are deprecated; each prints
> the equivalent commit-based command.

### <a id="icons"></a>icons/build_icons.sh

To run `icons/build_icons.sh`, you will need:

- imagemagick
- png2icns (`npm install png2icns -g`)
- librsvg
