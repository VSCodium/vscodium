#!/bin/bash

if [[ "$TRAVIS_OS_NAME" === "osx" ]]; then
  cd VSCode-darwin
  zip -r ../VSCode-darwin-${TRAVIS_TAG}.zip ./*
else
  cd VSCode-linux-x64
  zip -r ../VSCode-linux-x64-${TRAVIS_TAG}.zip ./*
fi

cd ..