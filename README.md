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
- [Getting all the Telemetry Out](#disable-telemetry)
- [Supported OS](#supported-os)
- [Extensions + Marketplace](#extensions-marketplace)
- [Migrating from Visual Studio Code to VSCodium](#migrating)

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

## <a id="disable-telemetry"></a>Getting all the Telemetry Out
Even though we do not pass the telemetry build flags (and go out of our way to cripple the baked-in telemetry), Microsoft will still track usage by default. After installing VSCodium, you must manually disable telemetry in your settings file to stop it from sending tracking data to Microsoft. 

The instructions [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-telemetry-reporting) and [here](https://code.visualstudio.com/docs/supporting/faq#_how-to-disable-crash-reporting) help with disabling telemetry. 

It is also highly recommended that you review all the settings that "use online services" by following [these instructions](https://code.visualstudio.com/docs/supporting/faq#_managing-online-services). The `@tag:usesOnlineServices` filter on the settings page will show that by default:
- Extensions auto check for updates and auto install updates
- Searches within the app are sent to an online service for "natural language processing"
- Updates to the app are fetched in the background

These can all be disabled.

__Please note that some extensions send telemetry data to Microsoft as well. We have no control over this and can only recommend removing the extension.__

_(For example the C# extension `ms-vscode.csharp` sends tracking data to Microsoft.)_

## <a id="supported-os"></a>Supported OS
- [x] OSX x64 (zipped app file)
- [x] Linux x64 (`.deb`, `.rpm`, and `.tar.gz` files)
- [x] Linux x86 (`.deb`, `.rpm`, and `.tar.gz` files)
- [ ] Windows
  - The plan is to build the Windows executable with [AppVeyor](https://appveyor.com). PRs are welcome :blue_heart:
  
The ARM architecture is not currently supported but is actively being worked on.

## <a id="extensions-marketplace"></a>Extensions + Marketplace
Until something more open comes around, we use the Microsoft Marketplace/Extensions in the `product.json` file. Those links are licensed under MIT as per [the comments on this issue.](https://github.com/Microsoft/vscode/issues/31168#issuecomment-317319063)

## <a id="migrating"></a>Migrating from Visual Studio Code to VSCodium
VSCodium (and a freshly cloned copy of vscode built from source) stores its extension files in `~/.vscode-oss`. So if you currently have Visual Studio Code installed, your extensions won't automatically populate. You can reinstall your extensions from the Marketplace in VSCodium, or copy the `extensions` from `~/.vscode/extensions` to `~/.vscode-oss/extensions`.

Visual Studio Code stores its `keybindings.json` and `settings.json` file in the these locations:
- __Windows__: `%APPDATA%\Code\User`
- __macOS__: `$HOME/Library/Application Support/Code/User`
- __Linux__: `$HOME/.config/Code/User`

You can copy these files to the VSCodium user settings folder:
- __Windows__: `%APPDATA%\VSCodium\User`
- __macOS__: `$HOME/Library/Application Support/VSCodium/User`
- __Linux__: `$HOME/.config/VSCodium/User`

To copy your settings manually:
- In Visual Studio Code, go to Settings (Command+, if on a Mac)
- Click the three dots `...` and choose 'Open settings.json'
- Copy the contents of settings.json into the same place in VSCodium

## <a id="license"></a>License
MIT
