#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

tar -xzf ./vscode.tar.gz

cd vscode || { echo "'vscode' dir not found"; exit 1; }

for i in {1..5}; do # try 5 times
  npm ci && break
  if [[ $i -eq 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

node build/azure-pipelines/distro/mixin-npm

. ../build/windows/rtf/make.sh

yarn gulp "vscode-win32-${VSCODE_ARCH}-min-ci"

if [[ "${VSCODE_ARCH}" == "x64" ]]; then
  if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
    echo "Building REH"
    yarn gulp minify-vscode-reh
    yarn gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

    echo "Archiving REH"
    pushd "../vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}"
    tar czf "../assets/${APP_NAME_LC}-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
    popd
  fi

  if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
    echo "Building REH-web"
    yarn gulp minify-vscode-reh-web
    yarn gulp "vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

    echo "Archiving REH-web"
    pushd "../vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}"
    tar czf "../assets/${APP_NAME_LC}-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
    popd
  fi
fi

cd ..
