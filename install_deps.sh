#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install yarn --without-node
  brew install jq zip
else
  sudo apt-get update
  sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm jq
  if [[ "$BUILDARCH" == "ia32" ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install libc6-dev-i386 gcc-multilib g++-multilib
    sudo apt-get install libx11-dev:i386 libxkbfile-dev:i386
    export CC="/usr/bin/gcc -m32"
    export CXX="/usr/bin/g++ -m32"
    export CC_host=/usr/bin/gcc
    export CXX_host=/usr/bin/g++
  elif [[ $BUILDARCH == "arm64" ]]; then
    sudo dpkg --add-architecture arm64
    sudo apt-get update
    sudo apt-get install libc6-dev-arm64-cross gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
    sudo apt-get install libx11-dev:arm64 libxkbfile-dev:arm64
    export CC=/usr/bin/aarch64-linux-gnu-gcc
    export CXX=/usr/bin/aarch64-linux-gnu-g++
    export CC_host=/usr/bin/gcc
    export CXX_host=/usr/bin/g++
  fi
fi
