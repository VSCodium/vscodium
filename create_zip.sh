#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    zip -r -X -y ../Codium-darwin-${LATEST_MS_TAG}.zip ./*.app
  elif [[ "$BUILDARCH" == "arm64" ]]; then
    cd VSCode-linux-arm64
    tar czf ../Codium-linux-arm64-${LATEST_MS_TAG}.tar.gz .
  else
    cd VSCode-linux-x64
    tar czf ../Codium-linux-x64-${LATEST_MS_TAG}.tar.gz .
  fi

  cd ..
fi