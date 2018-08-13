#!/bin/bash

cd vscode
yarn
mv product.json product.json.bak
cat product.json.bak | jq 'setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"})' > product.json
export NODE_ENV=production

if [[ "$TRAVIS_OS_NAME" === "osx" ]]; then
  npx gulp vscode-darwin-min
else
  npx gulp vscode-linux-x64-min
fi

cd ..