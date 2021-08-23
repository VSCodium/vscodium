#!/bin/bash

# to run with WSL: wsl ./build/build_windows.sh

rm -rf VSCode*
rm -rf vscode

./get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no OS_NAME=windows VSCODE_ARCH=x64 ./build.sh
