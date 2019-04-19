#!/bin/bash
if [[ "$SHOULD_BUILD" == "yes" ]]; then
  cp -rp src/* vscode/
  cd vscode

  export npm_config_arch="$BUILDARCH"
  export npm_config_target_arch="$BUILDARCH"
  ../update_settings.sh

  yarn
  mv product.json product.json.bak
  cat product.json.bak | jq 'setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"}) | setpath(["nameShort"]; "VSCodium") | setpath(["nameLong"]; "VSCodium") | setpath(["applicationName"]; "vscodium") | setpath(["win32MutexName"]; "vscodium") | setpath(["win32DirName"]; "VSCodium") | setpath(["win32NameVersion"]; "VSCodium") | setpath(["win32RegValueName"]; "VSCodium") | setpath(["win32AppUserModelId"]; "Microsoft.VSCodium") | setpath(["win32ShellNameShort"]; "V&SCodium") | setpath (["win32x64UserAppId"]; "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}") | setpath(["urlProtocol"]; "vscodium") | setpath(["extensionAllowedProposedApi"]; getpath(["extensionAllowedProposedApi"]) + ["ms-vsliveshare.vsliveshare"])' > product.json
  cat product.json
  ../undo_telemetry.sh

  export NODE_ENV=production

  if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    # microsoft adds their apt repo to sources
    # unless the app name is code-oss
    # as we are renaming the application to vscodium
    # we need to edit a line in the post install template
    sed -i "s/code-oss/vscodium/" resources/linux/debian/postinst.template
  fi

  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    npm run gulp -- "vscode-darwin-min"
  elif [[ "$CI_WINDOWS" == "True" ]]; then
    cp LICENSE.txt LICENSE.rtf # windows build expects rtf license
    npm run gulp -- "vscode-win32-${BUILDARCH}-min"
    npm run gulp -- "vscode-win32-${BUILDARCH}-inno-updater"
    npm run gulp -- "vscode-win32-${BUILDARCH}-system-setup"
    npm run gulp -- "vscode-win32-${BUILDARCH}-user-setup"
    npm run gulp -- "vscode-win32-${BUILDARCH}-archive"
  else # linux
    npm run gulp -- "vscode-linux-${BUILDARCH}-min"
    npm run gulp -- "vscode-linux-${BUILDARCH}-build-deb"
    npm run gulp -- "vscode-linux-${BUILDARCH}-build-rpm"
    . ../create_appimage.sh
  fi

  cd ..
fi
