#!/bin/bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

if [[ "${VSCODE_ARCH}" == "x64" ]]; then
  wget -c https://github.com/$(wget -q https://github.com/AppImage/pkg2appimage/releases -O - | grep "pkg2appimage-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
  chmod +x ./pkg2appimage-*.AppImage

  ./pkg2appimage-*.AppImage --appimage-extract && mv ./squashfs-root ./pkg2appimage.AppDir

  # add update's url
  sed -i 's/generate_type2_appimage/generate_type2_appimage -u "gh-releases-zsync|VSCodium|vscodium|latest|*.AppImage.zsync"/' pkg2appimage.AppDir/AppRun

  # remove check so build in docker can succeed
  sed -i 's/grep docker/# grep docker/' pkg2appimage.AppDir/usr/share/pkg2appimage/functions.sh

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i 's|@@NAME@@|VSCodium - Insiders|g' recipe.yml
    sed -i 's|@@APPNAME@@|codium-insiders|g' recipe.yml
    sed -i 's|@@ICON@@|vscodium-insiders|g' recipe.yml
  else
    sed -i 's|@@NAME@@|VSCodium|g' recipe.yml
    sed -i 's|@@APPNAME@@|codium|g' recipe.yml
    sed -i 's|@@ICON@@|vscodium|g' recipe.yml
  fi

  bash -ex pkg2appimage.AppDir/AppRun recipe.yml

  rm -f pkg2appimage-*.AppImage
  rm -rf pkg2appimage.AppDir
  rm -rf VSCodium*
fi

cd "${CALLER_DIR}"
