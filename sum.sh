#!/bin/bash

sum_file () {
  if [[ -f "$1" ]]; then
    shasum -a 256 $1 > $1.sha256
  fi
}

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    sum_file VSCodium-darwin-*.zip
  else # linux
    if [[ "$BUILDARCH" == "x64" ]]; then
      deb_arch=amd64
      rpm_arch=x86_64
    elif [[ "$BUILDARCH" == "ia32" ]]; then
      deb_arch=i386
      rpm_arch=i386
    fi
    sum_file VSCodium-linux*.tar.gz
    sum_file vscode/.build/linux/deb/${deb_arch}/deb/*.deb
    sum_file vscode/.build/linux/rpm/${rpm_arch}/*.rpm
    cp vscode/.build/linux/deb/${deb_arch}/deb/*.sha256 .
    cp vscode/.build/linux/rpm/${rpm_arch}/*.sha256 .
  fi
fi
