#!/bin/bash

GITHUB_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/vscodium/vscodium/releases/tags/$LATEST_MS_TAG)
echo "Github response: ${GITHUB_RESPONSE}"
VSCODIUM_ASSETS=$(echo $GITHUB_RESPONSE | jq '.assets')
echo "VSCodium assets: ${VSCODIUM_ASSETS}"

if [ "$VSCODIUM_ASSETS" != "null" ]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    HAVE_MAC=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["zip"])')
    if [[ "$HAVE_MAC" != "true" ]]; then
      echo "Building on Mac because we have no ZIP"
      export SHOULD_BUILD="yes"
    fi
  else
    HAVE_RPM=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["rpm"])')
    HAVE_DEB=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["deb"])')
    HAVE_TAR=$(echo $VSCODIUM_ASSETS | jq 'map(.name) | contains(["tar.gz"])')
    if [[ "$HAVE_RPM" != "true" ]]; then
      echo "Building on Linux because we have no RPM"
      export SHOULD_BUILD="yes"
    fi
    if [[ "$HAVE_DEB" != "true" ]]; then
      echo "Building on Linux because we have no DEB"
      export SHOULD_BUILD="yes"
    fi
    if [[ "$HAVE_TAR" != "true" ]]; then
      echo "Building on Linux because we have no TAR"
      export SHOULD_BUILD="yes"
    fi
    if [[ "$SHOULD_BUILD" != "yes" ]]; then
      echo "Already have all the Linux builds"
    fi
  fi
else
  echo "Release assets do not exist at all, continuing build"
  export SHOULD_BUILD="yes"
  if git rev-parse $LATEST_MS_TAG >/dev/null 2>&1
  then
    export TRAVIS_TAG=$LATEST_MS_TAG
  else
    git config --local user.name "Travis CI"
    git config --local user.email "builds@travis-ci.com"
    git tag $LATEST_MS_TAG
  fi
fi

