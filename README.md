<div id="codex-logo" align="center">
    <br />
    <img src="./icons/stable/codex_cnl.svg" alt="Codex Logo" width="200"/>
    <h1>Codex</h1>
    <h3>Free/Libre Open Source Software Binaries of VS Code</h3>
</div>

<div id="badges" align="center">

[![current release](https://img.shields.io/github/release/codex/codex.svg)](https://github.com/codex/codex/releases)
[![license](https://img.shields.io/github/license/BiblioNexus-Foundation/codex.svg)](https://github.com/BiblioNexus-Foundation/codex/blob/master/LICENSE)
[![Gitter](https://img.shields.io/gitter/room/codex/codex.svg)](https://gitter.im/Codex/Lobby)
[![codex](https://snapcraft.io//codex/badge.svg)](https://snapcraft.io/codex)
[![codex](https://snapcraft.io//codex/trending.svg?name=0)](https://snapcraft.io/codex)

[![build status (linux)](https://img.shields.io/github/actions/workflow/status/BiblioNexus-Foundation/codex/stable-linux.yml?branch=master&label=build%28linux%29)](https://github.com/BiblioNexus-Foundation/codex/actions/workflows/stable-linux.yml?query=branch%3Amaster)
[![build status (macos)](https://img.shields.io/github/actions/workflow/status/BiblioNexus-Foundation/codex/stable-macos.yml?branch=master&label=build%28macOS%29)](https://github.com/BiblioNexus-Foundation/codex/actions/workflows/stable-macos.yml?query=branch%3Amaster)
[![build status (windows)](https://img.shields.io/github/actions/workflow/status/BiblioNexus-Foundation/codex/stable-windows.yml?branch=master&label=build%28windows%29)](https://github.com/BiblioNexus-Foundation/codex/actions/workflows/stable-windows.yml?query=branch%3Amaster)

</div>

**This is not a fork. This is a repository of scripts to automatically build [Microsoft's `vscode` repository](https://github.com/microsoft/vscode) into freely-licensed binaries with a community-driven default configuration.**

## Table of Contents

- [Download/Install](#download-install)
  - [Install with Brew](#install-with-brew)
  - [Install with Windows Package Manager (WinGet)](#install-with-winget)
  - [Install with Chocolatey](#install-with-choco)
  - [Install with Scoop](#install-with-scoop)
  - [Install with snap](#install-with-snap)
  - [Install with Package Manager](#install-with-package-manager)
  - [Install on Arch Linux](#install-on-arch-linux)
  - [Flatpak Option](#flatpak)
- [Build](#build)
- [Why Does This Exist](#why)
- [More Info](#more-info)
- [Supported Platforms](#supported-platforms)

## <a id="download-install"></a>Download/Install

:tada: :tada:
Download latest release here:
[stable](https://github.com/BiblioNexus-Foundation/codex/releases) or
[insiders](https://github.com/BiblioNexus-Foundation/codex-insiders/releases)
:tada: :tada:

[More info / helpful tips are here.](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/index.md)


#### <a id="install-with-brew"></a>Install with Brew (Mac)

If you are on a Mac and have [Homebrew](https://brew.sh/) installed:
```bash
# stable
brew install --cask codex

# insiders
brew install --cask codex@insiders
```

*Note for macOS users: if you can't open the App, please read [the following troubleshooting](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/troubleshooting.md#macos).*

#### <a id="install-with-winget"></a>Install with Windows Package Manager (WinGet)

If you use Windows and have [Windows Package Manager](https://github.com/microsoft/winget-cli) installed:
```cmd
:: stable
winget install -e --id Codex.Codex

:: insider
winget install -e --id Codex.Codex.Insiders
```

#### <a id="install-with-choco"></a>Install with Chocolatey (Windows)

If you use Windows and have [Chocolatey](https://chocolatey.org) installed (thanks to [@Thilas](https://github.com/Thilas)):
```cmd
:: stable
choco install codex

:: insider
choco install codex-insiders
```

#### <a id="install-with-scoop"></a>Install with Scoop (Windows)

If you use Windows and have [Scoop](https://scoop.sh) installed:
```bash
scoop bucket add extras
scoop install codex
```

#### <a id="install-with-snap"></a>Install with snap (GNU/Linux)

Codex is available in the [Snap Store](https://snapcraft.io/) as [Codex](https://snapcraft.io/codex), thanks to the help of the [Snapcrafters](https://github.com/snapcrafters/codex) community.
If your GNU/Linux distribution has support for [snaps](https://snapcraft.io/docs/installing-snapd):

```bash
snap install codex --classic
```

#### <a id="install-with-package-manager"></a>Install with Package Manager (GNU/Linux)

You can always install using the downloads (deb, rpm, tar) on the releases page for [stable](https://github.com/BiblioNexus-Foundation/codex/releases) or [insiders](https://github.com/BiblioNexus-Foundation/codex-insiders/releases), but you can also install using your favorite package manager and get automatic updates.

[@paulcarroty](https://github.com/paulcarroty) has set up a repository with instructions for `apt`, `dnf` and `zypper` [here](https://gitlab.com/paulcarroty/codex-deb-rpm-repo).

Any issues installing Codex using your package manager should be directed to that repository's issue tracker.

#### <a id="install-on-arch-linux"></a>Install on Arch Linux

Codex is available in [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository), maintained by [@binex-dsk](https://github.com/binex-dsk) as package [codex-bin](https://aur.archlinux.org/packages/codex-bin/) (stable) and as [codex-insiders-bin](https://aur.archlinux.org/packages/codex-insiders-bin).

If you want to save disk space by having Codex use the Electron system-wide, you also have [codex-electron](https://aur.archlinux.org/packages/codex-electron),
maintained by [@m00nw4tch3r](https://aur.archlinux.org/account/m00nw4tch3r).

An alternative package [codex-git](https://aur.archlinux.org/packages/codex-git/), maintained by [@cedricroijakkers](https://github.com/cedricroijakkers), is also available should you wish to compile from source yourself.

#### <a id="flatpak"></a>Flatpak Option (GNU/Linux)

Codex is available as a Flatpak app [here](https://flathub.org/apps/details/com.codex.codex) and the build repo is [here](https://github.com/flathub/com.codex.codex).
If your distribution has support for [flatpak](https://flathub.org), and you have enabled the [flathub repo](https://flatpak.org/setup/):

```bash
flatpak install flathub com.codex.codex
flatpak run com.codex.codex
```

## <a id="build"></a>Build

Build instructions can be found [here](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/howto-build.md)

## <a id="why"></a>Why Does This Exist

This repository contains build files to generate free release binaries of Microsoft's VS Code. When we speak of "free software", we're talking about freedom, not price.

Microsoft's releases of Visual Studio Code are licensed under [this not-FLOSS license](https://code.visualstudio.com/license) and contain telemetry/tracking. According to [this comment](https://github.com/Microsoft/vscode/issues/60#issuecomment-161792005) from a Visual Studio Code maintainer:

> When we [Microsoft] build Visual Studio Code, we do exactly this. We clone the vscode repository, we lay down a customized product.json that has Microsoft specific functionality (telemetry, gallery, logo, etc.), and then produce a build that we release under our license.
>
> When you clone and build from the vscode repo, none of these endpoints are configured in the default product.json. Therefore, you generate a "clean" build, without the Microsoft customizations, which is by default licensed under the MIT license

This repo exists so that you don't have to download+build from source. The build scripts in this repo clone Microsoft's vscode repo, run the build commands, and upload the resulting binaries to [GitHub releases](https://github.com/BiblioNexus-Foundation/codex/releases). __These binaries are licensed under the MIT license. Telemetry is disabled.__

If you want to build from source yourself, head over to [Microsoft's vscode repo](https://github.com/Microsoft/vscode) and follow their [instructions](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#build-and-run). This repo exists to make it easier to get the latest version of MIT-licensed VS Code.

Microsoft's build process (which we are running to build the binaries) does download additional files. Those packages downloaded during build are:

- Pre-built extensions from the GitHub:
  - [ms-vscode.js-debug-companion](https://github.com/microsoft/vscode-js-debug-companion)
  - [ms-vscode.js-debug](https://github.com/microsoft/vscode-js-debug)
  - [ms-vscode.vscode-js-profile-table](https://github.com/microsoft/vscode-js-profile-visualizer)
- From [Electron releases](https://github.com/electron/electron/releases) (using [gulp-atom-electron](https://github.com/joaomoreno/gulp-atom-electron))
  - electron
  - ffmpeg

## <a id="more-info"></a>More Info

### Documentation

For more information on getting all the telemetry disabled, tips for migrating from Visual Studio Code to Codex and more, have a look at [the Docs page](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/index.md) page.

### Troubleshooting

If you have any issue, please check [the Troubleshooting page](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/troubleshooting.md) or the existing issues.

### Extensions and the Marketplace

According to the VS Code Marketplace [Terms of Use](https://aka.ms/vsmarketplace-ToU), _you may only install and use Marketplace Offerings with Visual Studio Products and Services._ For this reason, Codex uses [open-vsx.org](https://open-vsx.org/), an open source registry for VS Code extensions. See the [Extensions + Marketplace](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/index.md#extensions-marketplace) section on the Docs page for more details.

Please note that some Visual Studio Code extensions have licenses that restrict their use to the official Visual Studio Code builds and therefore do not work with Codex. See [this note](https://github.com/BiblioNexus-Foundation/codex/blob/master/docs/index.md#proprietary-debugging-tools) on the Docs page for what's been found so far and possible workarounds.

### How are the Codex binaries built?

If you would like to see the commands we run to build `vscode` into Codex binaries, have a look at the workflow files in `.github/workflows` for Windows, GNU/Linux and macOS. These build files call all the other scripts in the repo. If you find something that doesn't make sense, feel free to ask about it [on Gitter](https://gitter.im/Codex/Lobby).

The builds are run every day, but exit early if there isn't a new release from Microsoft.

## <a id="supported-platforms"></a>Supported Platforms

The minimal version is limited by the core component Electron, you may want to check its [platform prerequisites](https://www.electronjs.org/docs/latest/development/build-instructions-gn#platform-prerequisites).

- [x] macOS (`zip`, `dmg`) macOS 10.15 or newer x64
- [x] macOS (`zip`, `dmg`) macOS 11.0 or newer arm64
- [x] GNU/Linux x64 (`deb`, `rpm`, `AppImage`, `snap`, `tar.gz`)
- [x] GNU/Linux arm64 (`deb`, `rpm`, `snap`, `tar.gz`)
- [x] GNU/Linux armhf (`deb`, `rpm`, `tar.gz`)
- [x] GNU/Linux riscv64 (`tar.gz`)
- [x] GNU/Linux loong64 (`tar.gz`)
- [x] GNU/Linux ppc64le (`tar.gz`)
- [x] Windows 10 / Server 2012 R2 or newer x64
- [x] Windows 10 / Server 2012 R2 or newer arm64

## <a id="thanks"></a>Special thanks

<table>
  <tr>
    <td><a href="https://github.com/jaredreich" target="_blank">@jaredreich</a></td>
    <td>for the logo</td>
  </tr>
  <tr>
    <td><a href="https://github.com/PalinuroSec" target="_blank">@PalinuroSec</a></td>
    <td>for CDN and domain name</td>
  </tr>
  <tr>
    <td><a href="https://www.macstadium.com" target="_blank"><img src="https://images.prismic.io/macstadium/66fbce64-707e-41f3-b547-241908884716_MacStadium_Logo.png?w=128&q=75" width="128" height="49" alt="MacStadium logo" /></a></td>
    <td>for providing a Mac mini M1</td>
  </tr>
  <tr>
    <td><a href="https://github.com/daiyam" target="_blank">@daiyam</a></td>
    <td>for macOS certificate</td>
  </tr>
  <tr>
    <td><a href="https://signpath.org/" target="_blank"><img src="https://avatars.githubusercontent.com/u/34448643" height="30" alt="SignPath logo" /></a></td>
    <td>free code signing on Windows provided by <a href="https://signpath.io/" target="_blank">SignPath.io</a>, certificate by <a href="https://signpath.org/" target="_blank">SignPath Foundation</a></td>
  </tr>
</table>

## <a id="license"></a>License

[MIT](https://github.com/BiblioNexus-Foundation/codex/blob/master/LICENSE)
