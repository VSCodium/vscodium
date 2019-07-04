#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install jq zip
else
  sudo apt-get update
  sudo apt-get install -y fakeroot rpm jq
  if [[ $BUILDARCH == "arm64" ]]; then
    echo "deb http://ports.ubuntu.com/ubuntu-ports/ trusty main" | sudo tee -a /etc/apt/sources.list.d/arm64.list >/dev/null
    sudo dpkg --add-architecture arm64
    sudo apt-get update
    sudo apt-get install libc6-dev-arm64-cross gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
    sudo apt-get install libx11-dev:arm64 libxkbfile-dev:arm64
    export CC=/usr/bin/aarch64-linux-gnu-gcc
    export CXX=/usr/bin/aarch64-linux-gnu-g++
    export CC_host=/usr/bin/gcc
    export CXX_host=/usr/bin/g++
  else
    sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm jq
  fi
fi
