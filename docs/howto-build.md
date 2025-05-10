<!-- order: 35 -->

# How to build Codex

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

- node 20.18
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

- powershell
- sed
- 7z
- [WiX Toolset](http://wixtoolset.org/releases/)
- 'Tools for Native Modules' from the official Node.js installer

## <a id="build-dev"></a>Build for Development

A build helper script can be found at `dev/build.sh`.

- Linux: `./dev/build.sh`
- MacOS: `./dev/build.sh`
- Windows: `powershell -ExecutionPolicy ByPass -File .\dev\build.ps1` or `"C:\Program Files\Git\bin\bash.exe" ./dev/build.sh`

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

Here is the base script to build Codex:

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
- Linux: https://github.com/BiblioNexus-Foundation/codex/blob/master/.github/workflows/stable-linux.yml
- macOS: https://github.com/BiblioNexus-Foundation/codex/blob/master/.github/workflows/stable-macos.yml
- Windows: https://github.com/BiblioNexus-Foundation/codex/blob/master/.github/workflows/stable-windows.yml

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
review-tools.snap-review --allow-classic codex*.snap
```

## <a id="patch-update-process"></a>Patch Update Process

## <a id="patch-update-process-semiauto"></a>Semi-Automated

- run `./dev/build.sh`, if a patch is failing then,
- run `./dev/update_patches.sh`
- when the script pauses at `Press any key when the conflict have been resolved...`, open `vscode` directory in **Codex**
- fix all the `*.rej` files
- run `npm run watch`
- run `./script/code.sh` until everything is ok
- press any key to continue the script `update_patches.sh`

## <a id="patch-update-process-manual"></a>Manual

- run `./dev/build.sh`, if a patch is failing then,
- run `./dev/patch.sh <name>.patch` where `<name>.patch` is the failed patch
- open `vscode` directory in a new **Codex**'s window
- fix all the `*.rej` files
- run `npm run watch`
- run `./script/code.sh` until everything is ok
- go back to the command line running `./dev/patch.sh`, press `enter` to validate the changes and it will update the patch

### <a id="icons"></a>icons/build_icons.sh

To run `icons/build_icons.sh`, you will need:

- imagemagick
- png2icns (`npm install png2icns -g`)
- librsvg
