#!/bin/bash

rm -rf VSCode*
rm -rf vscode

. get_repo.sh

SHOULD_BUILD=yes CI_BUILD=no OS_NAME=linux VSCODE_ARCH=x64 . build.sh