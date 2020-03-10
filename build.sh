#!/bin/bash

function keep_alive_small() {
  while true; do
    echo .
    read -t 60 < /proc/self/fd/1 > /dev/null 2>&1
  done
}

function keep_alive() {
  while true; do
    date
    sleep 60
  done
}

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  export BUILD_SOURCEVERSION=$LATEST_MS_COMMIT
  echo "LATEST_MS_COMMIT: ${LATEST_MS_COMMIT}"
  echo "BUILD_SOURCEVERSION: ${BUILD_SOURCEVERSION}"

  cp -rp src/* vscode/
  cd vscode || exit

  export npm_config_arch="$BUILDARCH"
  export npm_config_target_arch="$BUILDARCH"
  ../update_settings.sh

  # apply patches
  patch -u src/vs/platform/update/electron-main/updateService.win32.ts -i ../patches/update-cache-path.patch

  yarn --frozen-lockfile
  yarn postinstall
  mv product.json product.json.bak

  # set fields in product.json
  tipsAndTricksUrl='setpath(["tipsAndTricksUrl"]; "https://go.microsoft.com/fwlink/?linkid=852118")'
  twitterUrl='setpath(["twitterUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533687")'
  requestFeatureUrl='setpath(["requestFeatureUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533482")'
  documentationUrl='setpath(["documentationUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533484#vscode")'
  introductoryVideosUrl='setpath(["introductoryVideosUrl"]; "https://go.microsoft.com/fwlink/?linkid=832146")'
  extensionAllowedBadgeProviders='setpath(["extensionAllowedBadgeProviders"]; ["api.bintray.com", "api.travis-ci.com", "api.travis-ci.org", "app.fossa.io", "badge.fury.io", "badge.waffle.io", "badgen.net", "badges.frapsoft.com", "badges.gitter.im", "badges.greenkeeper.io", "cdn.travis-ci.com", "cdn.travis-ci.org", "ci.appveyor.com", "circleci.com", "cla.opensource.microsoft.com", "codacy.com", "codeclimate.com", "codecov.io", "coveralls.io", "david-dm.org", "deepscan.io", "dev.azure.com", "flat.badgen.net", "gemnasium.com", "githost.io", "gitlab.com", "godoc.org", "goreportcard.com", "img.shields.io", "isitmaintained.com", "marketplace.visualstudio.com", "nodesecurity.io", "opencollective.com", "snyk.io", "travis-ci.com", "travis-ci.org", "visualstudio.com", "vsmarketplacebadge.apphb.com", "www.bithound.io", "www.versioneye.com"])'
  updateUrl='setpath(["updateUrl"]; "https://vscodium.now.sh")'
  releaseNotesUrl='setpath(["releaseNotesUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533483#vscode")'
  keyboardShortcutsUrlMac='setpath(["keyboardShortcutsUrlMac"]; "https://go.microsoft.com/fwlink/?linkid=832143")'
  keyboardShortcutsUrlLinux='setpath(["keyboardShortcutsUrlLinux"]; "https://go.microsoft.com/fwlink/?linkid=832144")'
  keyboardShortcutsUrlWin='setpath(["keyboardShortcutsUrlWin"]; "https://go.microsoft.com/fwlink/?linkid=832145")'
  quality='setpath(["quality"]; "stable")'
  extensionsGallery='setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"})'
  nameShort='setpath(["nameShort"]; "VSCodium")'
  nameLong='setpath(["nameLong"]; "VSCodium")'
  linuxIconName='setpath(["linuxIconName"]; "vscodium")'
  applicationName='setpath(["applicationName"]; "codium")'
  win32MutexName='setpath(["win32MutexName"]; "vscodium")'
  win32DirName='setpath(["win32DirName"]; "VSCodium")'
  win32NameVersion='setpath(["win32NameVersion"]; "VSCodium")'
  win32RegValueName='setpath(["win32RegValueName"]; "VSCodium")'
  win32AppUserModelId='setpath(["win32AppUserModelId"]; "Microsoft.VSCodium")'
  win32ShellNameShort='setpath(["win32ShellNameShort"]; "VSCodium")'
  win32x64UserAppId='setpath (["win32x64UserAppId"]; "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}")'
  urlProtocol='setpath(["urlProtocol"]; "vscodium")'
  extensionAllowedProposedApi='setpath(["extensionAllowedProposedApi"]; getpath(["extensionAllowedProposedApi"]) + ["ms-vsliveshare.vsliveshare"])'

  product_json_changes="${tipsAndTricksUrl} | ${twitterUrl} | ${requestFeatureUrl} | ${documentationUrl} | ${introductoryVideosUrl} | ${extensionAllowedBadgeProviders} | ${updateUrl} | ${releaseNotesUrl} | ${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${nameShort} | ${nameLong} | ${linuxIconName} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${extensionAllowedProposedApi}"
  cat product.json.bak | jq "${product_json_changes}" > product.json
  cat product.json
  ../undo_telemetry.sh

  export NODE_ENV=production

  if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    # microsoft adds their apt repo to sources
    # unless the app name is code-oss
    # as we are renaming the application to vscodium
    # we need to edit a line in the post install template
    sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template
  fi

  # these tasks are very slow, so using a keep alive to keep travis alive
  if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    keep_alive_small &
  else
    keep_alive &
  fi

  KA_PID=$!

  yarn gulp compile-build
  yarn gulp compile-extensions-build

  yarn gulp minify-vscode

  yarn gulp minify-vscode-reh
  yarn gulp minify-vscode-reh-web

  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    npm install --global create-dmg
    yarn gulp vscode-darwin-min-ci
    yarn gulp vscode-reh-darwin-min-ci
    yarn gulp vscode-reh-web-darwin-min-ci
  elif [[ "$CI_WINDOWS" == "True" ]]; then
    cp LICENSE.txt LICENSE.rtf # windows build expects rtf license
    yarn gulp "vscode-win32-${BUILDARCH}-min-ci"
    yarn gulp "vscode-reh-win32-${BUILDARCH}-min-ci"
    yarn gulp "vscode-reh-web-win32-${BUILDARCH}-min-ci"
    yarn gulp "vscode-win32-${BUILDARCH}-code-helper"
    yarn gulp "vscode-win32-${BUILDARCH}-inno-updater"
    yarn gulp "vscode-win32-${BUILDARCH}-archive"
    yarn gulp "vscode-win32-${BUILDARCH}-system-setup"
    yarn gulp "vscode-win32-${BUILDARCH}-user-setup"
  else # linux
    yarn gulp vscode-linux-${BUILDARCH}-min-ci
    yarn gulp vscode-reh-linux-${BUILDARCH}-min-ci
    yarn gulp vscode-reh-web-linux-${BUILDARCH}-min-ci

    yarn gulp "vscode-linux-${BUILDARCH}-build-deb"
    if [[ "$BUILDARCH" == "x64" ]]; then
      yarn gulp "vscode-linux-${BUILDARCH}-build-rpm"
    fi
    . ../create_appimage.sh
  fi

  kill $KA_PID

  cd ..
fi
