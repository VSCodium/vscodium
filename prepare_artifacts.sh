#!/bin/bash

set -e

npm install -g checksum

sum_file() {
  if [[ -f "$1" ]]; then
    checksum -a sha256 "$1" > "$1".sha256
    checksum "$1" > "$1".sha1
  fi
}

mkdir artifacts

if [[ "${OS_NAME}" == "osx" ]]; then
  if [[ "${SHOULD_BUILD_ZIP}" != "no" ]]; then
    cd "VSCode-darwin-${VSCODE_ARCH}"
    zip -r -X -y ../artifacts/VSCodium-darwin-${VSCODE_ARCH}-${MS_TAG}.zip ./*.app
    cd ..
  fi

  if [[ "${SHOULD_BUILD_DMG}" != "no" ]]; then
    pushd "VSCode-darwin-${VSCODE_ARCH}"
    npx create-dmg VSCodium.app ..
    mv "../VSCodium ${MS_TAG}.dmg" "../artifacts/VSCodium.${VSCODE_ARCH}.${MS_TAG}.dmg"
    popd
  fi
elif [[ "${OS_NAME}" == "windows" ]]; then
  if [[ "${SHOULD_BUILD_ZIP}" != "no" ]]; then
    mv vscode\\.build\\win32-${VSCODE_ARCH}\\archive\\VSCode-win32-${VSCODE_ARCH}.zip artifacts\\VSCodium-win32-${VSCODE_ARCH}-${MS_TAG}.zip
  fi

  if [[ "${SHOULD_BUILD_EXE_SYS}" != "no" ]]; then
    mv vscode\\.build\\win32-${VSCODE_ARCH}\\system-setup\\VSCodeSetup.exe artifacts\\VSCodiumSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  fi

  if [[ "${SHOULD_BUILD_EXE_USR}" != "no" ]]; then
    mv vscode\\.build\\win32-${VSCODE_ARCH}\\user-setup\\VSCodeSetup.exe artifacts\\VSCodiumUserSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  fi

  if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
    if [[ "${SHOULD_BUILD_MSI}" != "no" ]]; then
      mv build\\windows\\msi\\releasedir\\VSCodium-${VSCODE_ARCH}-${MS_TAG}.msi artifacts/
    fi

    if [[ "${SHOULD_BUILD_MSI_NOUP}" != "no" ]]; then
      mv build\\windows\\msi\\releasedir\\VSCodium-${VSCODE_ARCH}-updates-disabled-${MS_TAG}.msi artifacts/
    fi
  fi
else
  if [[ "${SHOULD_BUILD_TAR}" != "no" ]]; then
    cd VSCode-linux-${VSCODE_ARCH}
    tar czf ../artifacts/VSCodium-linux-${VSCODE_ARCH}-${MS_TAG}.tar.gz .
    cd ..
  fi

  if [[ "${SHOULD_BUILD_DEB}" != "no" ]]; then
    mv vscode/.build/linux/deb/*/deb/*.deb artifacts/
  fi

  if [[ "${SHOULD_BUILD_RPM}" != "no" ]]; then
    mv vscode/.build/linux/rpm/*/*.rpm artifacts/
  fi

  if [[ "${VSCODE_ARCH}" == "x64" ]] && [["${SHOULD_BUILD_APPIMAGE}" != "no" ]]; then
    mv build/linux/appimage/out/*.AppImage* artifacts/
  fi
fi

for FILE in ./artifacts/*
do
  if [[ -f "${FILE}" ]]; then
    sum_file "${FILE}"
  fi
done
