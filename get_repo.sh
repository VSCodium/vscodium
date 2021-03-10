#!/bin/bash

# figure out latest tag by calling MS update API
UPDATE_INFO=$(curl https://update.code.visualstudio.com/api/update/darwin/stable/lol)
export LATEST_MS_COMMIT=$(echo $UPDATE_INFO | jq -r '.version')
export LATEST_MS_TAG=$(echo $UPDATE_INFO | jq -r '.name')
echo "Got the latest MS tag: ${LATEST_MS_TAG}"

git clone https://github.com/Microsoft/vscode.git --branch $LATEST_MS_TAG --depth 1

# for GH actions
if [[ $GITHUB_ENV ]]; then
	echo "LATEST_MS_COMMIT=$LATEST_MS_COMMIT" >> $GITHUB_ENV
	echo "LATEST_MS_TAG=$LATEST_MS_TAG" >> $GITHUB_ENV
fi
