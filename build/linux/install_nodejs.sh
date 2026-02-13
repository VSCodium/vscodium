#!/usr/bin/env bash

set -ex

NODEJS_VERSION=$( cat .nvmrc )

curl -fsSL "${NODEJS_SITE}${NODEJS_URLROOT}/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-${NODEJS_ARCH}${NODEJS_URLSUFFIX}.tar.xz" -o node.tar.xz

tar -xf node.tar.xz

sudo mv "node-v${NODEJS_VERSION}-linux-${NODEJS_ARCH}${NODEJS_URLSUFFIX}" /usr/local/node

echo "/usr/local/node/bin" >> $GITHUB_PATH
