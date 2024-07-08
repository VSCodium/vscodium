#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

tar -xzf ./vscode.tar.gz

chown -R root:root vscode

cd vscode || { echo "'vscode' dir not found"; exit 1; }

export VSCODE_SKIP_NODE_VERSION_CHECK=1
export VSCODE_SYSROOT_PREFIX='-glibc-2.17'

if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  export VSCODE_SYSROOT_REPO='VSCodium/vscode-linux-build-agent'
  export VSCODE_SYSROOT_VERSION='20240129-253798'
  export VSCODE_SYSROOT_PREFIX='-glibc-2.28'
fi

if [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
  export VSCODE_ELECTRON_REPO='riscv-forks/electron-riscv-releases'
  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  ELECTRON_VERSION="v29.4.0"
  # Look for releases here if electron version used by vscode changed
  # https://github.com/riscv-forks/electron-riscv-releases/releases
  export VSCODE_ELECTRON_TAG="${ELECTRON_VERSION}.riscv2"
  echo "7244465fe0c1a6ac6e34fe765a9d90fe0017b1a6d3406fd6b8dd9f5d2c8c9df5 *electron-v29.4.0-linux-riscv64.zip" >> build/checksums/electron.txt
fi

if [[ -d "../patches/linux/client/" ]]; then
  for file in "../patches/linux/client/"*.patch; do
    if [[ -f "${file}" ]]; then
      echo applying patch: "${file}";
      if ! git apply --ignore-whitespace "${file}"; then
        echo failed to apply patch "${file}" >&2
        exit 1
      fi
    fi
  done
fi

for i in {1..5}; do # try 5 times
  yarn --cwd build --frozen-lockfile --check-files && break
  if [[ $i == 3 ]]; then
    echo "Yarn failed too many times" >&2
    exit 1
  fi
  echo "Yarn failed $i, trying again..."
done

if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  source ./build/azure-pipelines/linux/setup-env.sh
else
  ./build/azure-pipelines/linux/setup-env.sh
fi

for i in {1..5}; do # try 5 times
  yarn --check-files && break
  if [ $i -eq 3 ]; then
    echo "Yarn failed too many times" >&2
    exit 1
  fi
  echo "Yarn failed $i, trying again..."
done

node build/azure-pipelines/distro/mixin-npm

yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

cd ..
