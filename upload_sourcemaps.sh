#!/usr/bin/env bash

set -e

npm install -g checksum github-release-cli

mkdir -p sourcemaps
cd sourcemaps

SOURCE_DIR="../vscode/.build/extensions"
DESTINATION_DIR="extensions"

find "${SOURCE_DIR}" -type f -name "*.js.map" | while read -r SOURCE_FILE_PATH; do
  RELATIVE_PATH="${SOURCE_FILE_PATH#$SOURCE_DIR/}"
  FLATTENED_FILENAME="${RELATIVE_PATH//\//-}"

  cp "${SOURCE_FILE_PATH}" "$DESTINATION_DIR-${FLATTENED_FILENAME}"
done

SOURCE_DIR="../vscode/out-vscode-min"
DESTINATION_DIR="core"

find "${SOURCE_DIR}" -type f -name "*.js.map" | while read -r SOURCE_FILE_PATH; do
  RELATIVE_PATH="${SOURCE_FILE_PATH#$SOURCE_DIR/}"
  FLATTENED_FILENAME="${RELATIVE_PATH//\//-}"

  cp "${SOURCE_FILE_PATH}" "$DESTINATION_DIR-${FLATTENED_FILENAME}"
done

tar czf "${APP_NAME}-${RELEASE_VERSION}-sourcemaps.tar.gz" *.js.map

find . -type f -name "*.js.map" | sort | xargs checksum -a sha256 > checksum.txt

checksum -a sha256 checksum.txt > checksum.txt.sha256
checksum -a sha256 "${APP_NAME}-${RELEASE_VERSION}-sourcemaps.tar.gz" > "${APP_NAME}-${RELEASE_VERSION}-sourcemaps.tar.gz.sha256"

REPOSITORY_OWNER="${SOURCEMAPS_REPOSITORY/\/*/}"
REPOSITORY_NAME="${SOURCEMAPS_REPOSITORY/*\//}"
RELEASE_TAG="${VSCODE_QUALITY}-${BUILD_SOURCEVERSION}"

gh release create "${RELEASE_TAG}" --repo "${SOURCEMAPS_REPOSITORY}" --title "${RELEASE_VERSION}"

set +e

for FILE in *; do
  if [[ -f "${FILE}" ]]; then
    echo "::group::Uploading '${FILE}' at $( date "+%T" )"
    gh release upload --repo "${SOURCEMAPS_REPOSITORY}" "${RELEASE_TAG}" "${FILE}"

    EXIT_STATUS=$?
    echo "exit: ${EXIT_STATUS}"

    if (( "${EXIT_STATUS}" )); then
      for (( i=0; i<10; i++ )); do
        github-release delete --owner "${REPOSITORY_OWNER}" --repo "${REPOSITORY_NAME}" --tag "${RELEASE_TAG}" "${FILE}"

        sleep $(( 15 * (i + 1)))

        echo "RE-Uploading '${FILE}' at $( date "+%T" )"
        gh release upload --repo "${SOURCEMAPS_REPOSITORY}" "${RELEASE_TAG}" "${FILE}"

        EXIT_STATUS=$?
        echo "exit: ${EXIT_STATUS}"

        if ! (( "${EXIT_STATUS}" )); then
          break
        fi
      done
      echo "exit: ${EXIT_STATUS}"

      if (( "${EXIT_STATUS}" )); then
        echo "'${FILE}' hasn't been uploaded!"

        github-release delete --owner "${REPOSITORY_OWNER}" --repo "${REPOSITORY_NAME}" --tag "${RELEASE_TAG}" "${FILE}"

        exit 1
      fi
    fi

    echo "::endgroup::"
  fi
done

cd ..
