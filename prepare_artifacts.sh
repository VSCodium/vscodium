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
  if [["${SHOULD_BUILD_ZIP}" != "no" ]]; then
    cd "VSCode-darwin-${VSCODE_ARCH}"

    zip -r -X -y ../artifacts/VSCodium-darwin-${VSCODE_ARCH}-${MS_TAG}.zip ./*.app

    cd ..
  fi

  if [["${SHOULD_BUILD_DMG}" != "no" ]]; then
    pushd "VSCode-darwin-${VSCODE_ARCH}"
    npx create-dmg VSCodium.app ..
    mv "../VSCodium ${MS_TAG}.dmg" "../artifacts/VSCodium.${VSCODE_ARCH}.${MS_TAG}.dmg"
    popd
  fi
elif [[ "${OS_NAME}" == "windows" ]]; then
  mv vscode\\.build\\win32-${VSCODE_ARCH}\\system-setup\\VSCodeSetup.exe artifacts\\VSCodiumSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  mv vscode\\.build\\win32-${VSCODE_ARCH}\\user-setup\\VSCodeSetup.exe artifacts\\VSCodiumUserSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  mv vscode\\.build\\win32-${VSCODE_ARCH}\\archive\\VSCode-win32-${VSCODE_ARCH}.zip artifacts\\VSCodium-win32-${VSCODE_ARCH}-${MS_TAG}.zip

  if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
    mv build\\windows\\msi\\releasedir\\VSCodium-${VSCODE_ARCH}-${MS_TAG}.msi artifacts
    mv build\\windows\\msi\\releasedir\\VSCodium-${VSCODE_ARCH}-updates-disabled-${MS_TAG}.msi artifacts
  fi
else
  if [["${SHOULD_BUILD_TAR}" != "no" ]]; then
    echo "Tar release"

    cd VSCode-linux-${VSCODE_ARCH}

    tar czf ../artifacts/VSCodium-linux-${VSCODE_ARCH}-${MS_TAG}.tar.gz .

    cd ..
  fi

  echo "Move/rename build artifacts"

  cp vscode/.build/linux/deb/*/deb/*.deb artifacts/
  cp vscode/.build/linux/rpm/*/*.rpm artifacts/

  if [[ "${VSCODE_ARCH}" == "x64" ]]; then
    cp build/linux/appimage/out/*.AppImage* artifacts/
  fi
fi

sum_file artifacts/*
