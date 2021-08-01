#!/bin/bash

cd ..

if [[ "$VSCODE_ARCH" == "x64" ]]; then
  wget -c https://github.com/$(wget -q https://github.com/AppImage/pkg2appimage/releases -O - | grep "pkg2appimage-.*-x86_64.AppImage" | head -n 1 | cut -d '"' -f 2)
  chmod +x ./pkg2appimage-*.AppImage

  ./pkg2appimage-*.AppImage --appimage-extract && mv ./squashfs-root ./pkg2appimage.AppDir

  # add update's url
  sed -i 's/generate_type2_appimage/generate_type2_appimage -u "gh-releases-zsync|VSCodium|vscodium|latest|*.AppImage.zsync"/' pkg2appimage.AppDir/AppRun

  # remove check so build in docker can succeed
  sed -i 's/grep docker/# grep docker/' pkg2appimage.AppDir/usr/share/pkg2appimage/functions.sh

  bash -ex pkg2appimage.AppDir/AppRun VSCodium-AppImage-Recipe.yml
fi

cd vscode
