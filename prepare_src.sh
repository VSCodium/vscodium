#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

npm install -g checksum

sum_file() {
  if [[ -f "${1}" ]]; then
    echo "Calculating checksum for ${1}"
    checksum -a sha256 "${1}" > "${1}".sha256
    checksum "${1}" > "${1}".sha1
  fi
}

mkdir -p assets

git archive --format tar.gz --output="./assets/${APP_NAME}-${RELEASE_VERSION}-src.tar.gz" HEAD
git archive --format zip --output="./assets/${APP_NAME}-${RELEASE_VERSION}-src.zip" HEAD

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  COMMIT_ID=$( git rev-parse HEAD )

  jsonTmp=$( jq -n --arg 'tag' "${RELEASE_VERSION}" --arg 'id' "${BUILD_SOURCEVERSION}" --arg 'commit' "${COMMIT_ID}" '{ "tag": $tag, "id": $id, "commit": $commit }' )
  echo "${jsonTmp}" > "./assets/buildinfo.json" && unset jsonTmp
fi

cd assets

for FILE in *; do
  if [[ -f "${FILE}" ]]; then
    sum_file "${FILE}"
  fi
done

cd ..
