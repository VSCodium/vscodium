#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

if [[ "${SHOULD_BUILD}" != "yes" ]]; then
  echo "Will not update version JSON because we did not build"
  exit 0
fi

if [[ -z "${GH_TOKEN}" ]] && [[ -z "${GITHUB_TOKEN}" ]] && [[ -z "${GH_ENTERPRISE_TOKEN}" ]] && [[ -z "${GITHUB_ENTERPRISE_TOKEN}" ]]; then
  echo "Will not update ${VSCODE_QUALITY}.json because no GITHUB_TOKEN defined"
  exit 0
fi

jsonTmp=$( cat "./upstream/${VSCODE_QUALITY}.json" | jq --arg 'tag' "${MS_TAG/\-insider/}" --arg 'commit' "${MS_COMMIT}" '. | .tag=$tag | .commit=$commit' )
echo "${jsonTmp}" > "./upstream/${VSCODE_QUALITY}.json" && unset jsonTmp

git add .

CHANGES=$( git status --porcelain )

if [[ -n "${CHANGES}" ]]; then
  COMMIT_MESSAGE="build(${VSCODE_QUALITY}): update to commit ${MS_COMMIT:0:7}"
  COMMIT_REF=$( git rev-parse --abbrev-ref HEAD )

  if [[ "${GITHUB_ENV}" ]]; then
    echo "SHOULD_COMMIT=yes" >> "${GITHUB_ENV}"
    echo "COMMIT_MESSAGE=${COMMIT_MESSAGE}" >> "${GITHUB_ENV}"
    echo "COMMIT_REF=${COMMIT_REF}" >> "${GITHUB_ENV}"
  fi
fi
