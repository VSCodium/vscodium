#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

tar -xzf ./vscode.tar.gz

cd vscode || { echo "'vscode' dir not found"; exit 1; }

GLIBC_VERSION="2.17"
GLIBCXX_VERSION="3.4.26"
NODE_VERSION="16.20.2"

if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  GLIBC_VERSION="2.28"
elif [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
  # Unofficial RISC-V nodejs builds doesn't provide v16.x
  NODE_VERSION="18.18.1"
fi

export VSCODE_PLATFORM='linux'
export VSCODE_SKIP_NODE_VERSION_CHECK=1
export VSCODE_SYSROOT_PREFIX="-glibc-${GLIBC_VERSION}"

VSCODE_HOST_MOUNT="$( pwd )"

export VSCODE_HOST_MOUNT

if [[ "${VSCODE_ARCH}" == "x64" || "${VSCODE_ARCH}" == "arm64" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:centos7-devtoolset8-${VSCODE_ARCH}"
elif [[ "${VSCODE_ARCH}" == "armhf" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:bionic-devtoolset-arm32v7"
elif [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:bionic-devtoolset-ppc64le"
  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  export VSCODE_SYSROOT_REPO='VSCodium/vscode-linux-build-agent'
  export VSCODE_SYSROOT_VERSION='20240129-253798'
elif [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:focal-devtoolset-riscv64"
  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
fi

export VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME

sed -i "/target/s/\"20.*\"/\"${NODE_VERSION}\"/" remote/.yarnrc

if [[ "${NODE_VERSION}" != 16* ]]; then
  if [[ -f "../patches/linux/reh/node16.patch" ]]; then
    mv "../patches/linux/reh/node16.patch" "../patches/linux/reh/node16.patch.no"
  fi
fi

if [[ -d "../patches/linux/reh/" ]]; then
  for file in "../patches/linux/reh/"*.patch; do
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
  ./build/azure-pipelines/linux/setup-env.sh --only-remote
fi

for i in {1..5}; do # try 5 times
  yarn --frozen-lockfile --check-files && break
  if [ $i -eq 3 ]; then
    echo "Yarn failed too many times" >&2
    exit 1
  fi
  echo "Yarn failed $i, trying again..."
done

EXPECTED_GLIBC_VERSION="${GLIBC_VERSION}" EXPECTED_GLIBCXX_VERSION="${GLIBCXX_VERSION}" ./build/azure-pipelines/linux/verify-glibc-requirements.sh

node build/azure-pipelines/distro/mixin-npm

export VSCODE_NODE_GLIBC="-glibc-${GLIBC_VERSION}"

yarn gulp minify-vscode-reh
yarn gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

cd ..

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

mkdir -p assets

echo "Building and moving REH"
cd "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}"
tar czf "../assets/${APP_NAME_LC}-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
cd ..

npm install -g checksum

sum_file() {
  if [[ -f "${1}" ]]; then
    echo "Calculating checksum for ${1}"
    checksum -a sha256 "${1}" > "${1}".sha256
    checksum "${1}" > "${1}".sha1
  fi
}

cd assets

for FILE in *; do
  if [[ -f "${FILE}" ]]; then
    sum_file "${FILE}"
  fi
done

cd ..
