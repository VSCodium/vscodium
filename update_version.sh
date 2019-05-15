#!/bin/bash

if [[ "$SHOULD_BUILD" != "yes" ]]; then
  echo "Will not update version JSON because we did not build"
  exit
fi

#  {
#    "url": "https://az764295.vo.msecnd.net/stable/51b0b28134d51361cf996d2f0a1c698247aeabd8/VSCode-darwin-stable.zip",
#    "name": "1.33.1",
#    "version": "51b0b28134d51361cf996d2f0a1c698247aeabd8",
#    "productVersion": "1.33.1",
#    "hash": "cb4109f196d23b9d1e8646ce43145c5bb62f55a8",
#    "timestamp": 1554971059007,
#    "sha256hash": "ac2a1c8772501732cd5ff539a04bb4dc566b58b8528609d2b34bbf970d08cf01"
#  }

# `url` is URL_BASE + filename of asset e.g.
#    darwin: https://github.com/VSCodium/vscodium/releases/download/${LATEST_MS_TAG}/VSCodium-darwin-${LATEST_MS_TAG}.zip
# `name` is $LATEST_MS_TAG
# `version` is $LATEST_MS_COMMIT
# `productVersion` is $LATEST_MS_TAG
# `hash` in <filename>.sha1
# `timestamp` is $(node -e 'console.log(Date.now())')
# `sha256hash` in <filename>.sha256

URL_BASE=https://github.com/VSCodium/vscodium/releases/download/${LATEST_MS_TAG}

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  # zip, sha1, and sha256 files are all at top level dir
  ASSET_PATH=.
  ASSET_NAME=VSCodium-darwin-${LATEST_MS_TAG}.zip
fi

# generate parts
url=${URL_BASE}/${ASSET_NAME}
name=$LATEST_MS_TAG
version=$LATEST_MS_COMMIT
productVersion=$LATEST_MS_TAG
hash=$(cat ${ASSET_PATH}/${ASSET_NAME}.sha1 | awk '{ print $ 1 }')
timestamp=$(node -e 'console.log(Date.now())')
sha256hash=$(cat ${ASSET_PATH}/${ASSET_NAME}.sha256 | awk '{ print $ 1 }')

# generate json
JSON=$(jq \
  --arg url             "${url}" \
  --arg name            "${name}" \
  --arg version         "${version}" \
  --arg productVersion  "${productVersion}" \
  --arg hash            "${hash}" \
  --arg timestamp       "${timestamp}" \
  --arg sha256hash      "${sha256hash}" \
  '. | .url=$url | .name=$name | .version=$version | .productVersion=$productVersion | .hash=$hash | .timestamp=$timestamp | .sha256hash=$sha256hash' \
  <<<'{}')

echo $JSON
