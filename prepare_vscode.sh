#!/bin/bash

set -e

export npm_config_arch="$BUILDARCH"
export npm_config_target_arch="$BUILDARCH"

cp -rp src/* vscode/
cd vscode || exit

# ../update_settings.sh

# apply patches
# patch -u src/vs/platform/update/electron-main/updateService.win32.ts -i ../patches/update-cache-path.patch

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile --ignore-optional
  npm_config_argv='{"original":["--ignore-optional"]}' yarn postinstall
else
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile
  yarn postinstall
fi

if [[ "$BUILDARCH" == *"arm"* ]]; then
  sed -i -z 's/,\n[^\n]*arm[^\n]*//' node_modules/vscode-sqlite3/binding.gyp
  sed -i "s/Release\/sqlite'/Release\/sqlite.node'/" node_modules/vscode-sqlite3/lib/sqlite3.js
  yarn add -D electron-rebuild
  npx electron-rebuild -f -w vscode-sqlite3
fi

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
extensionsGallery='setpath(["extensionsGallery"]; {"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item"})'
linkProtectionTrustedDomains='setpath(["linkProtectionTrustedDomains"]; ["https://open-vsx.org"])'
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
extensionAllowedProposedApi='setpath(["extensionAllowedProposedApi"]; getpath(["extensionAllowedProposedApi"]) + ["ms-vsliveshare.vsliveshare", "ms-vscode-remote.remote-ssh"])'
serverDataFolderName='setpath(["serverDataFolderName"]; ".vscode-server-oss")'

product_json_changes="${tipsAndTricksUrl} | ${twitterUrl} | ${requestFeatureUrl} | ${documentationUrl} | ${introductoryVideosUrl} | ${extensionAllowedBadgeProviders} | ${updateUrl} | ${releaseNotesUrl} | ${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${linkProtectionTrustedDomains} | ${nameShort} | ${nameLong} | ${linuxIconName} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${extensionAllowedProposedApi} | ${serverDataFolderName}"
cat product.json.bak | jq "${product_json_changes}" > product.json
cat product.json

# ../undo_telemetry.sh

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vscodium
  # we need to edit a line in the post install template
  sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template
fi
