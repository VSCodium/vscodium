#!/bin/bash

set -e

cp -rp src/* vscode/
cp -f LICENSE vscode/LICENSE.txt

cd vscode || exit

../update_settings.sh

# apply patches
{ set +x; } 2>/dev/null

for file in ../patches/*.patch; do
  if [ -f "$file" ]; then
    echo applying patch: $file;
    git apply --ignore-whitespace "$file"
    if [ $? -ne 0 ]; then
      echo failed to apply patch $file 1>&2
    fi
  fi
done

for file in ../patches/user/*.patch; do
  if [ -f "$file" ]; then
    echo applying user patch: $file;
    git apply --ignore-whitespace "$file"
    if [ $? -ne 0 ]; then
      echo failed to apply patch $file 1>&2
    fi
  fi
done

set -x

if [[ "$OS_NAME" == "osx" ]]; then
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile --ignore-optional
  npm_config_argv='{"original":["--ignore-optional"]}' yarn postinstall
else
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile
fi

mv product.json product.json.bak

# set fields in product.json
checksumFailMoreInfoUrl='setpath(["checksumFailMoreInfoUrl"]; "https://go.microsoft.com/fwlink/?LinkId=828886")'
tipsAndTricksUrl='setpath(["tipsAndTricksUrl"]; "https://go.microsoft.com/fwlink/?linkid=852118")'
twitterUrl='setpath(["twitterUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533687")'
requestFeatureUrl='setpath(["requestFeatureUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533482")'
documentationUrl='setpath(["documentationUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533484#vscode")'
introductoryVideosUrl='setpath(["introductoryVideosUrl"]; "https://go.microsoft.com/fwlink/?linkid=832146")'
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
serverDataFolderName='setpath(["serverDataFolderName"]; ".vscode-server-oss")'
reportIssueUrl='setpath(["reportIssueUrl"]; "https://github.com/VSCodium/vscodium/issues/new/choose")'
licenseUrl='setpath(["licenseUrl"]; "https://github.com/VSCodium/vscodium/blob/master/LICENSE")'

product_json_changes="${checksumFailMoreInfoUrl} | ${tipsAndTricksUrl} | ${twitterUrl} | ${requestFeatureUrl} | ${documentationUrl} | ${introductoryVideosUrl} | ${updateUrl} | ${releaseNotesUrl} | ${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${linkProtectionTrustedDomains} | ${nameShort} | ${nameLong} | ${linuxIconName} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${serverDataFolderName} | ${reportIssueUrl} | ${licenseUrl}"
cat product.json.bak | jq "${product_json_changes}" > product.json.tmp

jq -s '.[0] * .[1]' product.json.tmp ../product.json > product.json
rm -f product.json.tmp

cat product.json

../undo_telemetry.sh

if [[ "$OS_NAME" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vscodium
  # we need to edit a line in the post install template
  sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://vscodium.com/img/vscodium.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|VSCodium|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/VSCodium/vscodium#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|Microsoft Corporation|VSCodium Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|VSCodium Team https://github.com/VSCodium/vscodium/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://vscodium.com|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|VSCodium|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|VSCodium|'  resources/linux/rpm/code.spec.template
fi

cd ..
