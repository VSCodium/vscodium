#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install jq zip
else
  sudo apt-get update
  sudo apt-get install -y fakeroot rpm jq
  if [[ "$BUILDARCH" == "ia32" ]]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y gcc-multilib g++-multilib
    sudo apt-get install -y \
      libgirepository-1.0-1:i386 \
      gir1.2-glib-2.0:i386 \
      libglib2.0-dev:i386 \
      gir1.2-secret-1:i386 \
      libx11-dev:i386 \
      libxkbfile-dev:i386 \
      libsecret-1-dev:i386
    export CFLAGS=-m32
    export CXXFLAGS=-m32
    export PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig
  elif [[ $BUILDARCH == "arm64" ]]; then
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
