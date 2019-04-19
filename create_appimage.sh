#!/bin/bash
if [[ "$BUILDARCH" == "x64" ]]; then
  # install a dep needed for this process
  sudo apt-get install desktop-file-utils

  # download pkg2appimage from github
  curl -LO "https://github.com/AppImage/pkg2appimage/raw/master/pkg2appimage"
  
  bash -e pkg2appimage ../VSCodium-AppImage-Recipe.yml
fi
