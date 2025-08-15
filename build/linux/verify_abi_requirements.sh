#!/usr/bin/env bash

set -e

files=$(find $SEARCH_PATH -name "*.node" -not -path "*prebuilds*" -not -path "*extensions/node_modules/@parcel/watcher*" -o -type f -executable -name "node")

for FILE in ${FILES}; do
  CXXABI_VERSION="${EXPECTED_CXXABI_VERSION}"

  while IFS= read -r LINE; do
    VERSION=${LINE#*_}

    if [[ $(printf "%s\n%s" "${VERSION}" "${CXXABI_VERSION}" | sort -V | tail -n1) == "${VERSION}" ]]; then
      CXXABI_VERSION="${VERSION}"
    fi
  done < <(strings "${FILE}" | grep -i ^CXXABI)

  if [[ "${CXXABI_VERSION}" != "${EXPECTED_CXXABI_VERSION}" ]]; then
    echo "Error: File ${FILE} has dependency on ABI > ${EXPECTED_CXXABI_VERSION}, found ${CXXABI_VERSION}"
    exit 1
  else
    echo "File ${FILE} has dependency on ABI ${CXXABI_VERSION}"
  fi
done
