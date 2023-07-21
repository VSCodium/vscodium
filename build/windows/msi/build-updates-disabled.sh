#!/usr/bin/env bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

SCRIPT_DIR=$( pwd )

cd "../../../VSCode-win32-${VSCODE_ARCH}/resources/app"

jsonTmp=$( jq "del(.updateUrl)" product.json )
echo "${jsonTmp}" > product.json && unset jsonTmp

cd "${SCRIPT_DIR}"

./build.sh "updates-disabled"

cd "${CALLER_DIR}"
