#!/bin/bash

exists() { type -t "$1" > /dev/null 2>&1; }

rm -rf VSCode*
rm -rf vscode*

if ! exists yarn; then
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt-get install -y nodejs desktop-file-utils

  npm install -g yarn
fi

UNAME_ARCH=$( uname -m )

if [[ "${UNAME_ARCH}" == "x86_64" ]]; then
  export VSCODE_ARCH="x64"
else
  export npm_config_arch=armv7l
  export npm_config_force_process_config="true"
  export VSCODE_ARCH="armhf"
fi

echo "-- VSCODE_ARCH: ${VSCODE_ARCH}"

. get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no OS_NAME=linux . build.sh
