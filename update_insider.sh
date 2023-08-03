#!/usr/bin/env bash

set -e

if [[ "${SHOULD_BUILD}" != "yes" ]]; then
  echo "Will not update version JSON because we did not build"
  exit 0
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not update insider.json because no GITHUB_TOKEN defined"
  exit 0
fi

jsonTmp=$( jq --arg 'tag' "${MS_TAG/\-insider/}" --arg 'commit' "${MS_COMMIT}" '. "insider.json" | .tag=$tag | .commit=$commit' )
echo "${jsonTmp}" > "insider.json" && unset jsonTmp

git config user.email "$( echo "${GITHUB_USERNAME}" | awk '{print tolower($0)}' )-ci@not-real.com"
git config user.name "${GITHUB_USERNAME} CI"
git add .

CHANGES=$( git status --porcelain )

if [[ -n "${CHANGES}" ]]; then
  git commit -m "build(insider): update to commit ${MS_COMMIT:0:7}"

  if ! git push origin insider --quiet; then
    git pull origin insider
    git push origin insider --quiet
  fi
fi
