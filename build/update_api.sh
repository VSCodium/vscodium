#!/bin/bash

export VSCODE_QUALITY="stable"

while getopts ":ilp" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
  esac
done


URL=`curl -s "https://update.code.visualstudio.com/api/update/win32-x64-archive/${VSCODE_QUALITY}/VERSION" | jq -c '.url' | sed -E 's/.*"([^"]+)".*/\1/'`
# echo "url: ${URL}"
FILE=`echo "${URL}" | sed -E 's|.*/([^/]+\.zip)$|\1|'`
# echo "file: ${FILE}"
DIRECTORY=`echo "${URL}" | sed -E 's|.*/([^/]+)\.zip$|\1|'`
# echo "directory: ${DIRECTORY}"

if [[ ! -f "${FILE}" ]]; then
  wget "${URL}"
fi

if [[ ! -d "${DIRECTORY}" ]]; then
  unzip "${FILE}" -d "${DIRECTORY}"
fi

APIS=`cat ${DIRECTORY}/resources/app/product.json | jq -r '.extensionEnabledApiProposals'`

cat <<< $(jq --argjson v "${APIS}" 'setpath(["extensionEnabledApiProposals"]; $v)' product.json) > product.json
