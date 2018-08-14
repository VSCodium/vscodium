#!/bin/bash

if git rev-parse $LATEST_MS_TAG >/dev/null 2>&1
then
    echo "Latest MS tag ${LATEST_MS_TAG} already exists in VSCodium. Bail"
else
    echo "New MS tag found, continuing build"
    git config --local user.name "Travis CI"
    git config --local user.email "builds@travis-ci.com"
    git tag $LATEST_MS_TAG
    export SHOULD_BUILD="yes"
fi