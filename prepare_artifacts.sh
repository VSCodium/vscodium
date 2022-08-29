#!/bin/bash

set -e

npm install -g checksum

sum_file() {
  if [[ -f "${1}" ]]; then
    echo "Calcuating checksum for ${1}"
    checksum -a sha256 "${1}" > "${1}".sha256
    checksum "${1}" > "${1}".sha1
  fi
}

mkdir artifacts

if [[ "${OS_NAME}" == "osx" ]]; then
  if [[ "${CI_BUILD}" != "no" ]]; then
    cd "VSCode-darwin-${VSCODE_ARCH}"

    CERTIFICATE_P12=VSCodium.p12
    KEYCHAIN="${RUNNER_TEMP}/build.keychain"

    echo "${CERTIFICATE_OSX_P12}" | base64 --decode > "${CERTIFICATE_P12}"
    security create-keychain -p mysecretpassword "${KEYCHAIN}"
    security default-keychain -s "${KEYCHAIN}"
    security unlock-keychain -p mysecretpassword "${KEYCHAIN}"
    security import "${CERTIFICATE_P12}" -k "${KEYCHAIN}" -P "${CERTIFICATE_OSX_PASSWORD}" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple: -s -k mysecretpassword "${KEYCHAIN}"

    if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
      codesign --deep --force --verbose --sign "${CERTIFICATE_OSX_ID}" "VSCodium - Insiders.app"
    else
      codesign --deep --force --verbose --sign "${CERTIFICATE_OSX_ID}" "VSCodium.app"
    fi

    cd ..
  fi

  if [[ "${SHOULD_BUILD_ZIP}" != "no" ]]; then
    echo "Building and moving ZIP"
    cd "VSCode-darwin-${VSCODE_ARCH}"
    zip -r -X -y "../artifacts/VSCodium-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ./*.app
    cd ..
  fi

  if [[ "${SHOULD_BUILD_DMG}" != "no" ]]; then
    echo "Building and moving DMG"
    pushd "VSCode-darwin-${VSCODE_ARCH}"
    npx create-dmg VSCodium.app ..
    mv "../VSCodium ${MS_TAG}.dmg" "../artifacts/VSCodium.${VSCODE_ARCH}.${RELEASE_VERSION}.dmg"
    popd
  fi

  VSCODE_PLATFORM="darwin"
elif [[ "${OS_NAME}" == "windows" ]]; then
  cd vscode || { echo "'vscode' dir not found"; exit 1; }

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

  cd ..

  if [[ "${SHOULD_BUILD_ZIP}" != "no" ]]; then
    echo "Moving ZIP"
    mv "vscode\\.build\\win32-${VSCODE_ARCH}\\archive\\VSCode-win32-${VSCODE_ARCH}.zip" "artifacts\\VSCodium-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip"
  fi

  if [[ "${SHOULD_BUILD_EXE_SYS}" != "no" ]]; then
    echo "Moving System EXE"
    mv "vscode\\.build\\win32-${VSCODE_ARCH}\\system-setup\\VSCodeSetup.exe" "artifacts\\VSCodiumSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
  fi

  if [[ "${SHOULD_BUILD_EXE_USR}" != "no" ]]; then
    echo "Moving User EXE"
    mv "vscode\\.build\\win32-${VSCODE_ARCH}\\user-setup\\VSCodeSetup.exe" "artifacts\\VSCodiumUserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
  fi

  if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
    if [[ "${SHOULD_BUILD_MSI}" != "no" ]]; then
      echo "Moving MSI"
      mv "build\\windows\\msi\\releasedir\\VSCodium-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" artifacts/
    fi

    if [[ "${SHOULD_BUILD_MSI_NOUP}" != "no" ]]; then
      echo "Moving MSI with disabled updates"
      mv "build\\windows\\msi\\releasedir\\VSCodium-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" artifacts/
    fi
  fi

  VSCODE_PLATFORM="win32"
else
  cd vscode || { echo "'vscode' dir not found"; exit 1; }

  if [[ "${SHOULD_BUILD_DEB}" != "no" || "${SHOULD_BUILD_APPIMAGE}" != "no" ]]; then
    yarn gulp "vscode-linux-${VSCODE_ARCH}-build-deb"
  fi

  if [[ "${SHOULD_BUILD_RPM}" != "no" ]]; then
    yarn gulp "vscode-linux-${VSCODE_ARCH}-build-rpm"
  fi

  if [[ "${SHOULD_BUILD_APPIMAGE}" != "no" ]]; then
    . ../build/linux/appimage/build.sh
  fi

  cd ..

  if [[ "${SHOULD_BUILD_TAR}" != "no" ]]; then
    echo "Building and moving TAR"
    cd "VSCode-linux-${VSCODE_ARCH}"
    tar czf "../artifacts/VSCodium-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
    cd ..
  fi

  if [[ "${SHOULD_BUILD_DEB}" != "no" ]]; then
    echo "Moving DEB"
    mv vscode/.build/linux/deb/*/deb/*.deb artifacts/
  fi

  if [[ "${SHOULD_BUILD_RPM}" != "no" ]]; then
    echo "Moving RPM"
    mv vscode/.build/linux/rpm/*/*.rpm artifacts/
  fi

  if [[ "${SHOULD_BUILD_APPIMAGE}" != "no" ]]; then
    echo "Moving AppImage"
    mv build/linux/appimage/out/*.AppImage* artifacts/
  fi

  VSCODE_PLATFORM="linux"
fi

if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
  echo "Building and moving REH"
  cd "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}"
  tar czf "../artifacts/vscodium-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
  cd ..
fi

cd artifacts

for FILE in *
do
  if [[ -f "${FILE}" ]]; then
    sum_file "${FILE}"
  fi
done

cd ..
