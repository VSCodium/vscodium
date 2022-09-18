#!/bin/bash

set -e

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  VERSIONS=$( curl --silent https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/v/VSCodium/VSCodium/Insiders )

  RELEASE_VERSION="${RELEASE_VERSION/\-insider/}"
else
  VERSIONS=$( curl --silent https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/v/VSCodium/VSCodium )
fi

WINGET_VERSION=$( echo "${VERSIONS}" | jq -r 'map(.name) | last' )

echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
echo "WINGET_VERSION=\"${WINGET_VERSION}\""

if [[ "${RELEASE_VERSION}" == "${WINGET_VERSION}" ]]; then
  export SHOULD_DEPLOY="no"
else
  export SHOULD_DEPLOY="yes"
fi

if [[ "${GITHUB_ENV}" ]]; then
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
	echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}" >> "${GITHUB_ENV}"
fi
