#!/usr/bin/env bash

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

    if [[ -z $( contains "arm64.snap" ) || "${FORCE_LINUX_SNAP}" == "true" ]]; then
      echo "Building on Linux arm64 because we have no SNAP"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_SNAP="no"
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

    if [[ -z $( contains "${APP_NAME_LC}-cli-linux-arm64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux arm64 because we have no CLI archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_CLI="no"
    fi


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

    if [[ -z $( contains "${APP_NAME_LC}-cli-linux-armhf-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux arm because we have no CLI archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_CLI="no"
    fi


    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      echo "Already have all the Linux arm builds"
    fi
  fi

  # linux-ppc64le
  if [[ "${VSCODE_ARCH}" == "ppc64le" || "${CHECK_ALL}" == "yes" ]]; then
    export SHOULD_BUILD_APPIMAGE="no"

    if [[ -z $( contains "ppc64el.deb" ) ]]; then
      echo "Building on Linux PowerPC64LE because we have no DEB"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_DEB="no"
    fi

    if [[ -z $( contains "ppc64le.rpm" ) ]]; then
      echo "Building on Linux PowerPC64LE because we have no RPM"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_RPM="no"
    fi

    if [[ -z $( contains "${APP_NAME}-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux PowerPC64LE because we have no TAR"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_TAR="no"
    fi

    if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux PowerPC64LE because we have no REH archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH="no"
    fi

    if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux PowerPC64LE because we have no REH-web archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH_WEB="no"
    fi

    if [[ -z $( contains "${APP_NAME_LC}-cli-linux-ppc64le-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux PowerPC64LE because we have no CLI archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_CLI="no"
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

    if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux RISC-V 64 because we have no REH archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH="no"
    fi

    if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-linux-riscv64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux RISC-V 64 because we have no REH-web archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH_WEB="no"
    fi

    export SHOULD_BUILD_CLI="no"

    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      echo "Already have all the Linux riscv64 builds"
    fi
  fi

  # linux-loong64
  if [[ "${VSCODE_ARCH}" == "loong64" || "${CHECK_ALL}" == "yes" ]]; then
    export SHOULD_BUILD_DEB="no"
    export SHOULD_BUILD_RPM="no"
    export SHOULD_BUILD_APPIMAGE="no"

    if [[ -z $( contains "${APP_NAME}-linux-loong64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux Loong64 because we have no TAR"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_TAR="no"
    fi

    if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-linux-loong64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux Loong64 because we have no REH archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH="no"
    fi

    if [[ "${CHECK_REH}" != "no" && -z $( contains "${APP_NAME_LC}-reh-web-linux-loong64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux Loong64 because we have no REH-web archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH_WEB="no"
    fi

    export SHOULD_BUILD_CLI="no"

    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      echo "Already have all the Linux Loong64 builds"
    fi
  fi

  # linux-s390x
  if [[ "${VSCODE_ARCH}" == "s390x" || "${CHECK_ALL}" == "yes" ]]; then
    SHOULD_BUILD_APPIMAGE="no"
    SHOULD_BUILD_DEB="no"
    SHOULD_BUILD_RPM="no"
    SHOULD_BUILD_TAR="no"

    if [[ -z $( contains "${APP_NAME_LC}-reh-linux-s390x-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux s390x because we have no REH archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH="no"
    fi

    if [[ -z $( contains "${APP_NAME_LC}-reh-web-linux-s390x-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux s390x because we have no REH-web archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_REH_WEB="no"
    fi

    export SHOULD_BUILD_CLI="no"

    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      echo "Already have all the Linux s390x builds"
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

    if [[ -z $( contains "amd64.snap" ) || "${FORCE_LINUX_SNAP}" == "true" ]]; then
      echo "Building on Linux x64 because we have no SNAP"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_SNAP="no"
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

    if [[ -z $( contains "${APP_NAME_LC}-cli-linux-x64-${RELEASE_VERSION}.tar.gz" ) ]]; then
      echo "Building on Linux x64 because we have no CLI archive"
      export SHOULD_BUILD="yes"
    else
      export SHOULD_BUILD_CLI="no"
    fi

    if [[ "${SHOULD_BUILD}" != "yes" ]]; then
      echo "Already have all the Linux x64 builds"
    fi
  fi
fi
