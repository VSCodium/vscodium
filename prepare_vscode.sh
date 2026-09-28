#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  cp -rp src/insider/* vscode/
else
  cp -rp src/stable/* vscode/
fi

cp -f LICENSE vscode/LICENSE.txt

cd vscode || { echo "'vscode' dir not found"; exit 1; }

{ set +x; } 2>/dev/null

# {{{ product.json
cp product.json{,.bak}

setpath() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --arg 'value' "${3}" "setpath(path(.${2}); \$value)" "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath_json() {
  local jsonTmp
  { set +x; } 2>/dev/null
  jsonTmp=$( jq --argjson 'value' "${3}" "setpath(path(.${2}); \$value)" "${1}.json" )
  echo "${jsonTmp}" > "${1}.json"
  set -x
}

setpath "product" "checksumFailMoreInfoUrl" "https://go.microsoft.com/fwlink/?LinkId=828886"
setpath "product" "documentationUrl" "https://code.visualstudio.com/docs"
setpath_json "product" "extensionsGallery" '{"serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item", "latestUrlTemplate": "https://open-vsx.org/vscode/gallery/{publisher}/{name}/latest", "controlUrl": "https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json"}'

setpath "product" "keyboardShortcutsUrlLinux" "https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf"
setpath "product" "keyboardShortcutsUrlMac" "https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf"
setpath "product" "keyboardShortcutsUrlWin" "https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf"
setpath "product" "licenseUrl" "https://github.com/rockie/vslight/blob/master/LICENSE"
setpath_json "product" "linkProtectionTrustedDomains" '["https://open-vsx.org"]'
setpath "product" "releaseNotesUrl" "https://github.com/rockie/vslight/releases"
setpath "product" "reportIssueUrl" "https://github.com/rockie/vslight/issues/new"

if [[ "${DISABLE_UPDATE}" != "yes" ]]; then
  setpath "product" "updateUrl" "https://raw.githubusercontent.com/rockie/vslight/refs/heads/versions"

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    setpath "product" "downloadUrl" "https://github.com/rockie/vslight-insiders/releases"
  else
    setpath "product" "downloadUrl" "https://github.com/rockie/vslight/releases"
  fi
fi

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "product" "nameShort" "VSLight - Insiders"
  setpath "product" "nameLong" "VSLight - Insiders"
  setpath "product" "applicationName" "vslight-insiders"
  setpath "product" "dataFolderName" ".vslight-insiders"
  setpath "product" "linuxIconName" "vslight-insiders"
  setpath "product" "quality" "insider"
  setpath "product" "urlProtocol" "vslight-insiders"
  setpath "product" "darwinBundleIdentifier" "com.vslight.VSLightInsiders"
  setpath "product" "sharedDataFolderName" ".vslight-insiders-shared"
  setpath "product" "win32AppUserModelId" "VSLight.VSLightInsiders"
  setpath "product" "win32DirName" "VSLight Insiders"
  setpath "product" "win32MutexName" "vslightinsiders"
  setpath "product" "win32NameVersion" "VSLight Insiders"
  setpath "product" "win32RegValueName" "VSLightInsiders"
  setpath "product" "win32ShellNameShort" "VSLight Insiders"
  setpath "product" "win32AppId" "{{086A68B5-11FB-4A53-B581-00B085E0C26D}"
  setpath "product" "win32x64AppId" "{{1ADD66A1-D56B-4D29-8784-B4F1159AA17D}"
  setpath "product" "win32arm64AppId" "{{35E6F2F5-1819-4059-821A-71B4792483E5}"
  setpath "product" "win32UserAppId" "{{542F10DC-7068-4EB9-A635-8FC7C64B47E1}"
  setpath "product" "win32x64UserAppId" "{{7A251FF6-AE7A-4EFF-A668-7F28E584D8E2}"
  setpath "product" "win32arm64UserAppId" "{{1C8C6787-818A-4A15-B57A-226942EA1330}"
  setpath "product" "win32ContextMenu.x64.clsid" "90AAD229-85FD-43A3-B82D-8598A88829CF"
  setpath "product" "win32ContextMenu.arm64.clsid" "7544C31C-BDBF-4DDF-B15E-F73A46D6723D"
else
  setpath "product" "nameShort" "VSLight"
  setpath "product" "nameLong" "VSLight"
  setpath "product" "applicationName" "vslight"
  setpath "product" "dataFolderName" ".vslight"
  setpath "product" "linuxIconName" "vslight"
  setpath "product" "quality" "stable"
  setpath "product" "urlProtocol" "vslight"
  setpath "product" "darwinBundleIdentifier" "com.vslight"
  setpath "product" "sharedDataFolderName" ".vslight-shared"
  setpath "product" "win32AppUserModelId" "VSLight.VSLight"
  setpath "product" "win32DirName" "VSLight"
  setpath "product" "win32MutexName" "vslight"
  setpath "product" "win32NameVersion" "VSLight"
  setpath "product" "win32RegValueName" "VSLight"
  setpath "product" "win32ShellNameShort" "VSLight"
  setpath "product" "win32AppId" "{{086A68B5-11FB-4A53-B581-00B085E0C26D}"
  setpath "product" "win32x64AppId" "{{1ADD66A1-D56B-4D29-8784-B4F1159AA17D}"
  setpath "product" "win32arm64AppId" "{{35E6F2F5-1819-4059-821A-71B4792483E5}"
  setpath "product" "win32UserAppId" "{{542F10DC-7068-4EB9-A635-8FC7C64B47E1}"
  setpath "product" "win32x64UserAppId" "{{7A251FF6-AE7A-4EFF-A668-7F28E584D8E2}"
  setpath "product" "win32arm64UserAppId" "{{1C8C6787-818A-4A15-B57A-226942EA1330}"
  setpath "product" "win32ContextMenu.x64.clsid" "D910D5E6-B277-4F4A-BDC5-759A34EEE25D"
  setpath "product" "win32ContextMenu.arm64.clsid" "4852FC55-4A84-4EA1-9C86-D53BE3DF83C0"
fi

jsonTmp=$( jq -s '.[0] * .[1]' product.json ../product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

# vslight: key-level deletion (merge has no delete semantics) — server/tunnel/sessions
# are not part of this product; readers of these keys are nil-safe (checked at 1.135)
jsonTmp=$( jq 'del(
  .serverApplicationName,
  .serverDataFolderName,
  .tunnelApplicationName,
  .tunnelApplicationConfig,
  .win32TunnelServiceMutex,
  .win32TunnelMutex,
  .sessionsWindowAllowedExtensions
)' product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

cat product.json
# }}}

# include common functions
. ../utils.sh

# {{{ apply patches

echo "APP_NAME=\"${APP_NAME}\""
echo "APP_NAME_LC=\"${APP_NAME_LC}\""
echo "ASSETS_REPOSITORY=\"${ASSETS_REPOSITORY}\""
echo "BINARY_NAME=\"${BINARY_NAME}\""
echo "GH_REPO_PATH=\"${GH_REPO_PATH}\""
echo "GLOBAL_DIRNAME=\"${GLOBAL_DIRNAME}\""
echo "ORG_NAME=\"${ORG_NAME}\""
echo "TUNNEL_APP_NAME=\"${TUNNEL_APP_NAME}\""

if [[ "${DISABLE_UPDATE}" == "yes" ]]; then
  apply_patch ../patches/00-update-disable.patch.yet
fi

for file in ../patches/*.json; do
  if [[ -f "${file}" ]]; then
    apply_actions "${file}"
  fi
done

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
# }}}

# {{{ vslight light-prune — must run AFTER all patches (docs/vslight-plan.md §1.3-a;
# audit: dev/progress/audit-remove-patch.md). apply_actions exits 4 on missing paths.
for file in ../patches/light/*.json; do
  if [[ -f "${file}" ]]; then
    echo "light-prune: ${file}"
    apply_actions "${file}"
  fi
done
# }}}

set -x

# {{{ install dependencies
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

node build/npm/preinstall.ts

mv .npmrc .npmrc.bak
cp ../npmrc .npmrc

for i in {1..5}; do # try 5 times
  if [[ "${CI_BUILD}" != "no" && "${OS_NAME}" == "osx" ]]; then
    CXX=clang++ npm ci && break
  else
    npm ci && break
  fi

  if [[ $i == 5 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."

  sleep $(( 15 * (i + 1)))
done

mv .npmrc.bak .npmrc
# }}}

# package.json
cp package.json{,.bak}

setpath "package" "version" "${RELEASE_VERSION%-insider}"

replace 's|Microsoft Corporation|VSLight|' package.json
replace "s|--max-old-space-size=8192|--max-old-space-size=${MAX_OLD_SPACE_SIZE}|" package.json

cp resources/server/manifest.json{,.bak}

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  setpath "resources/server/manifest" "name" "VSLight - Insiders"
  setpath "resources/server/manifest" "short_name" "VSLight - Insiders"
else
  setpath "resources/server/manifest" "name" "VSLight"
  setpath "resources/server/manifest" "short_name" "VSLight"
fi

# announcements
replace "s|\\[\\/\\* BUILTIN_ANNOUNCEMENTS \\*\\/\\]|$( tr -d '\n' < ../announcements-builtin.json )|" src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts

../undo_telemetry.sh

replace 's|Microsoft Corporation|VSLight|' build/lib/electron.ts
replace 's|([0-9]) Microsoft|\1 VSLight|' build/lib/electron.ts

if [[ "${OS_NAME}" == "linux" ]]; then
  # microsoft adds their apt repo to sources
  # unless the app name is code-oss
  # as we are renaming the application to vslight
  # we need to edit a line in the post install template
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i "s/code-oss/vslight-insiders/" resources/linux/debian/postinst.template
  else
    sed -i "s/code-oss/vslight/" resources/linux/debian/postinst.template
  fi

  # fix the packages metadata
  # code.appdata.xml
  sed -i 's|Visual Studio Code|VSLight|g' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/rockie/vslight#download-install|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com/home/home-screenshot-linux-lg.png|https://github.com/rockie/vslight|' resources/linux/code.appdata.xml
  sed -i 's|https://code.visualstudio.com|https://github.com/rockie/vslight|' resources/linux/code.appdata.xml

  # control.template
  sed -i 's|Microsoft Corporation <vscode-linux@microsoft.com>|VSLight Team https://github.com/rockie/vslight/graphs/contributors|'  resources/linux/debian/control.template
  sed -i 's|Visual Studio Code|VSLight|g' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/rockie/vslight#download-install|' resources/linux/debian/control.template
  sed -i 's|https://code.visualstudio.com|https://github.com/rockie/vslight|' resources/linux/debian/control.template

  # code.spec.template
  sed -i 's|Microsoft Corporation|VSLight Team|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code Team <vscode-linux@microsoft.com>|VSLight Team https://github.com/rockie/vslight/graphs/contributors|' resources/linux/rpm/code.spec.template
  sed -i 's|Visual Studio Code|VSLight|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com/docs/setup/linux|https://github.com/rockie/vslight#download-install|' resources/linux/rpm/code.spec.template
  sed -i 's|https://code.visualstudio.com|https://github.com/rockie/vslight|' resources/linux/rpm/code.spec.template

  # snapcraft.yaml
  sed -i 's|Visual Studio Code|VSLight|' resources/linux/rpm/code.spec.template
elif [[ "${OS_NAME}" == "windows" ]]; then
  # code.iss
  sed -i 's|https://code.visualstudio.com|https://github.com/rockie/vslight|' build/win32/code.iss
  sed -i 's|Microsoft Corporation|VSLight|' build/win32/code.iss
fi

cd ..
