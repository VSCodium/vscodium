#!/bin/bash

set -e

cp -rp src/* vscode/
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
extensionAllowedProposedApi='setpath(["extensionAllowedProposedApi"]; getpath(["extensionAllowedProposedApi"]) + ["ms-vscode.cpptools", "ms-azuretools.vscode-docker", "visualstudioexptteam.vscodeintellicode", "GitHub.codespaces", "GitHub.vscode-pull-request-github-insiders", "GitHub.vscode-pull-request-github", "Microsoft.vscode-nmake-tools", "ms-ai-tools.notebook-renderers", "ms-dotnettools.dotnet-interactive-vscode", "ms-python.gather", "ms-python.python", "ms-toolsai.jupyter", "ms-toolsai.vscode-ai", "ms-toolsai.vscode-ai-remote", "ms-vscode-remote.remote-containers-nightly", "ms-vscode-remote.remote-containers", "ms-vscode-remote.remote-ssh-edit-nightly", "ms-vscode-remote.remote-ssh-edit", "ms-vscode-remote.remote-ssh-nightly", "ms-vscode-remote.remote-ssh", "ms-vscode-remote.remote-wsl-nightly", "ms-vscode-remote.remote-wsl", "ms-vscode-remote.remote-wsl-recommender", "ms-vscode-remote.vscode-remote-extensionpack-nightly", "ms-vscode-remote.vscode-remote-extensionpack", "ms-vscode.azure-account", "ms-vscode.azure-sphere-tools-ui", "ms-vscode.azure-sphere-tools", "ms-vscode.github-browser", "ms-vscode.github-richnav", "ms-vscode.js-debug-nightly", "ms-vscode.js-debug", "ms-vscode.lsif-browser", "ms-vscode.vscode-js-profile-flame", "ms-vscode.vscode-js-profile-table", "ms-vscode.vscode-selfhost-test-provider", "ms-vsliveshare.cloudenv-explorer", "ms-vsliveshare.cloudenv", "ms-vsliveshare.vsliveshare", "ms-vsonline.vsonline", "dbaeumer.vscode-eslint"])'
serverDataFolderName='setpath(["serverDataFolderName"]; ".vscode-server-oss")'

product_json_changes="${checksumFailMoreInfoUrl} | ${tipsAndTricksUrl} | ${twitterUrl} | ${requestFeatureUrl} | ${documentationUrl} | ${introductoryVideosUrl} | ${extensionAllowedBadgeProviders} | ${updateUrl} | ${releaseNotesUrl} | ${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${linkProtectionTrustedDomains} | ${nameShort} | ${nameLong} | ${linuxIconName} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${extensionAllowedProposedApi} | ${serverDataFolderName}"
cat product.json.bak | jq "${product_json_changes}" > product.json
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
