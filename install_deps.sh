#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  brew update
  brew install jq zip
else
  sudo apt-get update
  sudo apt-get install -y fakeroot jq
  if [[ $BUILDARCH == "arm64" ]]; then
    sed 's/^deb /deb [arch=amd64] '/g -i /etc/apt/sources.list
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ trusty main" | sudo tee -a /etc/apt/sources.list.d/arm64.list >/dev/null
    sudo dpkg --add-architecture arm64
    sudo apt-get update
    sudo apt-get install libc6-dev-arm64-cross gcc-aarch64-linux-gnu g++-aarch64-linux-gnu `apt-cache search x11proto | grep ^x11proto | cut -f 1 -d ' '` xz-utils pkg-config
    mkdir -p dl
    cd dl
    apt-get download libx11-dev:arm64 libx11-6:arm64 libxkbfile-dev:arm64 libxkbfile1:arm64 libxau-dev:arm64 libxdmcp-dev:arm64 libxcb1-dev:arm64 libsecret-1-dev:arm64 libsecret-1-0:arm64 libpthread-stubs0-dev:arm64 libglib2.0-dev:arm64 libglib2.0-0:arm64 libffi-dev:arm64 libffi6:arm64 zlib1g:arm64 libpcre3-dev:arm64 libpcre3:arm64
    for i in *.deb; do ar x $i; sudo tar -C / -xf data.tar.*; rm -f data.tar.*; done
    cd ..
    export CC=/usr/bin/aarch64-linux-gnu-gcc
    export CXX=/usr/bin/aarch64-linux-gnu-g++
    export CC_host=/usr/bin/gcc
    export CXX_host=/usr/bin/g++
    export PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig
  else
    sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev rpm
  fi
fi
