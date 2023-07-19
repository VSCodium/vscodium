#!/usr/bin/env bash

set -e

if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
	echo "It's a PR"

	export SHOULD_BUILD="yes"
	export SHOULD_DEPLOY="no"
elif [[ "${GITHUB_EVENT_NAME}" == "push" ]]; then
	echo "It's a Push"

	export SHOULD_BUILD="yes"
	export SHOULD_DEPLOY="no"
elif [[ "${GITHUB_EVENT_NAME}" == "workflow_dispatch" ]]; then
	echo "It's a Dispatch"

  export SHOULD_DEPLOY="yes"
else
	echo "It's a Cron"

	export SHOULD_DEPLOY="yes"
fi

[[ "${GITHUB_ENV}" ]] && {
  echo "GITHUB_BRANCH=${GITHUB_BRANCH}"
  echo "SHOULD_BUILD=${SHOULD_BUILD}"
  echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}" 
  echo "VSCODE_QUALITY=${VSCODE_QUALITY}"; } >> "${GITHUB_ENV}"
