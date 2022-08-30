#!/bin/bash

set -e

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory /__w/vscodium/vscodium
fi

if [[ -z "${RELEASE_VERSION}" ]]; then
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    if [[ "${VSCODE_LATEST}" == "yes" ]] || [[ ! -f "insider.json" ]]; then
      UPDATE_INFO=$( curl https://update.code.visualstudio.com/api/update/darwin/insider/lol )
    else
      export MS_COMMIT=$(jq -r '.commit' insider.json)
      export MS_TAG=$(jq -r '.tag' insider.json)
    fi
  else
    UPDATE_INFO=$( curl https://update.code.visualstudio.com/api/update/darwin/stable/lol )
  fi

  if [[ -z "${MS_COMMIT}" ]]; then
    export MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' )
    export MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' )
  fi

  date=$( date +%Y%j )

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    export RELEASE_VERSION="${MS_TAG/\-insider/}.${date: -5}-insider"
  else
    export RELEASE_VERSION="${MS_TAG}.${date: -5}"
  fi
else
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+-insider$ ]];
    then
      MS_TAG="${BASH_REMATCH[1]}"
    else
      echo "Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi

    if [[ "${MS_TAG}" == "$(jq -r '.tag' insider.json)" ]]; then
      export MS_COMMIT=$(jq -r '.commit' insider.json)
    else
      echo "No MS_COMMIT for ${RELEASE_VERSION}"
      exit 1
    fi
  else
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+$ ]];
    then
      MS_TAG="${BASH_REMATCH[1]}"
    else
      echo "Bad RELEASE_VERSION: ${RELEASE_VERSION}"
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
    UPDATE_INFO=$( curl https://update.code.visualstudio.com/api/update/darwin/insider/lol )
  else
    UPDATE_INFO=$( curl https://update.code.visualstudio.com/api/update/darwin/stable/lol )
  fi
  export MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' )
  export MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' )
elif [[ -z "${MS_COMMIT}" ]]; then
  reference=$( git ls-remote --tags | grep -x ".*refs\/tags\/${MS_TAG}" | head -1 )

  if [[ -z "${reference}" ]]; then
    echo "The following tag can't be found: ${MS_TAG}"
    exit 1
  elif [[ "${reference}" =~ ^([[:alnum:]]+)[[:space:]]+refs\/tags\/([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    export MS_COMMIT="${BASH_REMATCH[1]}"
    export MS_TAG="${BASH_REMATCH[2]}"
  else
    echo "The following reference can't be parsed: ${reference}"
    exit 1
  fi
fi

echo "MS_TAG=\"${MS_TAG}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""

git fetch --depth 1 origin "${MS_COMMIT}"
git checkout FETCH_HEAD

cd ..

# for GH actions
if [[ ${GITHUB_ENV} ]]; then
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
fi

. version.sh
