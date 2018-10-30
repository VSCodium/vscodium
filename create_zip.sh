#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    zip -r -X -y ../VSCode-darwin-${LATEST_MS_TAG}.zip ./*
  elif [[ "$BUILDARCH" == "ia32" ]]; then
    cd VSCode-linux-ia32
    tar czf ../VSCode-linux-ia32-${LATEST_MS_TAG}.tar.gz .
  elif [[ "$BUILDARCH" == "arm64" ]]; then
    cd VSCode-linux-arm64
    tar czf ../VSCode-linux-arm64-${LATEST_MS_TAG}.tar.gz .
  else
    cd VSCode-linux-x64
    tar czf ../VSCode-linux-x64-${LATEST_MS_TAG}.tar.gz .
  fi

  cd ..
fi