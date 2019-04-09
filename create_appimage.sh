#!/bin/bash
if [[ "$BUILDARCH" == "x64" ]]; then
  # download pkg2appimage from github
  curl -LO "https://github.com/AppImage/pkg2appimage/raw/master/pkg2appimage"
  
  bash -e pkg2appimage ../VSCodium-AppImage-Recipe.yml
fi
