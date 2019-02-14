#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install jq zip
else
  if [[ "$BUILDARCH" == "ia32" ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y fakeroot rpm jq
    sudo apt-get install -y gcc-multilib g++-multilib
    sudo apt-get install -y libgirepository-1.0-1:i386
    sudo apt-get install -y gir1.2-glib-2.0:i386
    sudo apt-get install -y gir1.2-secret-1:i386
    sudo apt-get install -y libglib2.0-dev:i386 libx11-dev:i386 libxkbfile-dev:i386 libsecret-1-dev:i386
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
