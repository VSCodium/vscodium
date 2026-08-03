#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	libdbusmenu-glib

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Extracting VSCodium binary..."
echo "---------------------------------------------------------------"

mkdir -p ./AppDir/bin ./AppDir/share/applications
tar -xzf vscode-bin.tar.gz -C ./AppDir/bin/

# Keep the CLI usable from a terminal: 
# quick-sharun would overwrite bin/bin/codium with the Electron binary
# Renaming to codium-cli avoids the conflict; the desktop Exec= points to it.
# The script calls ../codium (Electron) internally, which deploys normally.
mv ./AppDir/bin/bin/codium ./AppDir/bin/bin/codium-cli

# Get version from env (set by CI) or from package.json
if [ -z "${RELEASE_VERSION:-}" ]; then
  VERSION=$(awk -F'"' '/"version":/ {print $4}' ./AppDir/bin/resources/app/package.json)
else
  VERSION="$RELEASE_VERSION"
fi
echo "$VERSION" > ~/version
echo "VSCodium version: $VERSION"

# Desktop entries from repo sources
QUALITY="${VSCODE_QUALITY:-stable}"
SRC_DIR="src/$QUALITY/resources/linux"

cp "$SRC_DIR/code.desktop" ./AppDir/
cp "$SRC_DIR/code-url-handler.desktop" ./AppDir/share/applications/

sed -i \
  -e 's/@@NAME_LONG@@/VSCodium/g' \
  -e 's/@@NAME_SHORT@@/codium/g' \
  -e 's/@@NAME@@/codium/g' \
  -e 's#@@EXEC@@#bin/codium-cli#g' \
  -e 's/@@ICON@@/vscodium/g' \
  -e 's/@@URLPROTOCOL@@/vscodium/g' \
  ./AppDir/code.desktop ./AppDir/share/applications/code-url-handler.desktop

# Icon will be set via ICON env var in make-appimage.sh
