#!/bin/bash

set -e

# include common functions
. ./utils.sh

if [[ "${INSIDER}" == "yes" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

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

if [[ "${INSIDER}" == "yes" ]]; then
  for file in ../patches/insider/*.patch; do
    if [ -f "${file}" ]; then
      echo applying patch: "${file}";
      git apply --ignore-whitespace "${file}"
      if [ $? -ne 0 ]; then
        echo failed to apply patch "${file}" 1>&2
      fi
    fi
  done
fi

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

cp product.json product.json.bak

setpath() {
  echo "$( cat "${1}.json" | jq --arg 'path' "${2}" --arg 'value' "${3}" 'setpath([$path]; $value)' )" > "${1}.json"
}

setpath_json() {
  echo "$( cat "${1}.json" | jq --arg 'path' "${2}" --argjson 'value' "${3}" 'setpath([$path]; $value)' )" > "${1}.json"
}

# set fields in product.json
setpath "product" "checksumFailMoreInfoUrl" "https://go.microsoft.com/fwlink/?LinkId=828886"
setpath "product" "documentationUrl" "https://go.microsoft.com/fwlink/?LinkID=533484#vscode"
setpath_json "product" "extensionsGallery" '{"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item"}'
setpath "product" "introductoryVideosUrl" "https://go.microsoft.com/fwlink/?linkid=832146"
setpath "product" "keyboardShortcutsUrlLinux" "https://go.microsoft.com/fwlink/?linkid=832144"
setpath "product" "keyboardShortcutsUrlMac" "https://go.microsoft.com/fwlink/?linkid=832143"
setpath "product" "keyboardShortcutsUrlWin" "https://go.microsoft.com/fwlink/?linkid=832145"
setpath "product" "licenseUrl" "https://github.com/VSCodium/vscodium/blob/master/LICENSE"
setpath "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "linuxIconName" "vscodium"
setpath "product" "releaseNotesUrl" "https://go.microsoft.com/fwlink/?LinkID=533483#vscode"
setpath "product" "reportIssueUrl" "https://github.com/VSCodium/vscodium/issues/new"
setpath "product" "requestFeatureUrl" "https://go.microsoft.com/fwlink/?LinkID=533482"
setpath "product" "tipsAndTricksUrl" "https://go.microsoft.com/fwlink/?linkid=852118"
setpath "product" "twitterUrl" "https://go.microsoft.com/fwlink/?LinkID=533687"
setpath "product" "updateUrl" "https://vscodium.now.sh"

if [[ "${INSIDER}" == "yes" ]]; then
  setpath "product" "nameShort" "VSCodium - Insiders"
  setpath "product" "nameLong" "VSCodium - Insiders"
  setpath "product" "applicationName" "codium-insiders"
  setpath "product" "dataFolderName" ".vscodium-insiders"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "vscodium-insiders"
  setpath "product" "serverApplicationName" "codium-server-insiders"
  setpath "product" "serverDataFolderName" ".vscodium-server-insiders"
  setpath "product" "darwinBundleIdentifier" "com.vscodium.VSCodiumInsiders"
  setpath "product" "win32AppUserModelId" "VSCodium.VSCodiumInsiders"
  setpath "product" "win32DirName" "VSCodium Insiders"
  setpath "product" "win32MutexName" "vscodiuminsiders"
  setpath "product" "win32NameVersion" "VSCodium Insiders"
  setpath "product" "win32RegValueName" "VSCodiumInsiders"
  setpath "product" "win32ShellNameShort" "VSCodium Insiders"
  setpath "product" "win32AppId" "{{EF35BB36-FA7E-4BB9-B7DA-D1E09F2DA9C9}"
  setpath "product" "win32x64AppId" "{{B2E0DDB2-120E-4D34-9F7E-8C688FF839A2}"
  setpath "product" "win32arm64AppId" "{{44721278-64C6-4513-BC45-D48E07830599}"
  setpath "product" "win32UserAppId" "{{ED2E5618-3E7E-4888-BF3C-A6CCC84F586F}"
  setpath "product" "win32x64UserAppId" "{{20F79D0D-A9AC-4220-9A81-CE675FFB6B41}"
  setpath "product" "win32arm64UserAppId" "{{2E362F92-14EA-455A-9ABD-3E656BBBFE71}"
else
  setpath "product" "nameShort" "VSCodium"
  setpath "product" "nameLong" "VSCodium"
  setpath "product" "applicationName" "codium"
  setpath "product" "quality" "stable"
  setpath "product" "urlProtocol" "vscodium"
  setpath "product" "serverApplicationName" "codium-server"
  setpath "product" "serverDataFolderName" ".vscodium-server"
  setpath "product" "darwinBundleIdentifier" "com.vscodium"
  setpath "product" "win32AppUserModelId" "VSCodium.VSCodium"
  setpath "product" "win32DirName" "VSCodium"
  setpath "product" "win32MutexName" "vscodium"
  setpath "product" "win32NameVersion" "VSCodium"
  setpath "product" "win32RegValueName" "VSCodium"
  setpath "product" "win32ShellNameShort" "VSCodium"
  setpath "product" "win32AppId" "{{763CBF88-25C6-4B10-952F-326AE657F16B}"
  setpath "product" "win32x64AppId" "{{88DA3577-054F-4CA1-8122-7D820494CFFB}"
  setpath "product" "win32arm64AppId" "{{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}"
  setpath "product" "win32UserAppId" "{{0FD05EB4-651E-4E78-A062-515204B47A3A}"
  setpath "product" "win32x64UserAppId" "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}"
  setpath "product" "win32arm64UserAppId" "{{57FD70A5-1B8D-4875-9F40-C5553F094828}"
fi

echo "$( jq -s '.[0] * .[1]' product.json ../product.json )" > product.json

cat product.json

cp package.json package.json.bak
setpath "package" "version" $( echo "${RELEASE_VERSION}" | sed -n -E "s/^(.*)\.([0-9]+)(-insider)?$/\1/p" )
setpath "package" "release" $( echo "${RELEASE_VERSION}" | sed -n -E "s/^(.*)\.([0-9]+)(-insider)?$/\2/p" )

../undo_telemetry.sh

if [[ "${OS_NAME}" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vscodium
  # we need to edit a line in the post install template
  if [[ "${INSIDER}" == "yes" ]]; then
    sed -i "s/code-oss/codium-insiders/" resources/linux/debian/postinst.template
  else
    sed -i "s/code-oss/codium/" resources/linux/debian/postinst.template
  fi

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
