#!/usr/bin/env bash

set -e

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
fi

if [[ -z "${RELEASE_VERSION}" ]]; then
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    if [[ "${VSCODE_LATEST}" == "yes" ]] || [[ ! -f "insider.json" ]]; then
      UPDATE_INFO=$( curl --silent --fail https://update.code.visualstudio.com/api/update/darwin/insider/0000000000000000000000000000000000000000 )
    else
      MS_COMMIT=$(jq -r '.commit' insider.json); export MS_COMMIT
      MS_TAG=$(jq -r '.tag' insider.json); export MS_TAG
    fi
  else
    UPDATE_INFO=$( curl --silent --fail https://update.code.visualstudio.com/api/update/darwin/stable/0000000000000000000000000000000000000000 )
  fi

  if [[ -z "${MS_COMMIT}" ]]; then
    MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' ); export MS_COMMIT
    MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' ); export MS_TAG

    if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
      MS_TAG="${MS_TAG/\-insider/}"; export MS_TAG
    fi
  fi

  date=$( date +%Y%j )

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    RELEASE_VERSION="${MS_TAG}.${date: -5}-insider"; export RELEASE_VERSION
  else
    RELEASE_VERSION="${MS_TAG}.${date: -5}"; export RELEASE_VERSION
  fi
else
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+-insider$ ]];
    then
      MS_TAG="${BASH_REMATCH[1]}"
    else
      echo "Error: Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi

    if [[ "${MS_TAG}" == "$(jq -r '.tag' insider.json)" ]]; then
      MS_COMMIT=$(jq -r '.commit' insider.json); export MS_COMMIT
    else
      echo "Error: No MS_COMMIT for ${RELEASE_VERSION}"
      exit 1
    fi
  else
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+$ ]];
    then
      MS_TAG="${BASH_REMATCH[1]}"
    else
      echo "Error: Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi
  fi
fi

echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""

mkdir -p vscode
cd vscode || { echo "'vscode' dir not found"; exit 1; }

git init -q
git remote add origin https://github.com/Microsoft/vscode.git

# figure out latest tag by calling MS update API
if [[ -z "${MS_TAG}" ]]; then
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    UPDATE_INFO=$( curl --silent --fail https://update.code.visualstudio.com/api/update/darwin/insider/0000000000000000000000000000000000000000 )
  else
    UPDATE_INFO=$( curl --silent --fail https://update.code.visualstudio.com/api/update/darwin/stable/0000000000000000000000000000000000000000 )
  fi
  MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' ); export MS_COMMIT
  MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' ); export MS_TAG
elif [[ -z "${MS_COMMIT}" ]]; then
  REFERENCE=$( git ls-remote --tags | grep -x ".*refs\/tags\/${MS_TAG}" | head -1 )

  if [[ -z "${REFERENCE}" ]]; then
    echo "Error: The following tag can't be found: ${MS_TAG}"
    exit 1
  elif [[ "${REFERENCE}" =~ ^([[:alnum:]]+)[[:space:]]+refs\/tags\/([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    export MS_COMMIT="${BASH_REMATCH[1]}"
    export MS_TAG="${BASH_REMATCH[2]}"
  else
    echo "Error: The following reference can't be parsed: ${REFERENCE}"
    exit 1
  fi
fi

echo "MS_TAG=\"${MS_TAG}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""

git fetch --depth 1 origin "${MS_COMMIT}"
git checkout FETCH_HEAD

cd ..

# for GH actions
[[ "${GITHUB_ENV}" ]] && {
  echo "MS_TAG=${MS_TAG}"
  echo "MS_COMMIT=${MS_COMMIT}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}"; } >> "${GITHUB_ENV}"
