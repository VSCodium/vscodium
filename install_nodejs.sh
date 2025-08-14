#!/usr/bin/env bash

set -ex

NODE_VERSION=$( cat .nvmrc )

curl -L -O "https://unofficial-builds.nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.gz"

tar -xzf "node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.gz"

cp -R node-v${NODE_VERSION}-linux-${NODE_ARCH}/* /usr/local/

rm -rf node-v${NODE_VERSION}-linux-${NODE_ARCH}*

node --version
