#!/usr/bin/env bash

set -e

create_github_release() {
  local notes
  if [[ -z "${GITHUB_TOKEN}" ]]; then
    echo "Will not release because no GITHUB_TOKEN defined"
    exit
  fi

  REPOSITORY_OWNER="${ASSETS_REPOSITORY/\/*/}"
  REPOSITORY_NAME="${ASSETS_REPOSITORY/*\//}"

  npm install -g github-release-cli

  if [[ $( gh release view --repo "${ASSETS_REPOSITORY}" "${RELEASE_VERSION}" 2>&1 ) =~ "release not found" ]]; then
    echo "Creating release '${RELEASE_VERSION}'"

    if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
      notes="update vscode to [${MS_COMMIT}](https://github.com/microsoft/vscode/tree/${MS_COMMIT})"
      CREATE_OPTIONS=""
    else
      notes="update vscode to [${MS_TAG}](https://code.visualstudio.com/updates/v$( echo "${MS_TAG//./_}" | cut -d'_' -f 1,2 ))"
      CREATE_OPTIONS="--generate-notes"
    fi

    gh release create "${RELEASE_VERSION}" --repo "${ASSETS_REPOSITORY}" --title "${RELEASE_VERSION}" --notes "${notes}" ${CREATE_OPTIONS}
  fi
}

create_github_release

cd assets

set +e

upload_release_files() {
  local file exit_status
  for file in *; do
    if [[ -f "${file}" ]] && [[ "${file}" != *.sha1 ]] && [[ "${file}" != *.sha256 ]]; then
      echo "::group::Uploading '${file}' at $( date "+%T" )"
      gh release upload --repo "${ASSETS_REPOSITORY}" "${RELEASE_VERSION}" "${file}" "${file}.sha1" "${file}.sha256"

      exit_status=$?
      echo "exit: ${exit_status}"

      if (( "${exit_status}" )); then
        for (( i=0; i<10; i++ )); do
          github-release delete --owner "${REPOSITORY_OWNER}" --repo "${REPOSITORY_NAME}" --tag "${RELEASE_VERSION}" "${file}" "${file}.sha1" "${file}.sha256"

          sleep $(( 15 * (i + 1)))

          echo "RE-Uploading '${file}' at $( date "+%T" )"
          gh release upload --repo "${ASSETS_REPOSITORY}" "${RELEASE_VERSION}" "${file}" "${file}.sha1" "${file}.sha256"

          exit_status=$?
          echo "exit: ${exit_status}"

          if ! (( "${exit_status}" )); then
            break
          fi
        done
        echo "exit: ${exit_status}"

        if (( "${exit_status}" )); then
          echo "'${file}' hasn't been uploaded!"

          github-release delete --owner "${REPOSITORY_OWNER}" --repo "${REPOSITORY_NAME}" --tag "${RELEASE_VERSION}" "${file}" "${file}.sha1" "${file}.sha256"

          exit 1
        fi
      fi

      echo "::endgroup::"
    fi
  done
}

upload_release_files

cd ..