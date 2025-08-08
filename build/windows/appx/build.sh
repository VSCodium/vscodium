#!/usr/bin/env bash

set -ex

# Add Windows SDK to path
SDK='/C/Program Files (x86)/Windows Kits/10/bin/10.0.26100.0/x64'
export PATH="${SDK}:${PATH}"

APPX_NAME="${BINARY_NAME//-/_}"

makeappx pack /d "../../../VSCode-win32-${VSCODE_ARCH}/appx/manifest" /p "../../../VSCode-win32-${VSCODE_ARCH}/appx/${APPX_NAME}_${VSCODE_ARCH}.appx" /nv

# Remove the raw manifest folder
rm -rf "../../../VSCode-win32-${VSCODE_ARCH}/appx/manifest"
