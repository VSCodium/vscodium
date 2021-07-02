# Build

## Table of Contents

- [Dependencies](#dependencies)
  - [Linux](#dependencies-linux)
  - [MacOS](#dependencies-macos)
  - [Windows](#dependencies-windows)
- [Build Scripts](#build-scripts)
- [Build in Docker](#build-docker)

## <a id="dependencies"></a>Dependencies

- node 12
- yarn
- jq

### <a id="dependencies-linux"></a>Linux

- libx11-dev
- libxkbfile-dev
- libsecret-1-dev
- fakeroot
- rpm

### <a id="dependencies-macos"></a>MacOS

### <a id="dependencies-windows"></a>Windows

- powershell
- git
- sed

## <a id="build-scripts"></a>Build Scripts

Each platform has its build helper script in the directory `build`.

- Linux: `./build/build_linux.sh`
- MacOS: `./build/build_macos_.sh`
- Windows: `powershell -ExecutionPolicy ByPass -File .\build\build_windows.ps1`

## <a id="build-docker"></a>Build in Docker

To build for Linux, you can alternatively build VSCodium in docker

Firstly, create the container with:
```
docker run -ti --volume=<local vscodium source>:/root/vscodium --name=vscodium-build-agent vscodium/vscodium-linux-build-agent:bionic-x64 bash
```

When inside the container, you can use the following commands to build:
```
curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

npm install -g yarn

git clone https://github.com/VSCodium/vscodium.git

cd vscodium

./get_repo.sh

export SHOULD_BUILD=yes
export OS_NAME=linux
export VSCODE_ARCH=x64

./build.sh
```