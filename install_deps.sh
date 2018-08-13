#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install node python yarn jq zip
else
  sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm
  nvm install 8
  nvm use 8
fi