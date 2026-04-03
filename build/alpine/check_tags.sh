#!/usr/bin/env bash

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
