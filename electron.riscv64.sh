#!/usr/bin/env bash

set -ex

export ELECTRON_VERSION="30.5.1"
export VSCODE_ELECTRON_TAG="v${ELECTRON_VERSION}.riscv1"

echo "dfae1ccddec728faa7e5dcc92fb38ee7c40251e7f7638817da1c2a94dd37b5c2 *electron-v${ELECTRON_VERSION}-linux-riscv64.zip" >> build/checksums/electron.txt
