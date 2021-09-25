#!/bin/bash

set -e

if [[ -z "${GH_CLI_TOKEN}" ]]; then
  echo "Will not release because no GH_CLI_TOKEN defined"
  exit
fi

echo "${GH_CLI_TOKEN}" | gh auth login --with-token

RELEASE_DATA=$( gh release view "${MS_TAG}" )

if [[ "${RELEASE_DATA}" == "release not found" ]]; then
  gh release create "${MS_TAG}"
fi

for FILE in ./artifacts/*
do
  if [[ -f "${FILE}" ]] && [[ "${FILE}" != *.sha1 ]] && [[ "${FILE}" != *.sha256 ]]; then
    gh release upload "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"
  fi
done
