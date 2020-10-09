#!/bin/bash

set -e

REPOSITORY=${GITHUB_REPOSITORY:-"VSCodium/vscodium"}
GITHUB_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$REPOSITORY/releases/tags/$LATEST_MS_TAG)
VSCODIUM_ASSETS=$(echo $GITHUB_RESPONSE | jq '.assets')

# if we just don't have the github token, get out fast
if [ "$GITHUB_TOKEN" != "" ]; then
  if [ "$VSCODIUM_ASSETS" != "null" ]; then
    if [[ "$OS_NAME" == "osx" ]]; then
      HAVE_MAC=$(echo $VSCODIUM_ASSETS | jq --arg suffix "darwin-$LATEST_MS_TAG.zip" 'map(.name) | contains([$suffix])')
      if [[ "$HAVE_MAC" != "true" ]]; then
        echo "Building on Mac because we have no ZIP"
        export SHOULD_BUILD="yes"
      fi
    elif [[ $VSCODE_ARCH == "arm64" ]]; then
      HAVE_ARM64_DEB=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["arm64.deb"])')
      HAVE_ARM64_TAR=$(echo $VSCODIUM_ASSETS | jq --arg suffix "arm64-$LATEST_MS_TAG.tar.gz" 'map(.name) | contains([$suffix])')
      if [[ "$HAVE_ARM64_DEB" != "true" ]]; then
        echo "Building on Linux arm64 because we have no DEB"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$HAVE_ARM64_TAR" != "true" ]]; then
        echo "Building on Linux arm64 because we have no TAR"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$SHOULD_BUILD" != "yes" ]]; then
        echo "Already have all the Linux arm64 builds"
      fi
    elif [[ $VSCODE_ARCH == "armhf" ]]; then
      HAVE_ARM_DEB=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["armhf.deb"])')
      HAVE_ARM_TAR=$(echo $VSCODIUM_ASSETS | jq --arg suffix "armhf-$LATEST_MS_TAG.tar.gz" 'map(.name) | contains([$suffix])')
      if [[ "$HAVE_ARM_DEB" != "true" ]]; then
        echo "Building on Linux arm because we have no DEB"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$HAVE_ARM_TAR" != "true" ]]; then
        echo "Building on Linux arm because we have no TAR"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$SHOULD_BUILD" != "yes" ]]; then
        echo "Already have all the Linux arm builds"
      fi
    else
      HAVE_64_RPM=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["x86_64.rpm"])')
      HAVE_64_DEB=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["amd64.deb"])')
      HAVE_64_TAR=$(echo $VSCODIUM_ASSETS | jq --arg suffix "x64-$LATEST_MS_TAG.tar.gz" 'map(.name) | contains([$suffix])')
      if [[ "$HAVE_64_RPM" != "true" ]]; then
        echo "Building on Linux x64 because we have no RPM"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$HAVE_64_DEB" != "true" ]]; then
        echo "Building on Linux x64 because we have no DEB"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$HAVE_64_TAR" != "true" ]]; then
        echo "Building on Linux x64 because we have no TAR"
        export SHOULD_BUILD="yes"
      fi
      if [[ "$SHOULD_BUILD" != "yes" ]]; then
        echo "Already have all the Linux x64 builds"
      fi
    fi
  else
    echo "Release assets do not exist at all, continuing build"
    export SHOULD_BUILD="yes"
  fi
fi

echo "SHOULD_BUILD=$SHOULD_BUILD" >> $GITHUB_ENV
