#!/usr/bin/env bash

set -e

VERSIONS=$( curl --silent "https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/v/${APP_IDENTIFIER//.//}" )

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  RELEASE_VERSION="${RELEASE_VERSION/\-insider/}"
fi

WINGET_VERSION=$( echo "${VERSIONS}" | jq -r 'map(select(.name | startswith("1."))) | map(.name) | last' )

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
