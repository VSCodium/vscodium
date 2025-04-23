#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

if [[ "${SHOULD_BUILD}" != "yes" ]]; then
  echo "Will not update version JSON because we did not build"
  exit 0
fi

jsonTmp=$( cat "./upstream/${VSCODE_QUALITY}.json" | jq --arg 'tag' "${MS_TAG/\-insider/}" --arg 'commit' "${MS_COMMIT}" '. | .tag=$tag | .commit=$commit' )
echo "${jsonTmp}" > "./upstream/${VSCODE_QUALITY}.json" && unset jsonTmp

# stage notary files
git add upstream/*

# discard changed files
git restore .

CHANGES=$( git status --porcelain )

if [[ -n "${CHANGES}" ]]; then
  git commit -S -m "build(${VSCODE_QUALITY}): update to commit ${MS_COMMIT:0:7}"

  BRANCH_NAME=$( git rev-parse --abbrev-ref HEAD )

  if ! git push origin "${BRANCH_NAME}" --quiet; then
    git pull origin "${BRANCH_NAME}"
    git push origin "${BRANCH_NAME}" --quiet
  fi
fi
