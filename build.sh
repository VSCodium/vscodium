#!/bin/bash

set -ex

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  npm config set scripts-prepend-node-path true

  export BUILD_SOURCEVERSION=$LATEST_MS_COMMIT
  echo "LATEST_MS_COMMIT: ${LATEST_MS_COMMIT}"
  echo "BUILD_SOURCEVERSION: ${BUILD_SOURCEVERSION}"

  if [[ "$CI_WINDOWS" == "True" ]]; then
    export npm_config_arch="$BUILDARCH"
    export npm_config_target_arch="$BUILDARCH"
  fi

  . prepare_vscode.sh

  cd vscode || exit

  yarn monaco-compile-check
  yarn valid-layers-check

  yarn gulp compile-build
  yarn gulp compile-extensions-build
  yarn gulp minify-vscode

  if [[ "$OS_NAME" == "osx" ]]; then
    yarn gulp vscode-darwin-min-ci
  elif [[ "$CI_WINDOWS" == "True" ]]; then
    cp LICENSE.txt LICENSE.rtf # windows build expects rtf license
    yarn gulp "vscode-win32-${BUILDARCH}-min-ci"
    yarn gulp "vscode-win32-${BUILDARCH}-code-helper"
    yarn gulp "vscode-win32-${BUILDARCH}-inno-updater"
    yarn gulp "vscode-win32-${BUILDARCH}-archive"
    yarn gulp "vscode-win32-${BUILDARCH}-system-setup"
    yarn gulp "vscode-win32-${BUILDARCH}-user-setup"
  else # linux
    yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"
    if [[ "$SKIP_LINUX_PACKAGES" != "True" ]]; then
      yarn gulp "vscode-linux-${VSCODE_ARCH}-build-deb"
      yarn gulp "vscode-linux-${VSCODE_ARCH}-build-rpm"
      . ../create_appimage.sh
    fi
  fi

  cd ..
fi
