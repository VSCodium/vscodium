#!/bin/bash

# figure out latest tag by calling MS update API
if [ "$INSIDER" == "1" ]; then
	UPDATE_INFO=$(curl https://update.code.visualstudio.com/api/update/darwin/insider/lol)
else
	UPDATE_INFO=$(curl https://update.code.visualstudio.com/api/update/darwin/stable/lol)
fi
export LATEST_MS_COMMIT=$(echo $UPDATE_INFO | jq -r '.version')
export LATEST_MS_TAG=$(echo $UPDATE_INFO | jq -r '.name')
echo "Got the latest MS tag: ${LATEST_MS_TAG} version: ${LATEST_MS_COMMIT}"

if [ "$INSIDER" == "1" ]; then
	mkdir -p vscode; cd vscode
	git init ; git remote add origin https://github.com/Microsoft/vscode.git
	git fetch --depth 1 origin $LATEST_MS_COMMIT; git checkout FETCH_HEAD
	cd ..
else
	git clone https://github.com/Microsoft/vscode.git --branch $LATEST_MS_TAG --depth 1
fi

# for GH actions
if [[ $GITHUB_ENV ]]; then
	echo "LATEST_MS_COMMIT=$LATEST_MS_COMMIT" >> $GITHUB_ENV
	echo "LATEST_MS_TAG=$LATEST_MS_TAG" >> $GITHUB_ENV
fi
