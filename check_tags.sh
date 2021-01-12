#!/bin/bash

set -e

REPOSITORY=${GITHUB_REPOSITORY:-"VSCodium/vscodium"}
GITHUB_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$REPOSITORY/releases/tags/$LATEST_MS_TAG)
VSCODIUM_ASSETS=$(echo $GITHUB_RESPONSE | jq '.assets')

# if we just don't have the github token, get out fast
if [ "$GITHUB_TOKEN" != "" ]; then
  if [ "$VSCODIUM_ASSETS" != "null" ]; then
    if [[ "$OS_NAME" == "osx" ]]; then
      HAVE_MAC=$(echo $VSCODIUM_ASSETS | jq --arg suffix "darwin-$VSCODE_ARCH-$LATEST_MS_TAG.zip" 'map(.name) | contains([$suffix])')
      if [[ "$HAVE_MAC" != "true" ]]; then
        echo "Building on Mac because we have no ZIP"
        export SHOULD_BUILD="yes"
      fi
    elif [[ "$OS_NAME" == "windows" ]]; then
      if [[ $VSCODE_ARCH == "arm64" ]]; then
        HAVE_ARM64_SYS=$(echo $VSCODIUM_ASSETS | jq --arg suffix "$VSCODE_ARCH-$LATEST_MS_TAG.exe" 'map(.name) | contains([$suffix])')
        HAVE_ARM64_USR=$(echo $VSCODIUM_ASSETS | jq --arg suffix "UserSetup-$VSCODE_ARCH-$LATEST_MS_TAG.exe" 'map(.name) | contains([$suffix])')
        HAVE_ARM64_ZIP=$(echo $VSCODIUM_ASSETS | jq --arg suffix "win32-$VSCODE_ARCH-$LATEST_MS_TAG.zip" 'map(.name) | contains([$suffix])')
        if [[ "$HAVE_ARM64_SYS" != "true" ]]; then
          echo "Building on Windows arm64 because we have no system setup"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$HAVE_ARM64_USR" != "true" ]]; then
          echo "Building on Windows arm64 because we have no user setup"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$HAVE_ARM64_ZIP" != "true" ]]; then
          echo "Building on Windows arm64 because we have no zip"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$SHOULD_BUILD" != "yes" ]]; then
          echo "Already have all the Windows arm64 builds"
        fi
      elif [[ $VSCODE_ARCH == "ia32" ]]; then
        HAVE_IA32_SYS=$(echo $VSCODIUM_ASSETS | jq --arg suffix "$VSCODE_ARCH-$LATEST_MS_TAG.exe" 'map(.name) | contains([$suffix])')
        HAVE_IA32_USR=$(echo $VSCODIUM_ASSETS | jq --arg suffix "UserSetup-$VSCODE_ARCH-$LATEST_MS_TAG.exe" 'map(.name) | contains([$suffix])')
        HAVE_IA32_ZIP=$(echo $VSCODIUM_ASSETS | jq --arg suffix "win32-$VSCODE_ARCH-$LATEST_MS_TAG.zip" 'map(.name) | contains([$suffix])')
        if [[ "$HAVE_IA32_SYS" != "true" ]]; then
          echo "Building on Windows ia32 because we have no system setup"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$HAVE_IA32_USR" != "true" ]]; then
          echo "Building on Windows ia32 because we have no user setup"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$HAVE_IA32_ZIP" != "true" ]]; then
          echo "Building on Windows ia32 because we have no zip"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$SHOULD_BUILD" != "yes" ]]; then
          echo "Already have all the Windows ia32 builds"
        fi
      else # Windows x64
        HAVE_X64_SYS=$(echo $VSCODIUM_ASSETS | jq --arg suffix "$VSCODE_ARCH-$LATEST_MS_TAG.exe" 'map(.name) | contains([$suffix])')
        HAVE_X64_USR=$(echo $VSCODIUM_ASSETS | jq --arg suffix "UserSetup-$VSCODE_ARCH-$LATEST_MS_TAG.exe" 'map(.name) | contains([$suffix])')
        HAVE_X64_ZIP=$(echo $VSCODIUM_ASSETS | jq --arg suffix "win32-$VSCODE_ARCH-$LATEST_MS_TAG.zip" 'map(.name) | contains([$suffix])')
        if [[ "$HAVE_X64_SYS" != "true" ]]; then
          echo "Building on Windows x64 because we have no system setup"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$HAVE_X64_USR" != "true" ]]; then
          echo "Building on Windows x64 because we have no user setup"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$HAVE_X64_ZIP" != "true" ]]; then
          echo "Building on Windows x64 because we have no zip"
          export SHOULD_BUILD="yes"
        fi
        if [[ "$SHOULD_BUILD" != "yes" ]]; then
          echo "Already have all the Windows x64 builds"
        fi
      fi
    elif [[ "$OS_NAME" == "linux" ]]; then
      if [[ $VSCODE_ARCH == "arm64" ]]; then
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
      else # Linux x64
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
    fi
  else
    echo "Release assets do not exist at all, continuing build"
    export SHOULD_BUILD="yes"
  fi
fi

echo "SHOULD_BUILD=$SHOULD_BUILD" >> $GITHUB_ENV
