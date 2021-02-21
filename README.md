<div id="vscodium-logo" align="center">
    <br />
    <img src="./src/resources/linux/code.png" alt="VSCodium Logo" width="200"/>
    <h1>VSCodium</h1>
    <h3>Free/Libre Open Source Software Binaries of VSCode</h3>
</div>

<div id="badges" align="center">

  [![current release](https://img.shields.io/github/release/vscodium/vscodium.svg)](https://github.com/vscodium/vscodium/releases)
[![windows_build_status](https://dev.azure.com/vscodium/VSCodium/_apis/build/status/VSCodium.vscodium?branchName=master)](https://dev.azure.com/vscodium/VSCodium/_build?definitionId=1)
[![license](https://img.shields.io/github/license/VSCodium/vscodium.svg)](https://github.com/VSCodium/vscodium/blob/master/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/vscodium/vscodium.svg)](https://gitter.im/VSCodium/Lobby)
[![codium](https://snapcraft.io//codium/badge.svg)](https://snapcraft.io/codium)
[![codium](https://snapcraft.io//codium/trending.svg?name=0)](https://snapcraft.io/codium)

</div>

**This is not a fork. This is a repository of scripts to automatically build Microsoft's `vscode` repository into freely-licensed binaries with a community-driven default configuration.**

## Table of Contents
- [Table of Contents](#table-of-contents)
- [<a id="download-install"></a>Download/Install](#downloadinstall)
    - [<a id="install-with-brew"></a>Install with Brew (Mac)](#install-with-brew-mac)
    - [<a id="install-with-winget"></a>Install with Windows Package Manager (WinGet)](#install-with-windows-package-manager-winget)
    - [<a id="install-with-choco"></a>Install with Chocolatey (Windows)](#install-with-chocolatey-windows)
    - [<a id="install-with-scoop"></a>Install with Scoop (Windows)](#install-with-scoop-windows)
    - [<a id="install-with-snap"></a>Install with snap (Linux)](#install-with-snap-linux)
    - [<a id="install-with-package-manager"></a>Install with Package Manager (Linux)](#install-with-package-manager-linux)
    - [<a id="install-on-arch-linux"></a>Install on Arch Linux](#install-on-arch-linux)
    - [<a id="flatpak"></a>Flatpak Option (Linux)](#flatpak-option-linux)
- [<a id="why"></a>Why Does This Exist](#why-does-this-exist)
- [<a id="more-info"></a>More Info](#more-info)
  - [Documentation](#documentation)
  - [Extensions and the Marketplace](#extensions-and-the-marketplace)
  - [How are the VSCodium binaries built?](#how-are-the-vscodium-binaries-built)
- [<a id="supported-os"></a>Supported OS](#supported-os)
- [<a id="donate"></a>Donate](#donate)
- [<a id="license"></a>License](#license)

## <a id="download-install"></a>Download/Install
:tada: :tada: [Download latest release here](https://github.com/VSCodium/vscodium/releases) :tada: :tada:

[More info / helpful tips are here.](https://github.com/VSCodium/vscodium/blob/master/DOCS.md)

#### <a id="install-with-brew"></a>Install with Brew (Mac)
If you are on a Mac and have [Homebrew](https://brew.sh/) installed:
```bash
brew install --cask vscodium
```

_Note for Mac macOS Mojave users: if you see "App can't be opened because Apple cannot check it for malicious software" when opening VSCodium the first time, you can right-click the application and choose Open. This should only be required the first time opening on Mojave._

#### <a id="install-with-winget"></a>Install with Windows Package Manager (WinGet)
If you use Windows and have [Windows Package Manager](https://github.com/microsoft/winget-cli) installed:
```bash
winget install vscodium
```

#### <a id="install-with-choco"></a>Install with Chocolatey (Windows)
If you use Windows and have [Chocolatey](https://chocolatey.org) installed (thanks to [@Thilas](https://github.com/Thilas)):
```bash
choco install vscodium
```

#### <a id="install-with-scoop"></a>Install with Scoop (Windows)
If you use Windows and have [Scoop](https://scoop.sh) installed:
```bash
scoop bucket add extras
scoop install vscodium
```

#### <a id="install-with-snap"></a>Install with snap (Linux)
VSCodium is available in the [Snap Store](https://snapcraft.io/) as [Codium](https://snapcraft.io/codium), published by the [Snapcrafters](https://github.com/snapcrafters/codium) community.
If your Linux distribution has support for [snaps](https://snapcraft.io/docs/installing-snapd):
```bash
snap install codium
```

#### <a id="install-with-package-manager"></a>Install with Package Manager (Linux)
You can always install using the downloads (deb, rpm, tar) on the [releases page](https://github.com/VSCodium/vscodium/releases), but you can also install using your favorite package manager and get automatic updates. [@paulcarroty](https://github.com/paulcarroty) has set up a repository with instructions [here](https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo). Any issues installing VSCodium using your package manager should be directed to that repository's issue tracker. 

#### <a id="install-on-arch-linux"></a>Install on Arch Linux
VSCodium is available in [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) as package [vscodium-bin](https://aur.archlinux.org/packages/vscodium-bin/), maintained by [@binex-dsk](https://github.com/binex-dsk). An alternative package [vscodium-git](https://aur.archlinux.org/packages/vscodium-git/), maintained by [@cedricroijakkers](https://github.com/cedricroijakkers), is also available should you wish to compile from source yourself.

#### <a id="flatpak"></a>Flatpak Option (Linux)
VSCodium is (unofficially) available as a Flatpak app [here](https://flathub.org/apps/details/com.vscodium.codium) and the build repo is [here](https://github.com/flathub/com.vscodium.codium). If your distribution has support for [flatpak](https://flathub.org), and you have enabled the [flathub repo](https://flatpak.org/setup/):
```bash
flatpak install flathub com.vscodium.codium

flatpak run com.vscodium.codium
```

## <a id="why"></a>Why Does This Exist
This repository contains build files to generate free release binaries of Microsoft's VSCode. When we speak of "free software", we're talking about freedom, not price.

Microsoft's releases of Visual Studio Code are licensed under [this not-FLOSS license](https://code.visualstudio.com/license) and contain telemetry/tracking. According to [this comment](https://github.com/Microsoft/vscode/issues/60#issuecomment-161792005) from a Visual Studio Code maintainer: 

> When we [Microsoft] build Visual Studio Code, we do exactly this. We clone the vscode repository, we lay down a customized product.json that has Microsoft specific functionality (telemetry, gallery, logo, etc.), and then produce a build that we release under our license.
> 
> When you clone and build from the vscode repo, none of these endpoints are configured in the default product.json. Therefore, you generate a "clean" build, without the Microsoft customizations, which is by default licensed under the MIT license

This repo exists so that you don't have to download+build from source. The build scripts in this repo clone Microsoft's vscode repo, run the build commands, and upload the resulting binaries to [GitHub releases](https://github.com/VSCodium/vscodium/releases). __These binaries are licensed under the MIT license. Telemetry is disabled.__

If you want to build from source yourself, head over to [Microsoft's vscode repo](https://github.com/Microsoft/vscode) and follow their [instructions](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#build-and-run). This repo exists to make it easier to get the latest version of MIT-licensed VSCode.

Microsoft's build process (which we are running to build the binaries) does download additional files. This was brought up in [Microsoft/vscode#49159](https://github.com/Microsoft/vscode/issues/49159) and [Microsoft/vscode#45978](https://github.com/Microsoft/vscode/issues/45978). These are the packages downloaded during build:

- Extensions from the Microsoft Marketplace:
  - ms-vscode.node-debug2
  - ms-vscode.node-debug
- From [Electron releases](https://github.com/electron/electron/releases) (using [gulp-atom-electron](https://github.com/joaomoreno/gulp-atom-electron))
  - electron
  - ffmpeg

## <a id="more-info"></a>More Info

### Documentation
For more information on getting all the telemetry disabled and tips for migrating from Visual Studio Code to VSCodium, have a look at this [Docs](https://github.com/VSCodium/vscodium/blob/master/DOCS.md) page.

### Extensions and the Marketplace
According to the VS Code Marketplace [Terms of Use](https://aka.ms/vsmarketplace-ToU), _you may only install and use Marketplace Offerings with Visual Studio Products and Services._ For this reason, VSCodium uses [open-vsx.org](https://open-vsx.org/), an open source registry for VS Code extensions. See the [Extensions + Marketplace](https://github.com/VSCodium/vscodium/blob/master/DOCS.md#extensions-marketplace) section on the Docs page for more details.

Please note that some Visual Studio Code extensions have licenses that restrict their use to the official Visual Studio Code builds and therefore do not work with VSCodium. See [this note](https://github.com/VSCodium/vscodium/blob/master/DOCS.md#proprietary-debugging-tools) on the Docs page for what's been found so far and possible workarounds.

### How are the VSCodium binaries built?
If you would like to see the commands we run to build `vscode` into VSCodium binaries, have a look at the workflow files in `.github/workflow` (for Linux and macOS builds) and the `win32-build.yml` file (for Windows builds). These build files call all the other scripts in the repo. If you find something that doesn't make sense, feel free to ask about it [on Gitter](https://gitter.im/VSCodium/Lobby).

The builds are run every day, but exit early if there isn't a new release from Microsoft. 

## <a id="supported-os"></a>Supported OS
- [x] macOS (`zip`, `dmg`)
- [x] Linux x64 (`deb`, `rpm`, `AppImage`, `tar.gz`)
- [x] Linux x86 (`deb`, `rpm`, `tar.gz`) ([up to v1.35.1](https://code.visualstudio.com/updates/v1_36#_linux-32bit-support-ends))
- [x] Linux arm64 (`deb`, `tar.gz`)
- [x] Linux armhf (`deb`, `tar.gz`)
- [x] Windows x64
- [x] Windows x86
  
## <a id="donate"></a>Donate
If you would like to support the development of VSCodium, feel free to send BTC to `3PgjE95yzBDTrSPxPiqoxSgZFuKPPAix1N`.

Special thanks to:
- @estatra for the latest logo
- @jaredreich for the previous logo

## <a id="license"></a>License
[MIT](https://github.com/VSCodium/vscodium/blob/master/LICENSE).