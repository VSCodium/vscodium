#!/bin/bash

sudo apt-get update
sudo apt-get install -y fakeroot jq
triplet=
case $BUILDARCH in
  arm)
    arch=armhf
    triplet=arm-linux-gnueabihf
    ;;

  arm64)
    arch=arm64
    triplet=aarch64-linux-gnu
    ;;
esac

if [[ -n "$triplet" ]]; then
  sed 's/^deb /deb [arch=amd64] '/g -i /etc/apt/sources.list
  echo "deb [arch=$arch] http://ports.ubuntu.com/ubuntu-ports/ trusty main" | sudo tee -a /etc/apt/sources.list.d/$arch.list >/dev/null
  sudo dpkg --add-architecture $arch
  sudo apt-get update
  sudo apt-get install libc6-dev-$arch-cross gcc-$triplet g++-$triplet `apt-cache search x11proto | grep ^x11proto | cut -f 1 -d ' '` xz-utils pkg-config
  mkdir -p dl
  cd dl
  apt-get download libx11-dev:$arch libx11-6:$arch libxkbfile-dev:$arch libxkbfile1:$arch libxau-dev:$arch libxdmcp-dev:$arch libxcb1-dev:$arch libsecret-1-dev:$arch libsecret-1-0:$arch libpthread-stubs0-dev:$arch libglib2.0-dev:$arch libglib2.0-0:$arch libffi-dev:$arch libffi6:$arch zlib1g:$arch libpcre3-dev:$arch libpcre3:$arch
  for i in *.deb; do ar x $i; sudo tar -C / -xf data.tar.*; rm -f data.tar.*; done
  cd ..
  export CC=/usr/bin/$triplet-gcc
  export CXX=/usr/bin/$triplet-g++
  export CC_host=/usr/bin/gcc
  export CXX_host=/usr/bin/g++
  export PKG_CONFIG_LIBDIR=/usr/lib/$triplet/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig
else
  sudo apt-get install libx11-dev libxkbfile-dev libsecret-1-dev rpm
fi
