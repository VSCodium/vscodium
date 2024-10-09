#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

if [[ -z "${GH_TOKEN}" ]] && [[ -z "${GITHUB_TOKEN}" ]] && [[ -z "${GH_ENTERPRISE_TOKEN}" ]] && [[ -z "${GITHUB_ENTERPRISE_TOKEN}" ]]; then
  echo "Will not build because no GITHUB_TOKEN defined"
  exit 0
else
  GITHUB_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-${GH_ENTERPRISE_TOKEN:-${GITHUB_ENTERPRISE_TOKEN}}}}"
fi

# Support for GitHub Enterprise
GH_HOST="${GH_HOST:-github.com}"

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

if [[ "${SHOULD_DEPLOY}" == "no" ]]; then
  ASSETS="null"
else
  GITHUB_RESPONSE=$( curl -s -H "Authorization: token ${GITHUB_TOKEN}" "https://api.${GH_HOST}/repos/${ASSETS_REPOSITORY}/releases/latest" )
  LATEST_VERSION=$( echo "${GITHUB_RESPONSE}" | jq -c -r '.tag_name' )
  RECHECK_ASSETS="${SHOULD_BUILD}"

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
    elif [[ "${RECHECK_ASSETS}" == "yes" ]]; then
      export SHOULD_BUILD="no"

      ASSETS=$( echo "${GITHUB_RESPONSE}" | jq -c '.assets | map(.name)?' )
    else
      ASSETS="null"
    fi
  else
    echo "can't check assets"
    exit 1
  fi
fi

contains() {
  # add " to match the end of a string so any hashs won't be matched by mistake
  echo "${ASSETS}" | grep "${1}\""
}

# shellcheck disable=SC2153
if [[ "${CHECK_ASSETS}" == "no" ]]; then
  echo "Don't check assets, yet"
elif [[ "${ASSETS}" != "null" ]]; then
  if [[ "${IS_SPEARHEAD}" == "yes" ]]; then
    if [[ -z $( contains "${APP_NAME}-${RELEASE_VERSION}-src.tar.gz" ) || -z $( contains "${APP_NAME}-${RELEASE_VERSION}-src.zip" ) ]]; then
      echo "Building because we have no SRC"
      export SHOULD_BUILD="yes"
      export SHOULD_BUILD_SRC="yes"
    fi
  # macos
  elif [[ "${OS_NAME}" == "osx" ]]; then
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

    if [[ -z $( contains "${APP_NAME_LC}-reh-web-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on MacOS because we have no REH-web archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH_WEB="no"
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
      export SHOULD_BUILD_REH_WEB="no"

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

      if [[ -z $( contains "${APP_NAME_LC}-reh-web-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Windows ia32 because we have no REH-web archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH_WEB="no"
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

      if [[ -z $( contains "${APP_NAME_LC}-reh-web-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Windows x64 because we have no REH-web archive"
        export SHOULD_BUILD="yes"
      else
        export SHOULD_BUILD_REH_WEB="no"
      fi

      if [[ "${SHOULD_BUILD}" != "yes" ]]; then
        echo "Already have all the Windows x64 builds"
      fi
    fi
  elif [[ "${OS_NAME}" == "linux" ]]; then

    if [[ "${CHECK_ONLY_REH}" == "yes" ]]; then

      if [[ -z $( contains "${APP_NAME_LC}-reh-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux ${VSCODE_ARCH} because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        echo "Already have the Linux REH ${VSCODE_ARCH} archive"
        export SHOULD_BUILD_REH="no"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Linux ${VSCODE_ARCH} because we have no REH-web archive"
        export SHOULD_BUILD="yes"
      else
        echo "Already have the Linux REH-web ${VSCODE_ARCH} archive"
        export SHOULD_BUILD_REH_WEB="no"
      fi

    else

      # linux-arm64
      if [[ "${VSCODE_ARCH}" == "arm64" || "${CHECK_ALL}" == "yes" ]]; then
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

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm64 because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm64 because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi

        export SHOULD_BUILD_APPIMAGE="no"

        if [[ "${SHOULD_BUILD}" != "yes" ]]; then
          echo "Already have all the Linux arm64 builds"
        fi
      fi

      # linux-armhf
      if [[ "${VSCODE_ARCH}" == "armhf" || "${CHECK_ALL}" == "yes" ]]; then
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

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux arm because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi

        export SHOULD_BUILD_APPIMAGE="no"

        if [[ "${SHOULD_BUILD}" != "yes" ]]; then
          echo "Already have all the Linux arm builds"
        fi
      fi

      # linux-ppc64le
      if [[ "${VSCODE_ARCH}" == "ppc64le" || "${CHECK_ALL}" == "yes" ]]; then
        SHOULD_BUILD_APPIMAGE="no"
        SHOULD_BUILD_DEB="no"
        SHOULD_BUILD_RPM="no"
        SHOULD_BUILD_TAR="no"

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux PowerPC64LE because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux PowerPC64LE because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi

        if [[ "${SHOULD_BUILD}" != "yes" ]]; then
          echo "Already have all the Linux PowerPC64LE builds"
        fi
      fi

      # linux-riscv64
      if [[ "${VSCODE_ARCH}" == "riscv64" || "${CHECK_ALL}" == "yes" ]]; then
        export SHOULD_BUILD_DEB="no"
        export SHOULD_BUILD_RPM="no"
        export SHOULD_BUILD_APPIMAGE="no"

        if [[ -z $( contains "${APP_NAME}-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no TAR"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_TAR="no"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux RISC-V 64 because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi

        if [[ "${SHOULD_BUILD}" != "yes" ]]; then
          echo "Already have all the Linux riscv64 builds"
        fi
      fi

      # linux-x64
      if [[ "${VSCODE_ARCH}" == "x64" || "${CHECK_ALL}" == "yes" ]]; then
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

        if [[ "${DISABLE_APPIMAGE}" == "yes" ]]; then
          export SHOULD_BUILD_APPIMAGE="no"
        elif [[ -z $( contains "x86_64.AppImage" ) ]]; then
          echo "Building on Linux x64 because we have no AppImage"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_APPIMAGE="no"
        fi

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux x64 because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Linux x64 because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi

        if [[ "${SHOULD_BUILD}" != "yes" ]]; then
          echo "Already have all the Linux x64 builds"
        fi
      fi
    fi

  elif [[ "${OS_NAME}" == "alpine" ]]; then

    if [[ "${CHECK_ONLY_REH}" == "yes" ]]; then
      if [[ -z $( contains "${APP_NAME_LC}-reh-alpine-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Alpine ${VSCODE_ARCH} because we have no REH archive"
        export SHOULD_BUILD="yes"
      else
        echo "Already have the Alpine REH ${VSCODE_ARCH} archive"
        export SHOULD_BUILD_REH="no"
      fi

      if [[ -z $( contains "${APP_NAME_LC}-reh-web-alpine-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
        echo "Building on Alpine ${VSCODE_ARCH} because we have no REH-web archive"
        export SHOULD_BUILD="yes"
      else
        echo "Already have the Alpine REH-web ${VSCODE_ARCH} archive"
        export SHOULD_BUILD_REH_WEB="no"
      fi
    else

      # alpine-arm64
      if [[ "${VSCODE_ARCH}" == "arm64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-alpine-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine arm64 because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

         if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-alpine-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine arm64 because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi
      fi

      # alpine-x64
      if [[ "${VSCODE_ARCH}" == "x64" || "${CHECK_ALL}" == "yes" ]]; then
        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-alpine-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine x64 because we have no REH archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH="no"
        fi

        if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-alpine-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
          echo "Building on Alpine x64 because we have no REH-web archive"
          export SHOULD_BUILD="yes"
        else
          export SHOULD_BUILD_REH_WEB="no"
        fi
      fi
    fi
  fi
else
  if [[ "${IS_SPEARHEAD}" == "yes" ]]; then
    export SHOULD_BUILD_SRC="yes"
  elif [[ "${OS_NAME}" == "linux" ]]; then
    if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
      SHOULD_BUILD_DEB="no"
      SHOULD_BUILD_RPM="no"
      SHOULD_BUILD_TAR="no"
    elif [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
      SHOULD_BUILD_DEB="no"
      SHOULD_BUILD_RPM="no"
    fi
    if [[ "${VSCODE_ARCH}" != "x64" || "${DISABLE_APPIMAGE}" == "yes" ]]; then
      export SHOULD_BUILD_APPIMAGE="no"
    fi
  elif [[ "${OS_NAME}" == "windows" ]]; then
    if [[ "${VSCODE_ARCH}" == "arm64" ]]; then
      export SHOULD_BUILD_REH="no"
      export SHOULD_BUILD_REH_WEB="no"
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
echo "SHOULD_BUILD_REH_WEB=${SHOULD_BUILD_REH_WEB}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_RPM=${SHOULD_BUILD_RPM}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_TAR=${SHOULD_BUILD_TAR}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_ZIP=${SHOULD_BUILD_ZIP}" >> "${GITHUB_ENV}"
echo "SHOULD_BUILD_SRC=${SHOULD_BUILD_SRC}" >> "${GITHUB_ENV}"
