#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  cd vscode
  yarn
  mv product.json product.json.bak
  cat product.json.bak | jq 'setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"}) | setpath(["nameShort"]; "VSCodium") | setpath(["nameLong"]; "VSCodium") | setpath(["applicationName"]; "vscodium") | setpath(["win32MutexName"]; "vscodium") | setpath(["win32DirName"]; "VSCodium") | setpath(["win32NameVersion"]; "VSCodium") | setpath(["win32RegValueName"]; "VSCodium") | setpath(["win32AppUserModelId"]; "Microsoft.VSCodium") | setpath(["win32ShellNameShort"]; "V&SCodium") | setpath(["urlProtocol"]; "vscodium")' > product.json
  cat product.json
  export NODE_ENV=production

  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    # remove dc.services.visualstudio.com tracking
    grep -rl --exclude-dir=.git "dc.services.visualstudio.com" . | xargs sed -i '' 's/dc\.services\.visualstudio\.com/0\.0\.0\.0/g'
    # remove vortex.data.microsoft.com tracking
    grep -rl --exclude-dir=.git "vortex.data.microsoft.com" . | xargs sed -i '' 's/vortex\.data\.microsoft\.com/0\.0\.0\.0/g'

    npx gulp vscode-darwin-min
  else
    # microsoft adds their apt repo to sources
    # unless the app name is code-oss
    # as we are renaming the application to vscodium
    # we need to edit a line in the post install template
    sed -i "s/code-oss/vscodium/" resources/linux/debian/postinst.template

    # delete dc.services.visualstudio.com tracking
    grep -rl --exclude-dir=.git "dc.services.visualstudio.com" . | xargs sed -i 's/dc\.services\.visualstudio\.com/0\.0\.0\.0/g'
    # remove vortex.data.microsoft.com tracking
    grep -rl --exclude-dir=.git "vortex.data.microsoft.com" . | xargs sed -i 's/vortex\.data\.microsoft\.com/0\.0\.0\.0/g'

    npx gulp vscode-linux-x64-min
    npx gulp vscode-linux-x64-build-deb
    npx gulp vscode-linux-x64-build-rpm
  fi

  cd ..
fi