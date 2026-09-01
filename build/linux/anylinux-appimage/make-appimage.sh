#!/usr/bin/env bash

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm libdbusmenu-glib

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Extracting VSCodium binary..."
echo "---------------------------------------------------------------"

mkdir -p ./AppDir/bin ./AppDir/share/applications
tar -xzf vscode-bin.tar.gz -C ./AppDir/bin/

NAME_LONG=$(jq -r '.nameLong' ./AppDir/bin/resources/app/product.json)
NAME_SHORT=$(jq -r '.nameShort' ./AppDir/bin/resources/app/product.json)
NAME=$(jq -r '.applicationName' ./AppDir/bin/resources/app/product.json)
ICON=$(jq -r '.linuxIconName' ./AppDir/bin/resources/app/product.json)
URLPROTOCOL=$(jq -r '.urlProtocol' ./AppDir/bin/resources/app/product.json)
VERSION="${RELEASE_VERSION%-insider}"

echo "NAME_LONG=${NAME_LONG}"
echo "NAME_SHORT=${NAME_SHORT}"
echo "NAME=${NAME}"
echo "ICON=${ICON}"
echo "URLPROTOCOL=${URLPROTOCOL}"
echo "VERSION=${VERSION}"

echo "${VERSION}" > ~/version

# Desktop entries from repo sources
SRC_DIR="src/${VSCODE_QUALITY}/resources/linux"

cp "${SRC_DIR}/code.desktop" "./AppDir/${NAME}.desktop"
cp "${SRC_DIR}/code-url-handler.desktop" "./AppDir/share/applications/${NAME}-url-handler.desktop"

# Keeps CLI commands working and doesn't affect normal GUI launch
cp ./build/linux/anylinux-appimage/cli-router.hook ./AppDir/bin/cli-router.hook

sed -i \
  -e "s/@@NAME_LONG@@/${NAME_LONG}/g" \
  -e "s/@@NAME_SHORT@@/${NAME_SHORT}/g" \
  -e "s/@@NAME@@/${NAME}/g" \
  -e "s#@@EXEC@@#${NAME}#g" \
  -e "s/@@ICON@@/${ICON}/g" \
  -e "s/@@URLPROTOCOL@@/${URLPROTOCOL}/g" \
  "./AppDir/${NAME}.desktop" \
  "./AppDir/share/applications/${NAME}-url-handler.desktop" \
  ./AppDir/bin/cli-router.hook

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  export OUTNAME=${APP_NAME}-Insiders-${VERSION}-anylinux-"${ARCH}".AppImage
else
  export OUTNAME=${APP_NAME}-${VERSION}-anylinux-"${ARCH}".AppImage
fi

export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*${ARCH}.AppImage.zsync"
export ICON="src/${VSCODE_QUALITY}/resources/linux/code.svg"
export DEPLOY_GTK=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun ./AppDir/bin/*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the AppImage (simple test: check for missing symbols)
quick-sharun --simple-test ./dist/*.AppImage
