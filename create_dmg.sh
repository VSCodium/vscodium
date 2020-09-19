#!/bin/bash
set -x

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    npx create-dmg VSCodium.app ..
    mv "../VSCodium ${LATEST_MS_TAG}.dmg" "../VSCodium.${LATEST_MS_TAG}.dmg"
  fi
  cd ..
fi
