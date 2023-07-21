#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ -f  "./remote-dependencies.tar" ]]; then
  tar -xf ./remote-dependencies.tar ./vscode/remote/node_modules
fi

. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  npm config set scripts-prepend-node-path true
  npm config set node_gyp

  echo "MS_COMMIT=\"${MS_COMMIT}\""

  . prepare_vscode.sh

  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  yarn monaco-compile-check
  yarn valid-layers-check

  yarn gulp compile-build
  yarn gulp compile-extension-media
  yarn gulp compile-extensions-build
  yarn gulp minify-vscode

  if [[ "${OS_NAME}" == "osx" ]]; then
    yarn gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"

    find "../VSCode-darwin-${VSCODE_ARCH}" -print0 | xargs -o touch -c

    VSCODE_PLATFORM="darwin"
  elif [[ "${OS_NAME}" == "windows" ]]; then
    . ../build/windows/rtf/make.sh

    yarn gulp "vscode-win32-${VSCODE_ARCH}-min-ci"

    if [[ "${VSCODE_ARCH}" != "ia32" && "${VSCODE_ARCH}" != "x64" ]]; then
      SHOULD_BUILD_REH="no"
    fi

    VSCODE_PLATFORM="win32"
  elif [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then # linux-ppc64le
    VSCODE_PLATFORM="linux"
  else # linux
    yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

    find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -o touch -c

    VSCODE_PLATFORM="linux"
  fi

  if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
    yarn gulp minify-vscode-reh
    yarn gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
  fi

  cd ..
fi
