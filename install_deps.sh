#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install jq zip
else
  sudo apt-get update
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
