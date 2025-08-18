#!/usr/bin/env bash

set -e

FILES=$( find "${SEARCH_PATH}" -name "*.node" -not -path "*prebuilds*" -not -path "*extensions/node_modules/@parcel/watcher*" )

echo "Verifying requirements for files: ${FILES}"

for FILE in ${FILES}; do
  if [[ -n "$( strings "${FILE}" | grep cxx11 | tail -n1 )" ]]; then
    echo "Error: File ${FILE} has dependency on CXX11
    exit 1
  fi
done
