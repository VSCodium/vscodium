#!/bin/bash

### Windows
# to run with Bash: "C:\Program Files\Git\bin\bash.exe" ./build/build_windows.sh
###

export INSIDER="no"
export VSCODE_LATEST="no"

while getopts ":il" opt; do
  case "$opt" in
    i)
      export INSIDER="yes"
      ;;
    l)
      export VSCODE_LATEST="yes"
      ;;
  esac
done

case "$OSTYPE" in
  darwin*)
    export OS_NAME="osx"
    ;;
  msys* | cygwin*)
    export OS_NAME="windows"
    ;;
  *)
    export OS_NAME="linux"
    ;;
esac

UNAME_ARCH=$( uname -m )

if [[ "${UNAME_ARCH}" == "arm64" ]]; then
  export VSCODE_ARCH="arm64"
else
  export VSCODE_ARCH="x64"
fi

echo "OS_NAME: ${OS_NAME}"
echo "VSCODE_ARCH: ${VSCODE_ARCH}"
echo "VSCODE_LATEST: ${VSCODE_LATEST}"
echo "INSIDER: ${INSIDER}"

rm -rf vscode* VSCode*

if [[ "${OS_NAME}" == "windows" ]]; then
  rm -rf build/windows/msi/releasedir
fi

. get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no . build.sh
