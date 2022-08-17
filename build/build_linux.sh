#!/bin/bash

rm -rf VSCode*
rm -rf vscode*

if [[ "${1}" == "insider" ]]; then
  export INSIDER="yes"
fi

. get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no OS_NAME=linux VSCODE_ARCH=x64 . build.sh
