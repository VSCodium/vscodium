#!/bin/bash
if [[ "$VSCODE_ARCH" == "x64" ]]; then
  # install a dep needed for this process
  sudo apt-get install desktop-file-utils

  cd ..
  export DOCKER_BUILD=1
  bash -e src/resources/linux/appimage/pkg2appimage VSCodium-AppImage-Recipe.yml
fi
