#!/bin/bash
if [[ "$SHOULD_BUILD" == "yes" ]]; then
  cp -rp src/* vscode/
  cd vscode

  export npm_config_arch="$BUILDARCH"
  export npm_config_target_arch="$BUILDARCH"
  ../update_settings.sh

  yarn
  mv product.json product.json.bak

  # set fields in product.json
  quality='setpath(["quality"]; "stable")'
  extensionsGallery='setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"})'
  nameShort='setpath(["nameShort"]; "VSCodium")'
  nameLong='setpath(["nameLong"]; "VSCodium")'
  applicationName='setpath(["applicationName"]; "vscodium")'
  win32MutexName='setpath(["win32MutexName"]; "vscodium")'
  win32DirName='setpath(["win32DirName"]; "VSCodium")'
  win32NameVersion='setpath(["win32NameVersion"]; "VSCodium")'
  win32RegValueName='setpath(["win32RegValueName"]; "VSCodium")'
  win32AppUserModelId='setpath(["win32AppUserModelId"]; "Microsoft.VSCodium")'
  win32ShellNameShort='setpath(["win32ShellNameShort"]; "V&SCodium")'
  win32x64UserAppId='setpath (["win32x64UserAppId"]; "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}")'
  urlProtocol='setpath(["urlProtocol"]; "vscodium")'
  extensionAllowedProposedApi='setpath(["extensionAllowedProposedApi"]; getpath(["extensionAllowedProposedApi"]) + ["ms-vsliveshare.vsliveshare"])'
  keyboardShortcutsUrlMac='setpath(["keyboardShortcutsUrlMac"]; "https://go.microsoft.com/fwlink/?linkid=832143")'
  keyboardShortcutsUrlLinux='setpath(["keyboardShortcutsUrlLinux"]; "https://go.microsoft.com/fwlink/?linkid=832144")'
  keyboardShortcutsUrlWin='setpath(["keyboardShortcutsUrlWin"]; "https://go.microsoft.com/fwlink/?linkid=832145")'

  product_json_changes="${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${nameShort} | ${nameLong} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${extensionAllowedProposedApi}"
  cat product.json.bak | jq "${product_json_changes}" > product.json
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
    npm install --global create-dmg
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
