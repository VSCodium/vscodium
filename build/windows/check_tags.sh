#!/usr/bin/env bash

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

  if [[ -z $( contains "${APP_NAME_LC}-cli-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
    echo "Building on Windows arm64 because we have no CLI archive"
    export SHOULD_BUILD="yes"
  else
    export SHOULD_BUILD_CLI="no"
  fi

  if [[ "${SHOULD_BUILD}" != "yes" ]]; then
    echo "Already have all the Windows arm64 builds"
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

  if [[ "${DISABLE_MSI}" == "yes" ]]; then
      export SHOULD_BUILD_MSI="no"
  elif [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}.msi" ) ]]; then
    echo "Building on Windows x64 because we have no msi"
    export SHOULD_BUILD="yes"
  else
    export SHOULD_BUILD_MSI="no"
  fi

  if [[ "${DISABLE_MSI}" == "yes" ]]; then
      export SHOULD_BUILD_MSI_NOUP="no"
  elif [[ -z $( contains "${APP_NAME}-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi" ) ]]; then
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

  if [[ -z $( contains "${APP_NAME_LC}-cli-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
    echo "Building on Windows x64 because we have no CLI archive"
    export SHOULD_BUILD="yes"
  else
    export SHOULD_BUILD_CLI="no"
  fi

  if [[ "${SHOULD_BUILD}" != "yes" ]]; then
    echo "Already have all the Windows x64 builds"
  fi
fi
