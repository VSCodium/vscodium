#!/bin/bash

git clone https://github.com/Microsoft/vscode.git
cd vscode
export LATEST_MS_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "Got the latest MS tag: ${LATEST_MS_TAG}"
git checkout $LATEST_MS_TAG
cd ..