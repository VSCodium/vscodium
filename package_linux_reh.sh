#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

APP_NAME_LC="$( echo "${APP_NAME}" | awk '{print tolower($0)}' )"

mkdir -p assets

tar -xzf ./vscode.tar.gz

cd vscode || { echo "'vscode' dir not found"; exit 1; }

GLIBC_VERSION="2.17"
GLIBCXX_VERSION="3.4.22"
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

sed -i "/target/s/\"20.*\"/\"${NODE_VERSION}\"/" remote/.npmrc

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
  npm ci --prefix build && break
  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  source ./build/azure-pipelines/linux/setup-env.sh
else
  ./build/azure-pipelines/linux/setup-env.sh --only-remote
fi

for i in {1..5}; do # try 5 times
  npm ci && break
  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

node build/azure-pipelines/distro/mixin-npm

export VSCODE_NODE_GLIBC="-glibc-${GLIBC_VERSION}"

if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
  echo "Building REH"
  yarn gulp minify-vscode-reh
  yarn gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

  EXPECTED_GLIBC_VERSION="${GLIBC_VERSION}" EXPECTED_GLIBCXX_VERSION="${GLIBCXX_VERSION}" SEARCH_PATH="../vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}" ./build/azure-pipelines/linux/verify-glibc-requirements.sh

  echo "Archiving REH"
  pushd "../vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}"
  tar czf "../assets/${APP_NAME_LC}-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
  popd
fi

if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
  echo "Building REH-web"
  yarn gulp minify-vscode-reh-web
  yarn gulp "vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

  EXPECTED_GLIBC_VERSION="${GLIBC_VERSION}" EXPECTED_GLIBCXX_VERSION="${GLIBCXX_VERSION}" SEARCH_PATH="../vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}" ./build/azure-pipelines/linux/verify-glibc-requirements.sh

  echo "Archiving REH-web"
  pushd "../vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}"
  tar czf "../assets/${APP_NAME_LC}-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .
  popd
fi

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
