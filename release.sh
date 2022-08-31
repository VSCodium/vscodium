#!/bin/bash

set -e

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not release because no GITHUB_TOKEN defined"
  exit
fi

OWNER="${GITHUB_REPOSITORY_OWNER:-"VSCodium"}"
REPO_NAME="${GITHUB_REPOSITORY:(${#OWNER}+1)}"

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  REPOSITORY="${REPO_NAME:-"vscodium"}-insiders"
  NOTES="update to [${MS_COMMIT}](https://github.com/microsoft/vscode/tree/${MS_COMMIT})"
else
  REPOSITORY="${REPO_NAME:-"vscodium"}"
  NOTES="update to [${MS_TAG}](https://code.visualstudio.com/updates/v$( echo ${MS_TAG//./_} \| cut -d'_' -f 1,2 ))"
fi

npm install -g github-release-cli

if [[ $( gh release view --repo "${OWNER}/${REPOSITORY}" "${RELEASE_VERSION}" 2>&1 ) =~ "release not found" ]]; then
  echo "Creating release '${RELEASE_VERSION}'"
  gh release create "${RELEASE_VERSION}" --repo "${OWNER}/${REPOSITORY}" --notes "${NOTES}"
fi

cd artifacts

set +e

for FILE in *
do
  if [[ -f "${FILE}" ]] && [[ "${FILE}" != *.sha1 ]] && [[ "${FILE}" != *.sha256 ]]; then
    echo "::group::Uploading '${FILE}' at $( date "+%T" )"
    gh release upload --repo "${OWNER}/${REPOSITORY}" "${RELEASE_VERSION}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

    EXIT_STATUS=$?
    echo "exit: ${EXIT_STATUS}"

    if (( "${EXIT_STATUS}" )); then
      for (( i=0; i<10; i++ ))
      do
        github-release delete --owner "${OWNER}" --repo "${REPOSITORY}" --tag "${RELEASE_VERSION}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

        sleep $(( 15 * (i + 1)))

        echo "RE-Uploading '${FILE}' at $( date "+%T" )"
        gh release upload --repo "${OWNER}/${REPOSITORY}" "${RELEASE_VERSION}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

        EXIT_STATUS=$?
        echo "exit: ${EXIT_STATUS}"

        if ! (( "${EXIT_STATUS}" )); then
          break
        fi
      done
      echo "exit: ${EXIT_STATUS}"

      if (( "${EXIT_STATUS}" )); then
        echo "'${FILE}' hasn't been uploaded!"

        github-release delete --owner "${OWNER}" --repo "${REPOSITORY}" --tag "${RELEASE_VERSION}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

        exit 1
      fi
    fi

    echo "::endgroup::"
  fi
done

cd ..
