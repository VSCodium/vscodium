#!/bin/bash

exists() { type -t "$1" > /dev/null 2>&1; }

export CI_BUILD="no"
export OS_NAME="linux"
export SHOULD_BUILD="yes"
export SKIP_PACKAGES="yes"
export VSCODE_LATEST="no"
export VSCODE_QUALITY="stable"

while getopts ":ilp" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
    l)
      export VSCODE_LATEST="yes"
      ;;
    p)
      export SKIP_PACKAGES="no"
      ;;
  esac
done

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

echo "OS_NAME=\"${OS_NAME}\""
echo "SKIP_PACKAGES=\"${SKIP_PACKAGES}\""
echo "VSCODE_ARCH=\"${VSCODE_ARCH}\""
echo "VSCODE_LATEST=\"${VSCODE_LATEST}\""
echo "VSCODE_QUALITY=\"${VSCODE_QUALITY}\""

rm -rf vscode* VSCode*

. get_repo.sh
. build.sh

if [[ "${SKIP_PACKAGES}" == "no" ]]; then
  . prepare_artifacts.sh
fi
