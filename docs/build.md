# Build

## Table of Contents

- [Dependencies](#dependencies)
  - [Linux](#dependencies-linux)
  - [MacOS](#dependencies-macos)
  - [Windows](#dependencies-windows)
- [Build Scripts](#build-scripts)
- [Build in Docker](#build-docker)
  - [X64](#build-docker-x64)
  - [ARM 32bits](#build-docker-arm32)
- [Patch Update Process](#patch-update-process)
  - [Semi-Automated](#patch-update-process-semiauto)
  - [Manual](#patch-update-process-manual)

## <a id="dependencies"></a>Dependencies

- node 16
- yarn
- jq
- git

### <a id="dependencies-linux"></a>Linux

- GCC
- make
- pkg-config
- libx11-dev
- libxkbfile-dev
- libsecret-1-dev
- fakeroot
- rpm
- rpmbuild
- dpkg
- python3
- imagemagick (for AppImage)

### <a id="dependencies-macos"></a>MacOS

### <a id="dependencies-windows"></a>Windows

- powershell
- sed
- 7z
- [WiX Toolset](http://wixtoolset.org/releases/)
- python3
- 'Tools for Native Modules' from official Node.js installer

## <a id="build-scripts"></a>Build Scripts

Each platform has its build helper script in the directory `build`.

- Linux: `./build/build_linux.sh`
- MacOS: `./build/build_macos.sh`
- Windows: `powershell -ExecutionPolicy ByPass -File .\build\build_windows.ps1`

## <a id="build-docker"></a>Build in Docker

To build for Linux, you can alternatively build VSCodium in docker

### <a id="build-docker-x64"></a>X64

Firstly, create the container with:
```
docker run -ti --volume=<local vscodium source>:/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-x64 bash
```
like
```
docker run -ti --volume=$(pwd):/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-x64 bash
```

When inside the container, you can use the following commands to build:
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs desktop-file-utils

npm install -g yarn

cd /root/vscodium

. get_repo.sh

export SHOULD_BUILD=yes
export OS_NAME=linux
export VSCODE_ARCH=x64

. build.sh
```

### <a id="build-docker-arm32"></a>ARM 32bits

Firstly, create the container with:
```
docker run -ti --volume=<local vscodium source>:/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:stretch-armhf bash
```
like
```
docker run -ti --volume=$(pwd):/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:stretch-armhf bash
```

When inside the container, you can use the following commands to build:
```
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs desktop-file-utils

cd /root/vscodium

. get_repo.sh

export SHOULD_BUILD=yes
export OS_NAME=linux
export VSCODE_ARCH=armhf
export npm_config_arch=armv7l
export npm_config_force_process_config="true"

. build.sh
```

## <a id="patch-update-process"></a>Patch Update Process

## <a id="patch-update-process-semiauto"></a>Semi-Automated

- run `./build/build_<os>.sh`, if a patch is failing then,
- run `./build/update_patches.sh`
- when the script pause at `Press any key when the conflict have been resolved...`, open `vscode` directory in **VSCodium**
- fix all the `*.rej` files
- run `yarn watch`
- run `./script/code.sh` until everything ok
- press any key to continue the script `update_patches.sh`

## <a id="patch-update-process-manual"></a>Manual

- run `./build/build_<os>.sh`, if a patch is failing then,
- open `vscode` directory in **VSCodium**
- revert all changes
- run `git apply --reject ../patches/<name>.patch`
- fix all the `*.rej` files
- run `yarn watch`
- run `./script/code.sh` until everything ok
- run `git diff > ../patches/<name>.patch`
