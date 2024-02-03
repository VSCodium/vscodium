#!/usr/bin/env bash

set -e

if [[ "${SHOULD_BUILD}" != "yes" ]]; then
  echo "Will not update version JSON because we did not build"
  exit 0
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not update ${VSCODE_QUALITY}.json because no GITHUB_TOKEN defined"
  exit 0
fi

jsonTmp=$( cat "${VSCODE_QUALITY}.json" | jq --arg 'tag' "${MS_TAG/\-insider/}" --arg 'commit' "${MS_COMMIT}" '. | .tag=$tag | .commit=$commit' )
echo "${jsonTmp}" > "${VSCODE_QUALITY}.json" && unset jsonTmp

git config user.email "$( echo "${GITHUB_USERNAME}" | awk '{print tolower($0)}' )-ci@not-real.com"
git config user.name "${GITHUB_USERNAME} CI"
git add .

CHANGES=$( git status --porcelain )

if [[ -n "${CHANGES}" ]]; then
  git commit -m "build(${VSCODE_QUALITY}): update to commit ${MS_COMMIT:0:7}"

  BRANCH_NAME=$( git rev-parse --abbrev-ref HEAD )

  if ! git push origin "${BRANCH_NAME}" --quiet; then
    git pull origin "${BRANCH_NAME}"
    git push origin "${BRANCH_NAME}" --quiet
  fi
fi
