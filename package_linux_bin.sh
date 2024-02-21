#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

if [[ -f  "./vscode.tar.gz" ]]; then
  tar -xfz ./vscode.tar.gz .
fi

cd vscode || { echo "'vscode' dir not found"; exit 1; }

export VSCODE_SYSROOT_PREFIX='-glibc-2.17'

for i in {1..5}; do # try 5 times
  yarn --cwd build --frozen-lockfile --check-files && break
  if [[ $i == 3 ]]; then
    echo "Yarn failed too many times" >&2
    exit 1
  fi
  echo "Yarn failed $i, trying again..."
done

./build/azure-pipelines/linux/install.sh

EXPECTED_GLIBC_VERSION="2.17" EXPECTED_GLIBCXX_VERSION="3.4.22" ./build/azure-pipelines/linux/verify-glibc-requirements.sh

node build/azure-pipelines/distro/mixin-npm

yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

cd ..
