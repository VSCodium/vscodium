#!/bin/bash

set -ex

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  npm config set scripts-prepend-node-path true

  echo "MS_COMMIT: ${MS_COMMIT}"

  . prepare_vscode.sh

  cd vscode || exit

  yarn monaco-compile-check
  yarn valid-layers-check

  yarn gulp compile-build
  yarn gulp compile-extension-media
  yarn gulp compile-extensions-build
  yarn gulp minify-vscode

  if [[ "${OS_NAME}" == "osx" ]]; then
    yarn gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"
  elif [[ "${OS_NAME}" == "windows" ]]; then
    . ../build/windows/rtf/make.sh

    yarn gulp "vscode-win32-${VSCODE_ARCH}-min-ci"
    yarn gulp "vscode-win32-${VSCODE_ARCH}-inno-updater"

    if [[ "${SHOULD_BUILD_ZIP}" != "no" ]]; then
      yarn gulp "vscode-win32-${VSCODE_ARCH}-archive"
    fi

    if [[ "${SHOULD_BUILD_EXE_SYS}" != "no" ]]; then
      yarn gulp "vscode-win32-${VSCODE_ARCH}-system-setup"
    fi

    if [[ "${SHOULD_BUILD_EXE_USR}" != "no" ]]; then
      yarn gulp "vscode-win32-${VSCODE_ARCH}-user-setup"
    fi

    if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
      if [[ "${SHOULD_BUILD_MSI}" != "no" ]]; then
        . ../build/windows/msi/build.sh
      fi

      if [[ "${SHOULD_BUILD_MSI_NOUP}" != "no" ]]; then
        . ../build/windows/msi/build-updates-disabled.sh
      fi
    fi
  else # linux
    yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

    if [[ "${SKIP_LINUX_PACKAGES}" != "True" ]]; then
      if [[ "${SHOULD_BUILD_DEB}" != "no" || "${SHOULD_BUILD_APPIMAGE}" != "no" ]]; then
        yarn gulp "vscode-linux-${VSCODE_ARCH}-build-deb"
      fi

      if [[ "${SHOULD_BUILD_RPM}" != "no" ]]; then
        yarn gulp "vscode-linux-${VSCODE_ARCH}-build-rpm"
      fi

      if [[ "${SHOULD_BUILD_APPIMAGE}" != "no" ]]; then
        . ../build/linux/appimage/build.sh
      fi
    fi
  fi

  cd ..
fi
