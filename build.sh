#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  echo "MS_COMMIT=\"${MS_COMMIT}\""

  . prepare_vscode.sh

  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  export NODE_OPTIONS="--max-old-space-size=8192"

  npm run monaco-compile-check
  npm run valid-layers-check

  npm run gulp compile-build-without-mangling
  npm run gulp compile-extension-media
  npm run gulp compile-extensions-build
  npm run gulp minify-vscode

  if [[ "${OS_NAME}" == "osx" ]]; then
    # generate Group Policy definitions
    node build/lib/policies darwin

    npm run gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"

    find "../VSCode-darwin-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

    VSCODE_PLATFORM="darwin"
  elif [[ "${OS_NAME}" == "windows" ]]; then
    # generate Group Policy definitions
    node build/lib/policies win32

    # in CI, packaging will be done by a different job
    if [[ "${CI_BUILD}" == "no" ]]; then
      . ../build/windows/rtf/make.sh

      npm run gulp "vscode-win32-${VSCODE_ARCH}-min-ci"

      if [[ "${VSCODE_ARCH}" != "x64" ]]; then
        SHOULD_BUILD_REH="no"
        SHOULD_BUILD_REH_WEB="no"
      fi
    fi

    VSCODE_PLATFORM="win32"
  else # linux
    # in CI, packaging will be done by a different job
    if [[ "${CI_BUILD}" == "no" ]]; then
      npm run gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

      find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -0 touch -c
    fi

    VSCODE_PLATFORM="linux"
  fi

  if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
    npm run gulp minify-vscode-reh
    npm run gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
  fi

  if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
    npm run gulp minify-vscode-reh-web
    npm run gulp "vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"
  fi

  cd cli

  export CARGO_NET_GIT_FETCH_WITH_CLI="true"
  export VSCODE_CLI_APP_NAME="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"
  export VSCODE_CLI_BINARY_NAME="$( node -p "require(\"../product.json\").serverApplicationName" )"
  # export VSCODE_CLI_QUALITY="${VSCODE_QUALITY}"

  if [[ "${OS_NAME}" == "osx" ]]; then
    VSCODE_CLI_TARGET="aarch64-apple-darwin"

    cargo build --release --target "${VSCODE_CLI_TARGET}" --bin=code

    TUNNEL_APPLICATION_NAME="$( node -p "require(\"../product.json\").tunnelApplicationName" )"
    NAME_SHORT="$( node -p "require(\"../product.json\").nameShort" )"

    cp "target/${VSCODE_CLI_TARGET}/release/code" "../../VSCode-darwin-${VSCODE_ARCH}/${NAME_SHORT}.app/Contents/Resources/app/bin/${TUNNEL_APPLICATION_NAME}"
  fi

  cd ..

  cd ..
fi
