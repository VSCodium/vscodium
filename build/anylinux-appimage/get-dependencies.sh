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

# Protect the CLI script from being overwritten by quick-sharun.
# quick-sharun skips non-executable files (checks -x in both
# _is_deployable_binary and _handle_nested_bins).
# We restore +x after deployment in make-appimage.sh.
chmod -x ./AppDir/bin/bin/codium

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
  -e 's#@@EXEC@@#codium#g' \
  -e 's/@@ICON@@/vscodium/g' \
  -e 's/@@URLPROTOCOL@@/vscodium/g' \
  ./AppDir/code.desktop ./AppDir/share/applications/code-url-handler.desktop

# Icon will be set via ICON env var in make-appimage.sh
