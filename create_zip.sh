#!/bin/bash

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    cd VSCode-darwin
    zip -r ../VSCode-darwin-${LATEST_MS_TAG}.zip ./*
  else
    cd VSCode-linux-x64
    zip -r ../VSCode-linux-x64-${LATEST_MS_TAG}.zip ./*
  fi

  cd ..
fi