#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    zip -r ../VSCode-darwin-${LATEST_MS_TAG}.zip ./*
    cd ..
  else
    for ARCH in {x64,ia32}; do
      cd VSCode-linux-${ARCH}
      tar czf ../VSCode-linux-${ARCH}-${LATEST_MS_TAG}.tar.gz .
      cd ..
    done
  fi
fi
