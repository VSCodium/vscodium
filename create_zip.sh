#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    zip -r ../VSCode-darwin-${LATEST_MS_TAG}.zip ./*
  elif [[ "$BUILDARCH" == "32" ]]; then
    cd VSCode-linux-ia32
    tar czf ../VSCode-linux-ia32-${LATEST_MS_TAG}.tar.gz .
  else
    cd VSCode-linux-x64
    tar czf ../VSCode-linux-x64-${LATEST_MS_TAG}.tar.gz .
  fi

  cd ..
fi