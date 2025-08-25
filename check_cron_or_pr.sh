#!/usr/bin/env bash
# shellcheck disable=SC2129

set -euo pipefail

echo "GitHub event: ${GITHUB_EVENT_NAME}"

SHOULD_BUILD="no"
SHOULD_DEPLOY="no"

case "${GITHUB_EVENT_NAME}" in
  "pull_request")
    echo "It's a PR"
    SHOULD_BUILD="yes"
    ;;

  "push")
    echo "It's a Push"
    SHOULD_BUILD="yes"
    ;;

  "workflow_dispatch")
    if [[ "${GENERATE_ASSETS:-}" == "true" ]]; then
      echo "It will generate the assets"
      SHOULD_BUILD="yes"
    else
      echo "It's a Dispatch"
      SHOULD_DEPLOY="yes"
    fi
    ;;

  *)
    echo "It's a Cron"
    SHOULD_DEPLOY="yes"
    ;;
esac

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "GITHUB_BRANCH=${GITHUB_BRANCH:-}"
    echo "SHOULD_BUILD=${SHOULD_BUILD}"
    echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}"
    echo "VSCODE_QUALITY=${VSCODE_QUALITY:-}"
  } >> "${GITHUB_ENV}"
fi
