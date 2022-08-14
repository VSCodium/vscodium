#!/bin/bash

set -e

# include common functions
. ../utils.sh

cp -rp src/* vscode/
cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

../update_settings.sh

# apply patches
{ set +x; } 2>/dev/null

for file in ../patches/*.patch; do
  if [ -f "${file}" ]; then
    echo applying patch: "${file}";
    git apply --ignore-whitespace "${file}"
    if [ $? -ne 0 ]; then
      echo failed to apply patch "${file}" 1>&2
    fi
  fi
done

for file in ../patches/user/*.patch; do
  if [ -f "${file}" ]; then
    echo applying user patch: "${file}";
    git apply --ignore-whitespace "${file}"
    if [ $? -ne 0 ]; then
      echo failed to apply patch "${file}" 1>&2
    fi
  fi
done

set -x

if [[ "${OS_NAME}" == "osx" ]]; then
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile
  yarn postinstall
elif [[ "${npm_config_arch}" == "armv7l" || "${npm_config_arch}" == "ia32" ]]; then
  # node-gyp@9.0.0 shipped with node@16.15.0 starts using config.gypi
  # from the custom headers path if dist-url option was set instead of
  # using the config value from the process. Electron builds with pointer compression
  # enabled for x64 and arm64, but incorrectly ships a single copy of config.gypi
  # with v8_enable_pointer_compression option always set for all target architectures.
  # We use the force_process_config option to use the config.gypi from the
  # nodejs process executing npm for 32-bit architectures.
  export npm_config_force_process_config="true"
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile
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
serverApplicationName='setpath(["serverApplicationName"]; "codium-server")'
serverDataFolderName='setpath(["serverDataFolderName"]; ".vscodium-server")'
reportIssueUrl='setpath(["reportIssueUrl"]; "https://github.com/VSCodium/vscodium/issues/new")'
licenseUrl='setpath(["licenseUrl"]; "https://github.com/VSCodium/vscodium/blob/master/LICENSE")'

product_json_changes="${checksumFailMoreInfoUrl} | ${tipsAndTricksUrl} | ${twitterUrl} | ${requestFeatureUrl} | ${documentationUrl} | ${introductoryVideosUrl} | ${updateUrl} | ${releaseNotesUrl} | ${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${linkProtectionTrustedDomains} | ${nameShort} | ${nameLong} | ${linuxIconName} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${serverApplicationName} | ${serverDataFolderName} | ${reportIssueUrl} | ${licenseUrl}"
cat product.json.bak | jq "${product_json_changes}" > product.json.tmp

jq -s '.[0] * .[1]' product.json.tmp ../product.json > product.json
rm -f product.json.tmp

cat product.json

mv package.json package.json.bak
package_json_changes="setpath(["\""version"\""]; "\""${RELEASE_VERSION}"\"")"
cat package.json.bak | jq "${package_json_changes}" > package.json
gsed -i -E 's/"version": "(.*)\.([0-9]+)"/"version": "\1+\2"/' package.json

../undo_telemetry.sh

if [[ "${OS_NAME}" == "linux" ]]; then
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
