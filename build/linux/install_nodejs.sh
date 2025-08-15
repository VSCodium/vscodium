#!/usr/bin/env bash

set -ex

NODEJS_VERSION=$( cat .nvmrc )

curl --silent --fail -L -O "${NODEJS_SITE}${NODEJS_URLROOT}/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-${NODEJS_ARCH}${NODEJS_URLSUFFIX}.tar.gz"

tar -xzf "node-v${NODEJS_VERSION}-linux-${NODEJS_ARCH}.tar.gz"

cp -R node-v${NODEJS_VERSION}-linux-${NODEJS_ARCH}/* /usr/local/

rm -rf node-v${NODEJS_VERSION}-linux-${NODEJS_ARCH}*

node --version
