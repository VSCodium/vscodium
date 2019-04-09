#!/bin/bash
if [[ "$BUILDARCH" == "x64" ]]; then
  mkdir appimage
  cd appimage

  # download pkg2appimage from github
  curl -LO "https://github.com/AppImage/pkg2appimage/raw/master/pkg2appimage"
  
  bash -ex pkg2appimage ../../VSCodium-AppImage-Recipe.yml
  cd ..
fi
