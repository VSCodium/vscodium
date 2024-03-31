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

if [[ -d "../patches/${OS_NAME}/client/" ]]; then
  for file in "../patches/${OS_NAME}/client/"*.patch; do
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

./build/azure-pipelines/linux/setup-env.sh

node build/azure-pipelines/distro/mixin-npm

yarn gulp "vscode-linux-${VSCODE_ARCH}-min-ci"

find "../VSCode-linux-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

cd ..
