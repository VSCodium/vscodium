#!/bin/bash

rm -rf VSCode*
rm -rf vscode*

UNAME_ARCH=$( uname -m )

if [[ "${UNAME_ARCH}" == "arm64" ]]; then
  export VSCODE_ARCH="arm64"
else
  export VSCODE_ARCH="x64"
fi

echo "-- VSCODE_ARCH: ${VSCODE_ARCH}"

. get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no OS_NAME=osx . build.sh
