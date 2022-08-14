#!/bin/bash

set -e

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not build because no GITHUB_TOKEN defined"
  exit
fi

VERSIONS_REPO="${GITHUB_USERNAME:-"VSCodium"}/versions"

REPOSITORY="${GITHUB_REPOSITORY:-"VSCodium/vscodium"}"
GITHUB_RESPONSE=$( curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${REPOSITORY}/releases/tags/latest")
LATEST_VERSION=$( echo "${GITHUB_RESPONSE}" | jq -c '.tag_name' )

if [[ "${LATEST_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  if [ "${MS_TAG}" != "${BASH_REMATCH[1]}" ]; then
    echo "New VSCode version, new build"
    export SHOULD_BUILD="yes"

    VSCODIUM_ASSETS="null"
  elif [[ "${NEW_RELEASE}" == "yes" ]]; then
    echo "New release build"
    export SHOULD_BUILD="yes"

    VSCODIUM_ASSETS="null"
  else
    export RELEASE_VERSION="${LATEST_VERSION}"
    echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"

    echo "Switch to release version: ${RELEASE_VERSION}"

    VSCODIUM_ASSETS=$( echo "${GITHUB_RESPONSE}" | jq -c '.assets | map(.name)?' )
  fi
fi

contains() {
  # add " to match the end of a string so any hashs won't be matched by mistake
  echo "${VSCODIUM_ASSETS}" | grep "${1}\""
}

if [ "${VSCODIUM_ASSETS}" != "null" ]; then
  # macos
  if [[ "${OS_NAME}" == "osx" ]]; then
    if [[ -z $( contains "VSCodium-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
      echo "Building on MacOS because we have no ZIP"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_ZIP="no"
    fi

    if [[ -z $( contains ".${VSCODE_ARCH}.${RELEASE_VERSION}.dmg" ) ]]; then
      echo "Building on MacOS because we have no DMG"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_DMG="no"
    fi

    if [[ -z $( contains "vscodium-reh-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on MacOS because we have no REH archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH="no"
    fi

    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      echo "Already have all the MacOS builds"
    fi
  elif [[ "${OS_NAME}" == "windows" ]]; then

    # windows-arm64
    if [[ ${VSCODE_ARCH} == "arm64" ]]; then
      if [[ -z $( contains "VSCodiumSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
        echo "Building on Windows arm64 because we have no system setup"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_EXE_SYS="no"
      fi

      if [[ -z $( contains "UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
        echo "Building on Windows arm64 because we have no user setup"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_EXE_USR="no"
      fi

      if [[ -z $( contains "VSCodium-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
        echo "Building on Windows arm64 because we have no zip"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_ZIP="no"
      fi

      export SHOULD_BUILD_REH="no"

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Windows arm64 builds"
      fi

    # windows-ia32
    elif [[ ${VSCODE_ARCH} == "ia32" ]]; then
      if [[ -z $( contains "VSCodiumSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
        echo "Building on Windows ia32 because we have no system setup"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_EXE_SYS="no"
      fi

      if [[ -z $( contains "UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
        echo "Building on Windows ia32 because we have no user setup"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_EXE_USR="no"
      fi

      if [[ -z $( contains "VSCodium-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
        echo "Building on Windows ia32 because we have no zip"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_ZIP="no"
      fi

      if [[ -z $( contains "VSCodium-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows ia32 because we have no msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI="no"
      fi

      if [[ -z $( contains "VSCodium-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows ia32 because we have no updates-disabled msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI_NOUP="no"
      fi

      if [[ -z $( contains "vscodium-reh-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Windows ia32 because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Windows ia32 builds"
      fi

    # windows-x64
    else
      if [[ -z $( contains "VSCodiumSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
        echo "Building on Windows x64 because we have no system setup"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_EXE_SYS="no"
      fi

      if [[ -z $( contains "UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
        echo "Building on Windows x64 because we have no user setup"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_EXE_USR="no"
      fi

      if [[ -z $( contains "VSCodium-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
        echo "Building on Windows x64 because we have no zip"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_ZIP="no"
      fi

      if [[ -z $( contains "VSCodium-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows x64 because we have no msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI="no"
      fi

      if [[ -z $( contains "VSCodium-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows x64 because we have no updates-disabled msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI_NOUP="no"
      fi

      if [[ -z $( contains "vscodium-reh-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Windows x64 because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Windows x64 builds"
      fi
    fi
  elif [[ "${OS_NAME}" == "linux" ]]; then

    # linux-arm64
    if [[ ${VSCODE_ARCH} == "arm64" ]]; then
      if [[ -z $( contains "arm64.deb" ) ]]; then
        echo "Building on Linux arm64 because we have no DEB"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_DEB="no"
      fi

      if [[ -z $( contains "aarch64.rpm" ) ]]; then
        echo "Building on Linux arm64 because we have no RPM"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_RPM="no"
      fi

      if [[ -z $( contains "VSCodium-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm64 because we have no TAR"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_TAR="no"
      fi

      if [[ -z $( contains "vscodium-reh-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm64 because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      export SHOULD_BUILD_APPIMAGE="no"

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Linux arm64 builds"
      fi

    # linux-armhf
    elif [[ ${VSCODE_ARCH} == "armhf" ]]; then
      if [[ -z $( contains "armhf.deb" ) ]]; then
        echo "Building on Linux arm because we have no DEB"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_DEB="no"
      fi

      if [[ -z $( contains "armv7hl.rpm" ) ]]; then
        echo "Building on Linux arm because we have no RPM"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_RPM="no"
      fi

      if [[ -z $( contains "VSCodium-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm because we have no TAR"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_TAR="no"
      fi

      if [[ -z $( contains "vscodium-reh-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      export SHOULD_BUILD_APPIMAGE="no"

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Linux arm builds"
      fi

    # linux-x64
    else
      if [[ -z $( contains "amd64.deb" ) ]]; then
        echo "Building on Linux x64 because we have no DEB"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_DEB="no"
      fi

      if [[ -z $( contains "x86_64.rpm" ) ]]; then
        echo "Building on Linux x64 because we have no RPM"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_RPM="no"
      fi

      if [[ -z $( contains "VSCodium-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux x64 because we have no TAR"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_TAR="no"
      fi

      if [[ -z $( contains "x86_64.AppImage" ) ]]; then
        echo "Building on Linux x64 because we have no AppImage"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_APPIMAGE="no"
      fi

      if [[ -z $( contains "vscodium-reh-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux x64 because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Linux x64 builds"
      fi
    fi
  fi
else
  echo "Release assets do not exist at all, continuing build"
  export SHOULD_BUILD="yes"
fi

echo "SHOULD_BUILD=${SHOULD_BUILD}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_APPIMAGE=${SHOULD_BUILD_APPIMAGE}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_DEB=${SHOULD_BUILD_DEB}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_DMG=${SHOULD_BUILD_DMG}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_EXE_SYS=${SHOULD_BUILD_EXE_SYS}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_EXE_USR=${SHOULD_BUILD_EXE_USR}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_MSI=${SHOULD_BUILD_MSI}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_MSI_NOUP=${SHOULD_BUILD_MSI_NOUP}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_REH=${SHOULD_BUILD_REH}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_RPM=${SHOULD_BUILD_RPM}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_TAR=${SHOULD_BUILD_TAR}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_ZIP=${SHOULD_BUILD_ZIP}" >> "${GITHUB_ENV}"
