#!/bin/bash
if [[ "$BUILDARCH" == "x64" ]]; then
  # install a dep needed for this process
  sudo apt-get install desktop-file-utils

  # download modified pkg2appimage from gist
  curl -LO "https://gist.githubusercontent.com/tyu1996/39b8a7a29c2cdeef882daaa1702ec971/raw/2e788010deafb2f1214439ee0bc8e46685480e45/pkg2appimage"
  
  bash -e pkg2appimage ../VSCodium-AppImage-Recipe.yml
fi
