# VSCodium

### Free/Libre Open Source Software Binaries of VSCode
[![build status](https://travis-ci.com/VSCodium/vscodium.svg?branch=master)](https://travis-ci.com/VSCodium/vscodium) 
[![current release](https://img.shields.io/github/release/vscodium/vscodium.svg)](https://github.com/vscodium/vscodium/releases)
[![license](https://img.shields.io/github/license/VSCodium/vscodium.svg)](https://github.com/VSCodium/vscodium/blob/master/LICENSE)

## Table of Contents
- [Download/Install](#download-install)
  - [Install with Brew](#install-with-brew)
  - [Install with Package Manager](#install-with-package-manager)
- [Why Does This Exist](#why)
- [More Info](#more-info)
- [Supported OS](#supported-os)

## <a id="download-install"></a>Download/Install
:tada: :tada: [Download latest release here](https://github.com/VSCodium/vscodium/releases) :tada: :tada:

#### <a id="install-with-brew"></a>Install with Brew (Mac)
If you are on a Mac and have [Homebrew](https://brew.sh/) installed:
```bash
brew cask install vscodium
```

_Note: if you see "App can’t be opened because it is from an unidentified developer" when opening VSCodium the first time, you can right-click the application and choose Open. This should only be required the first time opening on a Mac._

#### <a id="install-with-package-manager"></a>Install with Package Manager (Linux)
You can always install using the downloads (deb, rpm, tar) on the [releases page](https://github.com/VSCodium/vscodium/releases), but you can also install using your favorite package manager and get automatic updates. [@paulcarroty](https://github.com/paulcarroty) has set up a repository with instructions [here](https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo). Any issues installing VSCodium using your package manager should be directed to that repository's issue tracker. 

## <a id="why"></a>Why Does This Exist
This repository contains a build file to generate FLOSS release binaries of Microsoft's VSCode.

Microsoft's downloads of Visual Studio Code are licensed under [this not-FLOSS license](https://code.visualstudio.com/license) and contain telemetry/tracking. According to [this comment](https://github.com/Microsoft/vscode/issues/60#issuecomment-161792005) from a Visual Studio Code maintainer: 

> When we [Microsoft] build Visual Studio Code, we do exactly this. We clone the vscode repository, we lay down a customized product.json that has Microsoft specific functionality (telemetry, gallery, logo, etc.), and then produce a build that we release under our license.
> 
> When you clone and build from the vscode repo, none of these endpoints are configured in the default product.json. Therefore, you generate a "clean" build, without the Microsoft customizations, which is by default licensed under the MIT license

This repo exists so that you don't have to download+build from source. The build scripts in this repo clone Microsoft's vscode repo, run the build commands, and upload the resulting binaries to [GitHub releases](https://github.com/VSCodium/vscodium/releases). __These binaries are licensed under the MIT license. Telemetry is enabled by a build flag which we do not pass.__

If you want to build from source yourself, head over to [Microsoft's vscode repo](https://github.com/Microsoft/vscode) and follow their [instructions](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#build-and-run). This repo exists to make it easier to get the latest version of MIT-licensed VSCode.

Microsoft's build process does download additional files. This was brought up in [Microsoft/vscode#49159](https://github.com/Microsoft/vscode/issues/49159) and [Microsoft/vscode#45978](https://github.com/Microsoft/vscode/issues/45978). These are the packages downloaded during build:

- Extensions from the Microsoft Marketplace:
  - ms-vscode.node-debug2
  - ms-vscode.node-debug
- From [Electron releases](https://github.com/electron/electron/releases) (using [gulp-atom-electron](https://github.com/joaomoreno/gulp-atom-electron))
  - electron
  - ffmpeg

## <a id="more-info"></a>More Info
For more information on getting all the telemetry disabled and tips for migrating from Visual Studio Code to VSCodium, have a look at this [Docs](https://github.com/VSCodium/vscodium/blob/master/DOCS.md) page.

## <a id="supported-os"></a>Supported OS
- [x] OSX x64 (zipped app file)
- [x] Linux x64 (`.deb`, `.rpm`, and `.tar.gz` files)
- [x] Linux x86 (`.deb`, `.rpm`, and `.tar.gz` files)
- [ ] Windows
  - The plan is to build the Windows executable with [AppVeyor](https://appveyor.com). PRs are welcome :blue_heart:
  
The ARM architecture is not currently supported but is actively being worked on.

## <a id="license"></a>License
MIT
