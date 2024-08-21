#!/usr/bin/env bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

if [[ "${VSCODE_ARCH}" == "x64" ]]; then
  GITHUB_RESPONSE=$( curl --silent --location "https://api.github.com/repos/AppImage/pkg2appimage/releases/latest" )
  APPIMAGE_URL=$( echo "${GITHUB_RESPONSE}" | jq --raw-output '.assets | map(select( .name | test("x86_64.AppImage(?!.zsync)"))) | map(.browser_download_url)[0]' )

  if [[ -z "${APPIMAGE_URL}" ]]; then
    echo "The url for pkg2appimage.AppImage hasn't been found"
    exit 1
  fi

  wget -c "${APPIMAGE_URL}" -O pkg2appimage.AppImage

  chmod +x ./pkg2appimage.AppImage

  ./pkg2appimage.AppImage --appimage-extract && mv ./squashfs-root ./pkg2appimage.AppDir

  # add update's url
  sed -i 's/generate_type2_appimage/generate_type2_appimage -u "gh-releases-zsync|Codex|codex|latest|*.AppImage.zsync"/' pkg2appimage.AppDir/AppRun

  # remove check so build in docker can succeed
  sed -i 's/grep docker/# grep docker/' pkg2appimage.AppDir/usr/share/pkg2appimage/functions.sh

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    sed -i 's|@@NAME@@|Codex-Insiders|g' recipe.yml
    sed -i 's|@@APPNAME@@|codex-insiders|g' recipe.yml
    sed -i 's|@@ICON@@|codex-insiders|g' recipe.yml
  else
    sed -i 's|@@NAME@@|Codex|g' recipe.yml
    sed -i 's|@@APPNAME@@|codex|g' recipe.yml
    sed -i 's|@@ICON@@|codex|g' recipe.yml
  fi

  bash -ex pkg2appimage.AppDir/AppRun recipe.yml

  rm -f pkg2appimage-*.AppImage
  rm -rf pkg2appimage.AppDir
  rm -rf Codex*
fi

cd "${CALLER_DIR}"
