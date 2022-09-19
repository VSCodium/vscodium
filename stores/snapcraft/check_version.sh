#!/bin/bash

set -e

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  REPOSITORY="${GITHUB_REPOSITORY:-"VSCodium/vscodium"}-insiders"
  SNAP_NAME="codium-insiders"
else
  REPOSITORY="${GITHUB_REPOSITORY:-"VSCodium/vscodium"}"
  SNAP_NAME="codium"
fi

sudo snap install --channel stable --classic snapcraft

echo "Architecture: ${ARCHITECTURE}"

SNAP_VERSION=$(snapcraft list-revisions ${SNAP_NAME} | grep -F "stable*" | grep "${ARCHITECTURE}" | tr -s ' ' | cut -d ' ' -f 4)
echo "Snap version: ${SNAP_VERSION}"

wget --quiet "https://api.github.com/repos/${REPOSITORY}/releases" -O gh_latest.json
GH_VERSION=$(jq -r 'sort_by(.tag_name)|last.tag_name' gh_latest.json)
echo "GH version: ${GH_VERSION}"

rm -f gh_latest.json

if [[ "${SNAP_VERSION}" == "${GH_VERSION}" ]]; then
  export SHOULD_DEPLOY="no"
else
  export SHOULD_DEPLOY="yes"

  snap version
  snap info "${SNAP_NAME}" | true
fi

if [[ "${GITHUB_ENV}" ]]; then
	echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}" >> "${GITHUB_ENV}"
fi
