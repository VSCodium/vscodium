#!/bin/bash

sum_file () {
  if [[ -f "$1" ]]; then
    shasum -a 256 $1 > $1.sha256
    shasum $1 > $1.sha1
  fi
}

if [[ "$SHOULD_BUILD" == "yes" ]]; then
  if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    sum_file VSCodium-darwin-*.zip
  elif [[ "$CI_WINDOWS" == "True" ]]; then
    sum_file VSCodiumSetup-*.exe
    sum_file VSCodiumUserSetup-*.exe
    sum_file VSCodium-win32-*.zip
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
    cp vscode/.build/linux/deb/${deb_arch}/deb/*.{sha256,sha1} .
    cp vscode/.build/linux/rpm/${rpm_arch}/*.{sha256,sha1} .
  fi
fi
