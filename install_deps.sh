#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install yarn --without-node
  brew install jq zip
else
  # handle yarn install
  sudo apt-get update
  sudo apt-get install apt-transport-https -y --force-yes
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install --no-install-recommends yarn

  # get other deps
  sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm jq
  if [[ "$BUILDARCH" == "ia32" ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install libc6-dev-i386 gcc-multilib g++-multilib
    sudo apt-get install libx11-dev:i386 libxkbfile-dev:i386
  elif [[ $BUILDARCH == "arm64" ]]; then
    # Use the default C / C++ compilers,
    # because some makefiles default to CC:=gcc:
    export CC=/usr/bin/cc
    export CXX=/usr/bin/c++
  fi
fi
