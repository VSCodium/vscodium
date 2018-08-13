#!/bin/bash

if git rev-parse $LATEST_MS_TAG >/dev/null 2>&1
then
    echo "Latest MS tag ${LATEST_MS_TAG} already exists in VSCodium. Bail"
else
    echo "New MS tag found, continuing build"
    if [[ "$TRAVIS_OS_NAME" != "osx" ]]; then
      echo $LATEST_MS_TAG > version.md
      git config --local user.name "Travis CI"
      git config --local user.email "builds@travis-ci.com"
      git add version.md
      git commit -m "${LATEST_MS_TAG}"
      git tag $LATEST_MS_TAG
      git push --quiet https://$GITHUB_TOKEN@github.com/VSCodium/vscodium master --tags > /dev/null 2>&1
    fi
    export SHOULD_BUILD="yes"
fi