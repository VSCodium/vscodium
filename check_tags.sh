#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not build because no GITHUB_TOKEN defined"
  exit 0
fi

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"
GITHUB_RESPONSE=$( curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${ASSETS_REPOSITORY}/releases/latest" )
LATEST_VERSION=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.tag_name' )

if [[ "${LATEST_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  if [[ "${MS_TAG}" != "${BASH_REMATCH[1]}" ]]; then
    echo "New VSCode version, new build"
    export SHOULD_BUILD="yes"
  elif [[ "${NEW_RELEASE}" == "true" ]]; then
    echo "New release build"
    export SHOULD_BUILD="yes"
  elif [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    BODY=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.body' )

    if [[ "${BODY}" =~ \[([a-z0-9]+)\] ]]; then
      if [[ "${MS_COMMIT}" != "${BASH_REMATCH[1]}" ]]; then
        echo "New VSCode Insiders version, new build"
        export SHOULD_BUILD="yes"
      fi
    fi
  fi

  if [[ "${SHOULD_BUILD}" != "yes" ]]; then
    export RELEASE_VERSION="${LATEST_VERSION}"
    echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"

    echo "Switch to release version: ${RELEASE_VERSION}"

    ASSETS=$( echo "${GITHUB_RESPONSE}" | jq -c '.assets | map(.name)?' )
  else
    ASSETS="null"
  fi
fi

contains() {
  # add " to match the end of a string so any hashs won't be matched by mistake
  echo "${ASSETS}" | grep "${1}\""
}

if [[ "${ASSETS}" != "null" ]]; then
  # macos
  if [[ "${OS_NAME}" == "osx" ]]; then
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
      if [[ -z $( contains "${APP_NAME}-${RELEASE_VERSION}-src.tar.gz" ) || -z $( contains "${APP_NAME}-${RELEASE_VERSION}-src.zip" ) ]]; then
        echo "Building on MacOS because we have no SRC"
        export SHOULD_BUILD="yes"
        export SHOULD_BUILD_SRC="yes"
      fi
    fi

    if [[ -z $( contains "${APP_NAME}-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
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

    if [[ -z $( contains "${APP_NAME_LC}-reh-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
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
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
      if [[ -z $( contains "${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
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

      if [[ -z $( contains "${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
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
    elif [[ "${VSCODE_ARCH}" == "ia32" ]]; then
      if [[ -z $( contains "${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
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

      if [[ -z $( contains "${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
        echo "Building on Windows ia32 because we have no zip"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_ZIP="no"
      fi

      if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows ia32 because we have no msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI="no"
      fi

      if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows ia32 because we have no updates-disabled msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI_NOUP="no"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
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
      if [[ -z $( contains "${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe" ) ]]; then
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

      if [[ -z $( contains "${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ) ]]; then
        echo "Building on Windows x64 because we have no zip"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_ZIP="no"
      fi

      if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows x64 because we have no msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI="no"
      fi

      if [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
        echo "Building on Windows x64 because we have no updates-disabled msi"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_MSI_NOUP="no"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
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
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
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

      if [[ -z $( contains "${APP_NAME}-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm64 because we have no TAR"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_TAR="no"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
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
    elif [[ "${VSCODE_ARCH}" == "armhf" ]]; then
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

      if [[ -z $( contains "${APP_NAME}-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm because we have no TAR"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_TAR="no"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux arm because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      export SHOULD_BUILD_APPIMAGE="no"

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Linux arm builds"
      fi

    # linux-ppc64le
    elif [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
      SHOULD_BUILD_DEB="no"
      SHOULD_BUILD_APPIMAGE="no"
      SHOULD_BUILD_RPM="no"
      SHOULD_BUILD_TAR="no"

      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux PowerPC64LE because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH="no"
      fi

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Linux PowerPC64LE builds"
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

      if [[ -z $( contains "${APP_NAME}-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux x64 because we have no TAR"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_TAR="no"
      fi

      # if [[ -z $( contains "x86_64.AppImage" ) ]]; then
      #   echo "Building on Linux x64 because we have no AppImage"
      #   export SHOULD_BUILD="yes"
      # else
      #   export SHOULD_BUILD_APPIMAGE="no"
      # fi
      export SHOULD_BUILD_APPIMAGE="no"

      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
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
  if [[ "${OS_NAME}" == "linux" ]]; then
    if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
      SHOULD_BUILD_DEB="no"
      SHOULD_BUILD_APPIMAGE="no"
      SHOULD_BUILD_RPM="no"
      SHOULD_BUILD_TAR="no"
    elif [[ "${VSCODE_ARCH}" != "x64" ]]; then
      export SHOULD_BUILD_APPIMAGE="no"
    fi
  elif [[ "${OS_NAME}" == "osx" ]]; then
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
      export SHOULD_BUILD_SRC="yes"
    fi
  elif [[ "${OS_NAME}" == "windows" ]]; then
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
      export SHOULD_BUILD_REH="no"
    fi
  fi

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
echo "SHOULD_BUILD_SRC=${SHOULD_BUILD_SRC}" >> "${GITHUB_ENV}"
