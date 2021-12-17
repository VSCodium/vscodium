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

  sudo apt install curl jq

  sudo curl -sS --unix-socket /run/snapd.socket http://localhost/v2/find\?q\=codium > snap_latest.json
  SNAP_VERSION=$(jq -r '.result|map(select(.id == "lIZWXTqmo6LFSts5Cgk2VPlNwtysZAeH"))|.version' snap_latest.json)
  echo "Snap version: ${SNAP_VERSION}"

  wget --quiet https://api.github.com/repos/VSCodium/vscodium/releases -O gh_latest.json
  GH_VERSION=$(jq -r 'sort_by(.tag_name)|last.tag_name' gh_latest.json)
  echo "GH version: ${GH_VERSION}"

  if [[ "${SNAP_VERSION}" == "${GH_VERSION}" ]]; then
    export SHOULD_DEPLOY="no"
  else
	  export SHOULD_DEPLOY="yes"
  fi
fi

if [[ $GITHUB_ENV ]]; then
	echo "SHOULD_DEPLOY=$SHOULD_DEPLOY" >> $GITHUB_ENV
fi
