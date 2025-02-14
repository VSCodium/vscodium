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

GLIBC_VERSION="2.28"
GLIBCXX_VERSION="3.4.26"
NODE_VERSION="20.18.1"

export VSCODE_NODEJS_URLROOT='/download/release'
export VSCODE_NODEJS_URLSUFFIX=''

if [[ "${VSCODE_ARCH}" == "x64" ]]; then
  GLIBC_VERSION="2.17"
  GLIBCXX_VERSION="3.4.22"
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:centos7-devtoolset8-${VSCODE_ARCH}"

  export VSCODE_NODEJS_SITE='https://unofficial-builds.nodejs.org'
  export VSCODE_NODEJS_URLSUFFIX='-glibc-217'
elif [[ "${VSCODE_ARCH}" == "arm64" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:centos7-devtoolset8-${VSCODE_ARCH}"

  export VSCODE_SKIP_SYSROOT=1
  export USE_GNUPP2A=1
elif [[ "${VSCODE_ARCH}" == "armhf" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:bionic-devtoolset-arm32v7"

  export VSCODE_SKIP_SYSROOT=1
  export USE_GNUPP2A=1
elif [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:bionic-devtoolset-ppc64le"

  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  export VSCODE_SYSROOT_REPOSITORY='VSCodium/vscode-linux-build-agent'
  export VSCODE_SYSROOT_VERSION='20240129-253798'
  export USE_GNUPP2A=1
elif [[ "${VSCODE_ARCH}" == "riscv64" ]]; then
  NODE_VERSION="20.16.0"
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:focal-devtoolset-riscv64"

  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  export VSCODE_SKIP_SETUPENV=1
  export VSCODE_NODEJS_SITE='https://unofficial-builds.nodejs.org'
elif [[ "${VSCODE_ARCH}" == "loong64" ]]; then
  NODE_VERSION="20.16.0"
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:trixie-devtoolset-loong64"

  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  export VSCODE_SKIP_SETUPENV=1
  export VSCODE_NODEJS_SITE='https://unofficial-builds.nodejs.org'
elif [[ "${VSCODE_ARCH}" == "s390x" ]]; then
  VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME="vscodium/vscodium-linux-build-agent:focal-devtoolset-s390x"

  export ELECTRON_SKIP_BINARY_DOWNLOAD=1
  export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
  export VSCODE_SYSROOT_REPOSITORY='VSCodium/vscode-linux-build-agent'
  export VSCODE_SYSROOT_VERSION='20241108'
fi

export VSCODE_PLATFORM='linux'
export VSCODE_SKIP_NODE_VERSION_CHECK=1
export VSCODE_SYSROOT_PREFIX="-glibc-${GLIBC_VERSION}"

VSCODE_HOST_MOUNT="$( pwd )"

export VSCODE_HOST_MOUNT
export VSCODE_REMOTE_DEPENDENCIES_CONTAINER_NAME

sed -i "/target/s/\"20.*\"/\"${NODE_VERSION}\"/" remote/.npmrc

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

if [[ -d "../patches/linux/reh/${VSCODE_ARCH}/" ]]; then
  for file in "../patches/linux/reh/${VSCODE_ARCH}/"*.patch; do
    if [[ -f "${file}" ]]; then
      echo applying patch: "${file}";
      if ! git apply --ignore-whitespace "${file}"; then
        echo failed to apply patch "${file}" >&2
        exit 1
      fi
    fi
  done
fi

if [[ -n "${USE_GNUPP2A}" ]]; then
  INCLUDES=$(cat <<EOF
{
  "target_defaults": {
    "conditions": [
      ["OS=='linux'", {
        'cflags_cc!': [ '-std=gnu++20' ],
        'cflags_cc': [ '-std=gnu++2a' ],
      }]
    ]
  }
}
EOF
)

  if [ ! -d "${HOME}/.gyp" ]; then
    mkdir -p "${HOME}/.gyp"
  fi

  echo "${INCLUDES}" > "${HOME}/.gyp/include.gypi"
fi

for i in {1..5}; do # try 5 times
  npm ci --prefix build && break
  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

if [[ -z "${VSCODE_SKIP_SETUPENV}" ]]; then
  if [[ -n "${VSCODE_SKIP_SYSROOT}" ]]; then
    source ./build/azure-pipelines/linux/setup-env.sh --skip-sysroot
  else
    source ./build/azure-pipelines/linux/setup-env.sh
  fi
fi

for i in {1..5}; do # try 5 times
  npm ci && break
  if [[ $i == 3 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."

  # remove dependencies that fail during cleanup
  rm -rf node_modules/@vscode node_modules/node-pty
done

node build/azure-pipelines/distro/mixin-npm

export VSCODE_NODE_GLIBC="-glibc-${GLIBC_VERSION}"

if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
  echo "Building REH"
  yarn gulp minify-vscode-reh
  yarn gulp "vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

  EXPECTED_GLIBC_VERSION="${GLIBC_VERSION}" EXPECTED_GLIBCXX_VERSION="${GLIBCXX_VERSION}" SEARCH_PATH="../vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}" ./build/azure-pipelines/linux/verify-glibc-requirements.sh

  pushd "../vscode-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}"

  if [[ -f "../ripgrep_${VSCODE_PLATFORM}_${VSCODE_ARCH}.sh" ]]; then
    bash "../ripgrep_${VSCODE_PLATFORM}_${VSCODE_ARCH}.sh" "node_modules"
  fi

  echo "Archiving REH"
  tar czf "../assets/${APP_NAME_LC}-reh-${VSCODE_PLATFORM}-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" .

  popd
fi

if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
  echo "Building REH-web"
  yarn gulp minify-vscode-reh-web
  yarn gulp "vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}-min-ci"

  EXPECTED_GLIBC_VERSION="${GLIBC_VERSION}" EXPECTED_GLIBCXX_VERSION="${GLIBCXX_VERSION}" SEARCH_PATH="../vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}" ./build/azure-pipelines/linux/verify-glibc-requirements.sh

  pushd "../vscode-reh-web-${VSCODE_PLATFORM}-${VSCODE_ARCH}"

  if [[ -f "../ripgrep_${VSCODE_PLATFORM}_${VSCODE_ARCH}.sh" ]]; then
    bash "../ripgrep_${VSCODE_PLATFORM}_${VSCODE_ARCH}.sh" "node_modules"
  fi

  echo "Archiving REH-web"
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
