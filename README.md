# VSCodium
### Free/Libre Open Source Software Binaries of VSCode

## Table of Contents
- [Download/Install](#download-install)
  - [Install with Brew](#install-with-brew)
- [Why Does This Exist](#why)
- [Supported OS](#supported-os)
- [Extensions + Marketplace](#extensions-marketplace)
- [Migrating from Visual Studio Code to VSCodium](#migrating)

## <a id="download-install"></a>Download/Install
:tada: :tada: [Download latest release here](https://github.com/VSCodium/vscodium/releases) :tada: :tada:

#### <a id="install-with-brew"></a>Install with Brew
If you are on a Mac and have [Homebrew](https://brew.sh/) installed:
```bash
brew cask install vscodium
```

_Note: if you see "App can’t be opened because it is from an unidentified developer" when opening VSCodium the first time, you can right-click the application and choose Open. This should only be required the first time opening on a Mac._

## <a id="why"></a>Why Does This Exist
This repository contains a build file to generate FLOSS release binaries of Microsoft's VSCode.

Microsoft's downloads of Visual Studio Code are licensed under [this not-FLOSS license](https://code.visualstudio.com/license) and contain telemetry/tracking.

This repo exists so that you don't have to download+build from source. The build scripts in this repo clone Microsoft's vscode repo, run their build commands, and upload the resulting binaries to [GitHub releases](https://github.com/VSCodium/vscodium/releases). __These binaries don't have the telemetry/tracking, and are licensed under the MIT license.__

If you want to build from source yourself, head over to https://github.com/Microsoft/vscode and follow their [instructions](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#build-and-run). This repo exists to make it easier to get the latest version of MIT-licensed VSCode.

## <a id="supported-os"></a>Supported OS
- [x] OSX x64 (zipped app file)
- [x] Linux x64 (`.deb`, `.rpm`, and `.tar.gz` files) 
- [ ] Windows x64
  - The plan is to build the Windows executable with [AppVeyor](https://appveyor.com). PRs are welcome :blue_heart:
  
x32 and arm architectures are not currently supported. If you know of a way to do this with Travis or any other free CI/CD platform please put in an issue or a PR.

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
