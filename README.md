## VSCodium

This repository contains a build file to generate FLOSS release binaries of Microsoft's VSCode.

[Download binaries here](https://github.com/VSCodium/vscodium/releases)

Microsoft's downloads of VSCode are licensed under [this not-FLOSS license](https://code.visualstudio.com/license). That's why this repo exists. So you don't have to download+build from source.

Until something more open comes around, we use the Microsoft Marketplace/Extensions in the `product.json` file. Those links are licensed under MIT as per [the comments on this issue.](https://github.com/Microsoft/vscode/issues/31168#issuecomment-317319063)

### Supported OS/arch
Currently we are only building OSX (zip) and Linux x64 (deb, rpm, and tar). If you are familiar with building Windows binaries on Travis CI + Wine please put in a PR! :blue_heart:

## License
MIT