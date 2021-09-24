#!/bin/bash

set -e

if [[ ! -z "${GITHUB_TOKEN}" ]]; then
  echo "${GITHUB_TOKEN}" | gh auth login --with-token
fi

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
