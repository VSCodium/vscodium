#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install jq zip
else
  if [[ "$BUILDARCH" == "ia32" ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y fakeroot rpm jq build-essential
    sudo apt-get install -y libx11-dev:i386 libxkbfile-dev:i386 libsecret-1-dev:i386 libc6-dev-i386 gcc-multilib g++-multilib
    export CFLAGS=-m32
    export CXXFLAGS=-m32
    export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig
  elif [[ $BUILDARCH == "arm64" ]]; then
    # Use the default C / C++ compilers,
    # because some makefiles default to CC:=gcc:
    export CC=/usr/bin/cc
    export CXX=/usr/bin/c++
  else
    sudo apt-get update
    sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm jq
  fi
fi
