#!/usr/bin/env bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

# Include utilities
. ../../utils.sh

SNAP_VERSION=$( echo "${RELEASE_VERSION}" | sed 's|\-insider||' )
ICON_NAME="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  ICON_NAME="${ICON_NAME}-insiders"
fi

rm -rf build
mkdir -p build/snap/gui

if [[ "${CI_BUILD}" == "no" ]]; then
  DEB_ARCHIVE=$( ls ../../vscode/build/linux/deb/amd64/deb/*.deb )
else
  # Get GitHub releases
  wget --quiet "https://api.github.com/repos/${ASSETS_REPOSITORY}/releases" -O gh_latest.json

  DEB_URL=$( jq -r 'map(select(.tag_name == "'"${RELEASE_VERSION}"'"))|first.assets[].browser_download_url|select(endswith("'"_${ARCHITECTURE}.deb"'"))' gh_latest.json )
  DEB_ARCHIVE=$( basename "${DEB_URL}" )

  # Downloading .deb
  wget "${DEB_URL}" -O "${DEB_ARCHIVE}"

  rm gh_latest.json
fi

# Unpacking .deb
dpkg -x "${DEB_ARCHIVE}" build/deb

mkdir -p build/snap/usr/share
mv "build/deb/usr/share/${BINARY_NAME}" "build/snap/usr/share/${BINARY_NAME}"

# Prepare snapcraft.yaml
cp ${VSCODE_QUALITY}/snapcraft.yaml build/snap/snapcraft.yaml

replace "s|@@SNAP_NAME@@|${BINARY_NAME}|g" build/snap/snapcraft.yaml
replace "s|@@SNAP_VERSION@@|${SNAP_VERSION}|g" build/snap/snapcraft.yaml

# Prepare electron-launch
cp ${VSCODE_QUALITY}/electron-launch build/snap/electron-launch

# Prepare GUI
cp "../../src/${VSCODE_QUALITY}/resources/linux/code.png" "build/snap/gui/${BINARY_NAME}.png"
cp build/deb/usr/share/applications/*.desktop build/snap/gui

sed -i "s|Exec=/usr/share/${BINARY_NAME}/${BINARY_NAME}|Exec=${BINARY_NAME} --force-user-env|g" "build/snap/gui/${BINARY_NAME}.desktop"
sed -i "s|Exec=/usr/share/${BINARY_NAME}/${BINARY_NAME}|Exec=${BINARY_NAME} --force-user-env|g" "build/snap/gui/${BINARY_NAME}-url-handler.desktop"
sed -i "s|Icon=${ICON_NAME}|Icon=\${SNAP}/meta/gui/${BINARY_NAME}.png|g" "build/snap/gui/${BINARY_NAME}.desktop"
sed -i "s|Icon=${ICON_NAME}|Icon=\${SNAP}/meta/gui/${BINARY_NAME}.png|g" "build/snap/gui/${BINARY_NAME}-url-handler.desktop"

# Clean up
rm -rf build/deb

cd build

if [[ "${CI_BUILD}" == "no" ]]; then
  snapcraft --use-lxd --debug
# else
#   snapcraft

#   SNAP_ARCHIVE=$( ls *.snap )

#   echo "snap=$( pwd )/${SNAP_ARCHIVE}" >> "$GITHUB_OUTPUT"
fi

cd "${CALLER_DIR}"
