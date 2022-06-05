#!/bin/bash

set -e

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	echo "It's a PR"

	export SHOULD_DEPLOY="no"
elif [[ "${GITHUB_EVENT_NAME}" == "push" ]]; then
	echo "It's a Push"

	export SHOULD_DEPLOY="no"
else
	echo "It's a cron"

  sudo snap install --channel stable --classic snapcraft

  echo "$SNAP_STORE_LOGIN" | snapcraft login --with -

  echo "Architecture: ${ARCHITECTURE}"

  SNAP_VERSION=$(snapcraft list-revisions codium | grep -F stable* | grep "${ARCHITECTURE}" | tr -s ' ' | cut -d ' ' -f 4)
  echo "Snap version: ${SNAP_VERSION}"

  wget --quiet https://api.github.com/repos/VSCodium/vscodium/releases -O gh_latest.json
  GH_VERSION=$(jq -r 'sort_by(.tag_name)|last.tag_name' gh_latest.json)
  echo "GH version: ${GH_VERSION}"

  rm -f gh_latest.json

  if [[ "${SNAP_VERSION}" == "${GH_VERSION}" ]]; then
    export SHOULD_DEPLOY="no"
  else
	  export SHOULD_DEPLOY="yes"

    snap version
    snap info codium
  fi
fi

if [[ $GITHUB_ENV ]]; then
	echo "SHOULD_DEPLOY=$SHOULD_DEPLOY" >> "$GITHUB_ENV"
fi
