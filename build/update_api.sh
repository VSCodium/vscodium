#!/usr/bin/env bash

set -e

export VSCODE_QUALITY="stable"

while getopts ":i" opt; do
  case "$opt" in
    i)
      export VSCODE_QUALITY="insider"
      ;;
    *)
      ;;
  esac
done


URL=$( curl -s "https://update.code.visualstudio.com/api/update/win32-x64-archive/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" | jq -c '.url' | sed -E 's/.*"([^"]+)".*/\1/' )
# echo "url: ${URL}"
FILE="${URL##*/}"
# echo "file: ${FILE}"
DIRECTORY="${FILE%.zip}"
# echo "directory: ${DIRECTORY}"

if [[ ! -f "${FILE}" ]]; then
  wget "${URL}"
fi

if [[ ! -d "${DIRECTORY}" ]]; then
  unzip "${FILE}" -d "${DIRECTORY}"
fi

APIS=$( jq -r '.extensionEnabledApiProposals' "${DIRECTORY}/resources/app/product.json" )

APIS=$( echo "${APIS}" | jq '. += {"jeanp413.open-remote-ssh": ["resolvers", "tunnels", "terminalDataWriteEvent", "contribRemoteHelp", "contribViewsRemote"]}' )
APIS=$( echo "${APIS}" | jq '. += {"jeanp413.open-remote-wsl": ["resolvers", "contribRemoteHelp", "contribViewsRemote"]}' )

jsonTmp=$( jq --argjson v "${APIS}" 'setpath(["extensionEnabledApiProposals"]; $v)' product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp
