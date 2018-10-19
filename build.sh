#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  cp -rp src/* vscode/
  cd vscode

  if [[ "$BUILDARCH" == "ia32" ]]; then
    export npm_config_arch=ia32
  fi

  ../update_settings.sh

  yarn
  mv product.json product.json.bak
  cat product.json.bak | jq 'setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"}) | setpath(["nameShort"]; "VSCodium") | setpath(["nameLong"]; "VSCodium") | setpath(["applicationName"]; "vscodium") | setpath(["win32MutexName"]; "vscodium") | setpath(["win32DirName"]; "VSCodium") | setpath(["win32NameVersion"]; "VSCodium") | setpath(["win32RegValueName"]; "VSCodium") | setpath(["win32AppUserModelId"]; "Microsoft.VSCodium") | setpath(["win32ShellNameShort"]; "V&SCodium") | setpath(["urlProtocol"]; "vscodium")' > product.json
  cat product.json
  ../undo_telemetry.sh

  export NODE_ENV=production

  if [[ "$TRAVIS_OS_NAME" != "osx" ]]; then
    # microsoft adds their apt repo to sources
    # unless the app name is code-oss
    # as we are renaming the application to vscodium
    # we need to edit a line in the post install template
    sed -i "s/code-oss/vscodium/" resources/linux/debian/postinst.template
  fi

  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    npm run gulp vscode-darwin-min
  elif [[ "$BUILDARCH" == "ia32" ]]; then
    npm run gulp vscode-linux-ia32-min
    npm run gulp vscode-linux-ia32-build-deb
    npm run gulp vscode-linux-ia32-build-rpm
    unset npm_config_arch
  elif [[ "$BUILDARCH" == "arm64" ]]; then
    npm run gulp vscode-linux-arm64-min
    npm run gulp vscode-linux-arm64-build-deb
    # npm run gulp vscode-linux-arm64-build-rpm
  else
    npm run gulp vscode-linux-x64-min
    npm run gulp vscode-linux-x64-build-deb
    npm run gulp vscode-linux-x64-build-rpm
  fi
fi
