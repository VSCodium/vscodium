#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

export SHOULD_BUILD="no"
export SHOULD_DEPLOY_TO_RELEASE="no"
export SHOULD_DEPLOY_TO_STORE="no"

# Support for GitHub Enterprise
GH_HOST="${GH_HOST:-github.com}"

if [[ "${GENERATE_ASSETS}" == "true" ]]; then
  export SHOULD_BUILD="yes"
else
  wget --quiet "https://api.${GH_HOST}/repos/${ASSETS_REPOSITORY}/releases" -O gh_latest.json
  SNAP_URL=$( jq -r 'map(select(.tag_name == "'"${RELEASE_VERSION}"'"))|first.assets[].browser_download_url|select(endswith("'"_${ARCHITECTURE}.snap"'"))' gh_latest.json )

  if [[ -z "${SNAP_URL}" ]]; then
    export SHOULD_BUILD="yes"
    export SHOULD_DEPLOY_TO_RELEASE="yes"
  fi

  if [[ "${VSCODE_QUALITY}" == "stable" ]]; then
    CHANNEL="${SNAPCRAFT_STORE_CHANNEL:-stable}"

    sudo snap install --channel "${CHANNEL}" --classic snapcraft

    echo "Architecture: ${ARCHITECTURE}"

    SNAP_VERSION=$( snapcraft list-revisions "${SNAP_NAME}" | grep -F "stable*" | grep "${ARCHITECTURE}" | tr -s ' ' | cut -d ' ' -f 4 )
    echo "Snap version: ${SNAP_VERSION}"

    if [[ -n "${SNAP_VERSION}" && "${SNAP_VERSION}" != "${RELEASE_VERSION}" ]]; then
      export SHOULD_BUILD="yes"
      export SHOULD_DEPLOY_TO_STORE="yes"

      snap version
      snap info "${SNAP_NAME}" || true
    fi
  fi
fi

if [[ "${GITHUB_ENV}" ]]; then
  echo "SHOULD_BUILD=${SHOULD_BUILD}" >> "${GITHUB_ENV}"
  echo "SHOULD_DEPLOY_TO_RELEASE=${SHOULD_DEPLOY_TO_RELEASE}" >> "${GITHUB_ENV}"
	echo "SHOULD_DEPLOY_TO_STORE=${SHOULD_DEPLOY_TO_STORE}" >> "${GITHUB_ENV}"
fi
