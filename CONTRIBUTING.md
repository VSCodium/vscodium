# Contributing to CONTRIBUTING.md

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

#### Table Of Contents

- [Code of Conduct](#code-of-conduct)
- [Reporting Bugs](#reporting-bugs)
- [Making Changes](#making-changes)

## Code of Conduct

This project and everyone participating in it is governed by the [VSCodium Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Reporting Bugs

### Before Submitting an Issue

Before creating bug reports, please check existing issues and [the Troubleshooting Wiki page](https://github.com/VSCodium/vscodium/wiki/Troubleshooting) as you might find out that you don't need to create one.
When you are creating a bug report, please include as many details as possible. Fill out [the required template](https://github.com/VSCodium/vscodium/issues/new?&labels=bug&&template=bug_report.md), the information it asks for helps us resolve issues faster.

## Making Changes

If you want to make changes, please read the documentation [/docs/build.md](./docs/build.md).

### Building VSCodium

To build VSCOdium, please follow the command found in the section [`Build Scripts`](./docs/build.md#build-scripts).

### Updating patches

If you want to update the existing patches, please follow the section [`Patch Update Process - Semi-Automated`](./docs/build.md#patch-update-process-semiauto).

### Add a new patch

- firstly, you need to build VSCodium
- then use the command `patch.sh <your patch name>`, to initiate a new patch
- when the script pause at `Press any key when the conflict have been resolved...`, open `vscode` directory in **VSCodium**
- run `yarn watch`
- run `./script/code.sh`
- make your changes
- press any key to continue the script `patch.sh`
