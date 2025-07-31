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

# Check for patch rebuild (repository dispatch with special payload)
if [[ "${GITHUB_EVENT_NAME}" == "repository_dispatch" ]]; then
  echo "Repository dispatch event detected"

  # Check if this is a patch rebuild
  PATCH_REBUILD=$(echo "$GITHUB_EVENT_CLIENT_PAYLOAD" | jq -r '.patch_rebuild // "false"')
  FORCE_BUILD=$(echo "$GITHUB_EVENT_CLIENT_PAYLOAD" | jq -r '.force_build // "false"')
  BUILD_REASON=$(echo "$GITHUB_EVENT_CLIENT_PAYLOAD" | jq -r '.build_reason // ""')

  if [[ "${PATCH_REBUILD}" == "true" ]] || [[ "${FORCE_BUILD}" == "true" ]]; then
    echo "🔥 PATCH REBUILD DETECTED 🔥"
    echo "Reason: ${BUILD_REASON}"

    export SHOULD_BUILD="yes"
    export SHOULD_DEPLOY="yes"
    export PATCH_REBUILD="true"
    export BUILD_REASON="${BUILD_REASON}"

    # Use custom version if provided
    CUSTOM_VERSION=$(echo "$GITHUB_EVENT_CLIENT_PAYLOAD" | jq -r '.release_version // ""')
    if [[ -n "${CUSTOM_VERSION}" && "${CUSTOM_VERSION}" != "null" ]]; then
      export CUSTOM_RELEASE_VERSION="${CUSTOM_VERSION}"
      echo "Using custom version: ${CUSTOM_RELEASE_VERSION}"
    fi
  fi
fi

if [[ "${GITHUB_ENV}" ]]; then
  echo "GITHUB_BRANCH=${GITHUB_BRANCH}" >>"${GITHUB_ENV}"
  echo "SHOULD_BUILD=${SHOULD_BUILD}" >>"${GITHUB_ENV}"
  echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}" >>"${GITHUB_ENV}"
  echo "VSCODE_QUALITY=${VSCODE_QUALITY}" >>"${GITHUB_ENV}"

  # Add patch rebuild variables if they exist
  if [[ -n "${PATCH_REBUILD}" ]]; then
    echo "PATCH_REBUILD=${PATCH_REBUILD}" >>"${GITHUB_ENV}"
  fi
  if [[ -n "${BUILD_REASON}" ]]; then
    echo "BUILD_REASON=${BUILD_REASON}" >>"${GITHUB_ENV}"
  fi
  if [[ -n "${CUSTOM_RELEASE_VERSION}" ]]; then
    echo "CUSTOM_RELEASE_VERSION=${CUSTOM_RELEASE_VERSION}" >>"${GITHUB_ENV}"
  fi
fi
