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
- [Patch Update Process](#patch-update-process)
  - [Modify a patch](#patch-modify)
  - [Add a patch](#patch-add)
  - [Remove a patch](#patch-remove)
  - [Update to a new VS Code](#patch-rebase)
  - [Normalize](#patch-normalize)

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

You can try the latest version with the command `./dev/build.sh -il` but the patches might not be up to date.

### Flags

The script `dev/build.sh` provides several flags:

- `-i`: build the Insiders version
- `-l`: build with latest version of Visual Studio Code
- `-o`: skip the build step
- `-p`: generate the packages/assets/installers
- `-s`: do not retrieve the source code of Visual Studio Code, it won't delete the existing build
- `-f`: discard uncommitted edits and unexported commits in `vscode/` (or `VSCODIUM_FORCE_RESET=1`)

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

## <a id="patch-update-process"></a>Patch Update Process

`vscode/` is a git branch: `refs/vscodium/base` is the upstream commit, and each patch file is one commit on top of it, in apply order (`patches/`, `patches/insider/`, `patches/<os>/`, `patches/user/`). See [patches.md](patches.md).

- `./dev/build.sh` clones VS Code and imports the stack; `-s` reuses the clone, and keeps the commits while `patches/` is unchanged; the build refuses to discard uncommitted edits or commits not yet in `patches/` unless `-f` is given
- the build leaves the branding uncommitted on top of the stack; before editing, run `git reset --hard HEAD` in `vscode/` to drop it, commits keep the `!!APP_NAME!!` tokens
- each commit subject starts with its patch name, without `.patch`: `[00-foo] <description>`
- `./dev/export.sh` rewrites the patch files and `.patches` manifests from the commits; `--dry-run` only reports drift
- `dev/patch.sh`, `dev/update_patches.sh` and `dev/merge-patches.sh` are deprecated; each prints its replacement

### <a id="patch-modify"></a>Modify a patch

- find the commit with `git log --oneline refs/vscodium/base..HEAD`
- edit the source, then run `git add -A && git commit --fixup <commit>`
- run `git -c sequence.editor=: rebase -i --autosquash refs/vscodium/base`
- run `./dev/export.sh`

To test, run `./dev/export.sh`, then `./dev/build.sh -s` and `npm run watch` / `./scripts/code.sh` in `vscode/`.

### <a id="patch-add"></a>Add a patch

- make the change, then run `git add -A && git commit -m "[00-area-what-it-does] describe the change"`
- run `./dev/export.sh`, it writes `patches/00-area-what-it-does.patch`
- `[linux/00-foo]` writes to `patches/linux/`, `[user/foo]` to `patches/user/`; a commit without a tag lands in `patches/user/`
- a commit tagged `[NN-name.json]` must only `git rm` files; it is written as `patches/NN-name.json`
- a new commit sits above the whole stack; if `export` warns it is out of order, move it down with `git rebase -i refs/vscodium/base` or tag it `[user/...]`

### <a id="patch-remove"></a>Remove a patch

Drop the commit with `git rebase -i refs/vscodium/base` in `vscode/`, then run `./dev/export.sh`: it deletes the patch file and updates `.patches`.

### <a id="patch-rebase"></a>Update to a new VS Code

Run the rebase on the clone of the previous version, before changing `upstream/<quality>.json`, so git can 3-way merge. When `./dev/build.sh` fails on a stale patch, its message prints the `./dev/rebase.sh` command to run; with no argument it replays the stack onto the commit the build cloned.

- run `./dev/rebase.sh <tag or commit>`
- on a conflict the script stops and lists the files
- fix the conflict markers, or apply the hunks from `<file>.rej` and delete it, then `git add` the file (`git rm` it if it should stay deleted)
- run `./dev/rebase.sh --continue`
- when it finishes, run `./dev/verify.sh`, it lists the imports the stack broke
- run `./dev/export.sh`
- repeat the rebase and export for the two other OSes: `OS_NAME=<os> ./dev/rebase.sh <tag or commit>` then `./dev/export.sh` (`linux`, `osx`, `windows`)
- set `commit` and `tag` in `upstream/<quality>.json` to the new version
- run `./dev/build.sh -s`
- `.json` patches never conflict: paths gone upstream are dropped and reported
- no 3-way merge on a fresh clone or after changing the pin: the failed hunks are left in `.rej` files
- insider: `./dev/build.sh -il`, then `./dev/rebase.sh`, `./dev/export.sh`, `./dev/build.sh -ils` (writes `upstream/insider.json`)

`./dev/rebase.sh` flags:

- `--status`: show applied, skipped and pending patches
- `--skip`: drop the patch that stopped; `--skip <patch>` drops a pending one
- `--redo`: undo the last applied patch and apply it again
- `--until <patch>`: stop after that patch; `Ctrl-C` pauses between patches
- `--abort`: restore `vscode/` and `patches/`; add `-f` to discard rebased commits and patches exported mid-rebase

`./dev/export.sh` works mid-rebase: it writes the patches rebased so far and leaves the pending ones untouched.

### <a id="patch-normalize"></a>Normalize

`./dev/normalize.sh` rewrites the patches of every OS to the canonical format; run it on a clone of the quality's base:

```bash
./dev/normalize.sh
VSCODE_QUALITY=insider ./dev/normalize.sh
```

### <a id="icons"></a>icons/build_icons.sh

To run `icons/build_icons.sh`, you will need:

- imagemagick
- png2icns (`npm install png2icns -g`)
- librsvg
