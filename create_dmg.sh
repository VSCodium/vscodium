#!/bin/bash
if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    create-dmg VSCodium-darwin-${LATEST_MS_TAG}.app ../
  fi
  cd ..
fi
