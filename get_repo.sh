#!/bin/bash

if [ -d vscode ]; then
  cd vscode 
  git fetch --all
else
  git clone https://github.com/Microsoft/vscode.git
  cd vscode
fi

export LATEST_MS_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "Got the latest MS tag: ${LATEST_MS_TAG}"
git checkout $LATEST_MS_TAG
cd ..
