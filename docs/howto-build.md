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
  - [Semi-Automated](#patch-update-process-semiauto)
  - [Manual](#patch-update-process-manual)

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

## <a id="patch-update-process-semiauto"></a>Semi-Automated

- run `./dev/build.sh`, if a patch is failing then,
- run `./dev/update_patches.sh`
- when the script pauses at `Press any key when the conflict have been resolved...`, open `vscode` directory in **VSCodium**
- fix all the `*.rej` files
- run `npm run watch`
- run `./script/code.sh` until everything is ok
- press any key to continue the script `update_patches.sh`

## <a id="patch-update-process-manual"></a>Manual

- run `./dev/build.sh`, if a patch is failing then,
- run `./dev/patch.sh <name>.patch` where `<name>.patch` is the failed patch
- open `vscode` directory in a new **VSCodium**'s window
- fix all the `*.rej` files
- run `npm run watch`
- run `./script/code.sh` until everything is ok
- go back to the command line running `./dev/patch.sh`, press `enter` to validate the changes and it will update the patch

### <a id="icons"></a>icons/build_icons.sh

To run `icons/build_icons.sh`, you will need:

- imagemagick
- png2icns (`npm install png2icns -g`)
- librsvg
