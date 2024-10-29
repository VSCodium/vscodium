#!/usr/bin/env bash

set -ex

export ELECTRON_VERSION="32.2.1"
export VSCODE_ELECTRON_TAG="v${ELECTRON_VERSION}.riscv1"

echo "03b1b478ab7b9d40da5c47edef0bbeeb528a8bed5335018ff38e513b7df43c7f *electron-v${ELECTRON_VERSION}-linux-riscv64.zip" >> build/checksums/electron.txt
