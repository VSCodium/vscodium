#!/usr/bin/env bash

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

if [[ -z $( contains "${APP_NAME_LC}-cli-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" ) ]]; then
  echo "Building on MacOS because we have no CLI archive"
  export SHOULD_BUILD="yes"
else
  export SHOULD_BUILD_CLI="no"
fi

if [[ "${SHOULD_BUILD}" != "yes" ]]; then
  echo "Already have all the MacOS builds"
fi
