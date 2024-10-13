#!/usr/bin/env bash

set -ex

export ELECTRON_VERSION="32.1.2"
export VSCODE_ELECTRON_TAG="v${ELECTRON_VERSION}.riscv1"

echo "1893e6e8831ddd9c30111db02ad7edbaad8ebbf43d69054657f7221fb6086819 *electron-v${ELECTRON_VERSION}-linux-riscv64.zip" >> build/checksums/electron.txt
