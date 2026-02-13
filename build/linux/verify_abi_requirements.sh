#!/usr/bin/env bash

set -e

FILES=$(
  find "${SEARCH_PATH}" -type f -executable -name "node"
  find "${SEARCH_PATH}" -name "*.node" -not -path "*prebuilds*" -not -path "*extensions/node_modules/@parcel/watcher*"
)

echo "Verifying requirements for files: ${FILES}"

for FILE in ${FILES}; do
  CXXABI_VERSION="0.0.0"

  while IFS= read -r LINE; do
    VERSION=${LINE#*_}

    if [[ $( printf "%s\n%s" "${VERSION}" "${CXXABI_VERSION}" | sort -V | tail -n1 ) == "${VERSION}" ]]; then
      CXXABI_VERSION="${VERSION}"
    fi
  done < <( strings "${FILE}" | grep -i ^CXXABI )

  if [[ $( printf "%s\n%s" "${EXPECTED_CXXABI_VERSION}" "${CXXABI_VERSION}" | sort -V | tail -n1 ) == "${EXPECTED_CXXABI_VERSION}" ]]; then
    echo "File ${FILE} has dependency on ABI ${CXXABI_VERSION} <= ${EXPECTED_CXXABI_VERSION}"
  else
    echo "Error: File ${FILE} has dependency on ABI ${CXXABI_VERSION} > ${EXPECTED_CXXABI_VERSION}"
    exit 1
  fi
done
