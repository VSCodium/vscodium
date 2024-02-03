#!/usr/bin/env bash
# shellcheck disable=SC2129

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
  if [[ "${GENERATE_ASSETS}" == "true" ]]; then
    echo "It will generate the assets"

    export SHOULD_BUILD="yes"
    export SHOULD_DEPLOY="no"
  else
  	echo "It's a Dispatch"

    export SHOULD_DEPLOY="yes"
  fi
else
	echo "It's a Cron"

	export SHOULD_DEPLOY="yes"
fi

if [[ "${GITHUB_ENV}" ]]; then
  echo "GITHUB_BRANCH=${GITHUB_BRANCH}" >> "${GITHUB_ENV}"
  echo "SHOULD_BUILD=${SHOULD_BUILD}" >> "${GITHUB_ENV}"
  echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}" >> "${GITHUB_ENV}"
  echo "VSCODE_QUALITY=${VSCODE_QUALITY}" >> "${GITHUB_ENV}"
fi
