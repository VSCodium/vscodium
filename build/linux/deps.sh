#!/usr/bin/env bash

set -ex

sudo apt-get update -y

sudo apt-get install -y libkrb5-dev

if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
  sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu crossbuild-essential-arm64
elif [[ "${VSCODE_ARCH}" == "armhf" ]]; then
  sudo apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf crossbuild-essential-armhf
fi
