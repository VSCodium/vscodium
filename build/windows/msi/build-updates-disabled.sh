#!/usr/bin/env bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

SCRIPT_DIR=$( pwd )

cd "../../../VSCode-win32-${VSCODE_ARCH}/resources/app"

cp product.json product.json.bak
jq "del(.updateUrl)" product.json.bak > product.json
rm -f product.json.bak

cd "${SCRIPT_DIR}"

./build.sh "updates-disabled"

cd "${CALLER_DIR}"
