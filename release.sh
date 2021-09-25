#!/bin/bash

set -e

if [[ -z "${GH_CLI_TOKEN}" ]]; then
  echo "Will not release because no GH_CLI_TOKEN defined"
  exit
fi

echo "${GH_CLI_TOKEN}" | gh auth login --with-token

if [[ $( gh release view "${MS_TAG}" 2>&1 ) =~ "release not found" ]]; then
  echo "Creating release `${MS_TAG}`"
  gh release create "${MS_TAG}"
fi

for FILE in ./artifacts/*
do
  if [[ -f "${FILE}" ]] && [[ "${FILE}" != *.sha1 ]] && [[ "${FILE}" != *.sha256 ]]; then
    echo "Uploading `${FILE}`"
    gh release upload "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"
  fi
done
