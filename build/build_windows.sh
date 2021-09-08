#!/bin/bash

# to run with Bash: "C:\Program Files\Git\bin\bash.exe" ./build/build_windows.sh

rm -rf VSCode*
rm -rf vscode

. get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no OS_NAME=windows VSCODE_ARCH=x64 . build.sh
