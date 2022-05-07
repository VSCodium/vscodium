#!/bin/bash

set -e

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not release because no GITHUB_TOKEN defined"
  exit
fi

npm install -g github-release-cli

if [[ $( gh release view "${MS_TAG}" 2>&1 ) =~ "release not found" ]]; then
  echo "Creating release '${MS_TAG}'"
  gh release create "${MS_TAG}"
fi

cd artifacts

set +e

OWNER="${GITHUB_REPOSITORY_OWNER:-"VSCodium"}"
REPO_NAME="${GITHUB_REPOSITORY:(${#OWNER}+1)}"
REPOSITORY="${REPO_NAME:-"vscodium"}"

# git workaround
git config --global --add safe.directory /__w/vscodium/vscodium


for FILE in *
do
  if [[ -f "${FILE}" ]] && [[ "${FILE}" != *.sha1 ]] && [[ "${FILE}" != *.sha256 ]]; then
    echo "::group::Uploading '${FILE}' at $( date "+%T" )"
    gh release upload "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

    EXIT_STATUS=$?
    echo "exit: $EXIT_STATUS"

    if (( $EXIT_STATUS )); then
      for (( i=0; i<10; i++ ))
      do
        github-release delete --owner "${OWNER}" --repo "${REPOSITORY}" --tag "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

        sleep $(( 15 * (i + 1)))

        echo "RE-Uploading '${FILE}' at $( date "+%T" )"
        gh release upload "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

        EXIT_STATUS=$?
        echo "exit: $EXIT_STATUS"

        if ! (( $EXIT_STATUS )); then
          break
        fi
      done
      echo "exit: $EXIT_STATUS"

      if (( $EXIT_STATUS )); then
        echo "'${FILE}' hasn't been uploaded!"

        github-release delete --owner "${OWNER}" --repo "${REPOSITORY}" --tag "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

        exit 1
      fi
    fi

    echo "::endgroup::"
  fi
done

cd ..
