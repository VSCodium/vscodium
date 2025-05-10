#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e

# include common functions
. ./utils.sh

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

../update_settings.sh

# apply patches
{ set +x; } 2>/dev/null

echo "APP_NAME=\"${APP_NAME}\""
echo "APP_NAME_LC=\"${APP_NAME_LC}\""
echo "BINARY_NAME=\"${BINARY_NAME}\""
echo "GH_REPO_PATH=\"${GH_REPO_PATH}\""
echo "ORG_NAME=\"${ORG_NAME}\""

for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  for file in ../patches/insider/*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

if [[ -d "../patches/${OS_NAME}/" ]]; then
  for file in "../patches/${OS_NAME}/"*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

for file in ../patches/user/*.patch; do
  if [[ -f "${file}" ]]; then
    apply_patch "${file}"
  fi
done

set -x

export ELECTRON_SKIP_BINARY_DOWNLOAD=1
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

if [[ "${OS_NAME}" == "linux" ]]; then
  export VSCODE_SKIP_NODE_VERSION_CHECK=1

   if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi
elif [[ "${OS_NAME}" == "windows" ]]; then
  if [[ "${npm_config_arch}" == "arm" ]]; then
    export npm_config_arm_version=7
  fi
else
  if [[ "${CI_BUILD}" != "no" ]]; then
    clang++ --version
  fi
fi

mv .npmrc .npmrc.bak
cp ../npmrc .npmrc

for i in {1..5}; do # try 5 times
  if [[ "${CI_BUILD}" != "no" && "${OS_NAME}" == "osx" ]]; then
    CXX=clang++ npm ci && break
  else
    npm ci && break
  fi

  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."

  sleep $(( 15 * (i + 1)))
done

mv .npmrc.bak .npmrc

setpath() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'path' "${2}" --arg 'value' "${3}" 'setpath([$path]; $value)' "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath_json() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'path' "${2}" --argjson 'value' "${3}" 'setpath([$path]; $value)' "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

# product.json
cp product.json{,.bak}

setpath "product" "checksumFailMoreInfoUrl" "https://go.microsoft.com/fwlink/?LinkId=828886"
setpath "product" "documentationUrl" "https://go.microsoft.com/fwlink/?LinkID=533484#vscode"
setpath_json "product" "extensionsGallery" '{"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item", "extensionUrlTemplate": "https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest", "controlUrl": "https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json"}'
setpath "product" "introductoryVideosUrl" "https://go.microsoft.com/fwlink/?linkid=832146"
setpath "product" "keyboardShortcutsUrlLinux" "https://go.microsoft.com/fwlink/?linkid=832144"
setpath "product" "keyboardShortcutsUrlMac" "https://go.microsoft.com/fwlink/?linkid=832143"
setpath "product" "keyboardShortcutsUrlWin" "https://go.microsoft.com/fwlink/?linkid=832145"
setpath "product" "licenseUrl" "https://github.com/BiblioNexus-Foundation/codex/blob/master/LICENSE"
setpath "product" "licenseUrl" "https://github.com/BiblioNexus-Foundation/codex/blob/master/LICENSE"
setpath_json "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "releaseNotesUrl" "https://go.microsoft.com/fwlink/?LinkID=533483#vscode"
setpath "product" "reportIssueUrl" "https://github.com/BiblioNexus-Foundation/codex/issues/new"
setpath "product" "reportIssueUrl" "https://github.com/BiblioNexus-Foundation/codex/issues/new"
setpath "product" "requestFeatureUrl" "https://go.microsoft.com/fwlink/?LinkID=533482"
setpath "product" "tipsAndTricksUrl" "https://go.microsoft.com/fwlink/?linkid=852118"
setpath "product" "twitterUrl" "https://go.microsoft.com/fwlink/?LinkID=533687"

if [[ "${DISABLE_UPDATE}" != "yes" ]]; then
  setpath "product" "updateUrl" "https://raw.githubusercontent.com/BiblioNexus-Foundation/versions/refs/heads/master"

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    setpath "product" "downloadUrl" "https://github.com/BiblioNexus-Foundation/codex-insiders/releases"
  else
    setpath "product" "downloadUrl" "https://github.com/BiblioNexus-Foundation/codex/releases"
  fi
fi

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "product" "nameShort" "Codex - Insiders"
  setpath "product" "nameLong" "Codex - Insiders"
  setpath "product" "applicationName" "codex-insiders"
  setpath "product" "dataFolderName" ".codex-insiders"
  setpath "product" "linuxIconName" "codex-insiders"
  setpath "product" "nameShort" "Codex - Insiders"
  setpath "product" "nameLong" "Codex - Insiders"
  setpath "product" "applicationName" "codex-insiders"
  setpath "product" "dataFolderName" ".codex-insiders"
  setpath "product" "linuxIconName" "codex-insiders"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "codex-insiders"
  setpath "product" "serverApplicationName" "codex-server-insiders"
  setpath "product" "serverDataFolderName" ".codex-server-insiders"
  setpath "product" "darwinBundleIdentifier" "com.codex.CodexInsiders"
  setpath "product" "win32AppUserModelId" "Codex.CodexInsiders"
  setpath "product" "win32DirName" "Codex Insiders"
  setpath "product" "win32MutexName" "codexinsiders"
  setpath "product" "win32NameVersion" "Codex Insiders"
  setpath "product" "win32RegValueName" "CodexInsiders"
  setpath "product" "win32ShellNameShort" "Codex Insiders"
  setpath "product" "urlProtocol" "codex-insiders"
  setpath "product" "serverApplicationName" "codex-server-insiders"
  setpath "product" "serverDataFolderName" ".codex-server-insiders"
  setpath "product" "darwinBundleIdentifier" "com.codex.CodexInsiders"
  setpath "product" "win32AppUserModelId" "Codex.CodexInsiders"
  setpath "product" "win32DirName" "Codex Insiders"
  setpath "product" "win32MutexName" "codexinsiders"
  setpath "product" "win32NameVersion" "Codex Insiders"
  setpath "product" "win32RegValueName" "CodexInsiders"
  setpath "product" "win32ShellNameShort" "Codex Insiders"
  setpath "product" "win32AppId" "{{EF35BB36-FA7E-4BB9-B7DA-D1E09F2DA9C9}"
  setpath "product" "win32x64AppId" "{{B2E0DDB2-120E-4D34-9F7E-8C688FF839A2}"
  setpath "product" "win32arm64AppId" "{{44721278-64C6-4513-BC45-D48E07830599}"
  setpath "product" "win32UserAppId" "{{ED2E5618-3E7E-4888-BF3C-A6CCC84F586F}"
  setpath "product" "win32x64UserAppId" "{{20F79D0D-A9AC-4220-9A81-CE675FFB6B41}"
  setpath "product" "win32arm64UserAppId" "{{2E362F92-14EA-455A-9ABD-3E656BBBFE71}"
  setpath "product" "tunnelApplicationName" "codex-tunnel-insiders"
  setpath "product" "win32TunnelServiceMutex" "codexinsiders-tunnelservice"
  setpath "product" "win32TunnelMutex" "codexinsiders-tunnel"
else
  setpath "product" "nameShort" "Codex"
  setpath "product" "nameLong" "Codex"
  setpath "product" "applicationName" "codex"
  setpath "product" "linuxIconName" "codex"
  setpath "product" "quality" "stable"
  setpath "product" "urlProtocol" "codex"
  setpath "product" "serverApplicationName" "codex-server"
  setpath "product" "serverDataFolderName" ".codex-server"
  setpath "product" "darwinBundleIdentifier" "com.codex"
  setpath "product" "win32AppUserModelId" "Codex.Codex"
  setpath "product" "win32DirName" "Codex"
  setpath "product" "win32MutexName" "codex"
  setpath "product" "win32NameVersion" "Codex"
  setpath "product" "win32RegValueName" "Codex"
  setpath "product" "win32ShellNameShort" "Codex"
  setpath "product" "urlProtocol" "codex"
  setpath "product" "serverApplicationName" "codex-server"
  setpath "product" "serverDataFolderName" ".codex-server"
  setpath "product" "darwinBundleIdentifier" "com.codex"
  setpath "product" "win32AppUserModelId" "Codex.Codex"
  setpath "product" "win32DirName" "Codex"
  setpath "product" "win32MutexName" "codex"
  setpath "product" "win32NameVersion" "Codex"
  setpath "product" "win32RegValueName" "Codex"
  setpath "product" "win32ShellNameShort" "Codex"
  setpath "product" "win32AppId" "{{763CBF88-25C6-4B10-952F-326AE657F16B}"
  setpath "product" "win32x64AppId" "{{88DA3577-054F-4CA1-8122-7D820494CFFB}"
  setpath "product" "win32arm64AppId" "{{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}"
  setpath "product" "win32UserAppId" "{{0FD05EB4-651E-4E78-A062-515204B47A3A}"
  setpath "product" "win32x64UserAppId" "{{2E1F05D1-C245-4562-81EE-28188DB6FD17}"
  setpath "product" "win32arm64UserAppId" "{{57FD70A5-1B8D-4875-9F40-C5553F094828}"
  setpath "product" "tunnelApplicationName" "codex-tunnel"
  setpath "product" "win32TunnelServiceMutex" "codex-tunnelservice"
  setpath "product" "win32TunnelMutex" "codex-tunnel"
fi

jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

cat product.json

# package.json
cp package.json{,.bak}

setpath "package" "version" "${RELEASE_VERSION%-insider}"

replace 's|Microsoft Corporation|Codex|' package.json

cp resources/server/manifest.json{,.bak}

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "resources/server/manifest" "name" "Codex - Insiders"
  setpath "resources/server/manifest" "short_name" "Codex - Insiders"
else
  setpath "resources/server/manifest" "name" "Codex"
  setpath "resources/server/manifest" "short_name" "Codex"
fi

# announcements
replace "s|\\[\\/\\* BUILTIN_ANNOUNCEMENTS \\*\\/\\]|$( tr -d '\n' < ../announcements-builtin.json )|" src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts

../undo_telemetry.sh

replace 's|Microsoft Corporation|Codex|' build/lib/electron.js
replace 's|Microsoft Corporation|Codex|' build/lib/electron.ts
replace 's|([0-9]) Microsoft|\1 Codex|' build/lib/electron.js
replace 's|([0-9]) Microsoft|\1 Codex|' build/lib/electron.ts
replace 's|Microsoft Corporation|Codex|' build/lib/electron.js
replace 's|Microsoft Corporation|Codex|' build/lib/electron.ts
replace 's|([0-9]) Microsoft|\1 Codex|' build/lib/electron.js
replace 's|([0-9]) Microsoft|\1 Codex|' build/lib/electron.ts

if [[ "${OS_NAME}" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to codex
  # as we are renaming the application to codex
  # we need to edit a line in the post install template
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i "s/code-oss/codex-insiders/" resources/linux/debian/postinst.template
    sed -i "s/code-oss/codex-insiders/" resources/linux/debian/postinst.template
  else
    sed -i "s/code-oss/codex/" resources/linux/debian/postinst.template
    sed -i "s/code-oss/codex/" resources/linux/debian/postinst.template
  fi

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|Codex|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/BiblioNexus-Foundation/codex#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://codex.com/img/codex.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://codex.com|' resources/linux/code.appdata.xml
  sed -i 's|Visual Studio Code|Codex|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/BiblioNexus-Foundation/codex#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://codex.com/img/codex.png|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://codex.com|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|Codex Team https://github.com/BiblioNexus-Foundation/codex/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|Codex|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/BiblioNexus-Foundation/codex#download-install|' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://codex.com|' resources/linux/debian/control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|Codex Team https://github.com/BiblioNexus-Foundation/codex/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|Codex|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/BiblioNexus-Foundation/codex#download-install|' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://codex.com|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|Microsoft Corporation|Codex Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|Codex Team https://github.com/BiblioNexus-Foundation/codex/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|Codex|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/BiblioNexus-Foundation/codex#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://codex.com|' resources/linux/rpm/code.spec.template
  sed -i 's|Microsoft Corporation|Codex Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|Codex Team https://github.com/BiblioNexus-Foundation/codex/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|Codex|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/BiblioNexus-Foundation/codex#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://codex.com|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|Codex|'  resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|Codex|'  resources/linux/rpm/code.spec.template
elif [[ "${OS_NAME}" == "windows" ]]; then
  # code.iss
  sed -i 's|https://code.visualstudio.com|https://codex.com|' build/win32/code.iss
  sed -i 's|Microsoft Corporation|Codex|' build/win32/code.iss
  sed -i 's|https://code.visualstudio.com|https://codex.com|' build/win32/code.iss
  sed -i 's|Microsoft Corporation|Codex|' build/win32/code.iss
fi

cd ..
