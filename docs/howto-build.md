# How to build VSCodium

## Table of Contents

- [Dependencies](#dependencies)
  - [Linux](#dependencies-linux)
  - [MacOS](#dependencies-macos)
  - [Windows](#dependencies-windows)
- [Build Scripts](#build-scripts)
- [Build Snap](#build-snap)
- [Patch Update Process](#patch-update-process)
  - [Semi-Automated](#patch-update-process-semiauto)
  - [Manual](#patch-update-process-manual)

## <a id="dependencies"></a>Dependencies

- node 20.14
- yarn
- jq
- git
- python3 3.11

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

## <a id="build-scripts"></a>Build Scripts

A build helper script can be found at `build/build.sh`.

- Linux: `./build/build.sh`
- MacOS: `./build/build.sh`
- Windows: `powershell -ExecutionPolicy ByPass -File .\build\build.ps1` or `"C:\Program Files\Git\bin\bash.exe" ./build/build.sh`

### Insider

The `insider` version can be built with `./build/build.sh -i` on the `insider` branch.

You can try the latest version with the command `./build/build.sh -il` but the patches might not be up to date.

### Flags

The script `build/build.sh` provides several flags:

- `-i`: build the Insiders version
- `-l`: build with latest version of Visual Studio Code
- `-o`: skip the build step
- `-p`: generate the packages/assets/installers
- `-s`: do not retrieve the source code of Visual Studio Code, it won't delete the existing build

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

- run `./build/build_<os>.sh`, if a patch is failing then,
- run `./build/update_patches.sh`
- when the script pauses at `Press any key when the conflict have been resolved...`, open `vscode` directory in **VSCodium**
- fix all the `*.rej` files
- run `yarn watch`
- run `./script/code.sh` until everything is ok
- press any key to continue the script `update_patches.sh`

## <a id="patch-update-process-manual"></a>Manual

- run `./build/build_<os>.sh`, if a patch is failing then,
- open `vscode` directory in **VSCodium**
- revert all changes
- run `git apply --reject ../patches/<name>.patch`
- fix all the `*.rej` files
- run `yarn watch`
- run `./script/code.sh` until everything is ok
- run `git diff > ../patches/<name>.patch`

### <a id="icons"></a>icons/build_icons.sh

To run `icons/build_icons.sh`, you will need:

- imagemagick
- png2icns (`npm install png2icns -g`)
- librsvg
