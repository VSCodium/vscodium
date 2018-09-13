# VSCodium
### Free/Libre Open Source Software Binaries of VSCode

## Download/Install
:tada: :tada: [Download latest release here](https://github.com/VSCodium/vscodium/releases) :tada: :tada:

#### Install with Brew
If you are on a Mac and have [Homebrew](https://brew.sh/) installed:
```bash
brew cask install vscodium
```

__Note: if you see "App can’t be opened because it is from an unidentified developer" when opening VSCodium the first time, you can right-click the application and choose Open. This should only be required the first time opening on a Mac.__

## Why
This repository contains a build file to generate FLOSS release binaries of Microsoft's VSCode.

Microsoft's downloads of VSCode are licensed under [this not-FLOSS license](https://code.visualstudio.com/license). That's why this repo exists. So you don't have to download+build from source. If you want to build from source, definitely head over to https://github.com/Microsoft/vscode and follow the [instructions](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#build-and-run).

## Extensions + Marketplace
Until something more open comes around, we use the Microsoft Marketplace/Extensions in the `product.json` file. Those links are licensed under MIT as per [the comments on this issue.](https://github.com/Microsoft/vscode/issues/31168#issuecomment-317319063)

VSCodium (and a freshly cloned copy of vscode built from source) stores its config files in ~/.vscode-oss. So if you currently have Visual Studio Code installed, your extensions and settings won't automatically populate. You can reinstall extensions and copy settings over manually by following these steps:
- In Visual Studio Code, go to Settings (Command+, if on a Mac)
- Click the three dots `...` and choose 'Open settings.json'
- Copy the contents of settings.json into the same place in VSCodium

## Supported OS
- [x] OSX x64 (zipped app file)
- [x] Linux x64 (`.deb`, `.rpm`, and `.tar.gz` files) 
- [ ] Windows x64
  - The plan is to build the Windows executable with [AppVeyor](https://appveyor.com). PRs are welcome :blue_heart:
  
x32 and arm architectures are not currently supported. If you know of a way to do this with Travis or any other free CI/CD platform please put in an issue or a PR.

## License
MIT
