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
  VERSION_PATH="darwin"
elif [[ "$CI_WINDOWS" == "True" ]]; then
  # TODO: make this logic work for Windows builds too
  # or re-implement it in PowerShell and call that from the Windows build
  exit
else # linux
  # update service links to tar.gz file
  # see https://update.code.visualstudio.com/api/update/linux-x64/stable/VERSION
  # and https://update.code.visualstudio.com/api/update/linux-ia32/stable/VERSION
  # as examples
  ASSET_PATH=.
  ASSET_NAME=VSCodium-linux-${BUILD_ARCH}-${LATEST_MS_TAG}.tar.gz
  VERSION_PATH="linux-${BUILD_ARCH}"
fi

# generate parts
url=${URL_BASE}/${ASSET_NAME}
name=$LATEST_MS_TAG
version=$LATEST_MS_COMMIT
productVersion=$LATEST_MS_TAG
sha1hash=$(cat ${ASSET_PATH}/${ASSET_NAME}.sha1 | awk '{ print $ 1 }')
timestamp=$(node -e 'console.log(Date.now())')
sha256hash=$(cat ${ASSET_PATH}/${ASSET_NAME}.sha256 | awk '{ print $ 1 }')

# check that nothing is blank (blank indicates something awry with build)
for key in url name version productVersion sha1hash timestamp sha256hash do
  if [[ "$key" == "" ]]; then
    echo "Missing data for version update; exiting..."
    exit 1
done

# generate json
JSON=$(jq \
  --arg url             "${url}" \
  --arg name            "${name}" \
  --arg version         "${version}" \
  --arg productVersion  "${productVersion}" \
  --arg hash            "${sha1hash}" \
  --arg timestamp       "${timestamp}" \
  --arg sha256hash      "${sha256hash}" \
  '. | .url=$url | .name=$name | .version=$version | .productVersion=$productVersion | .hash=$hash | .timestamp=$timestamp | .sha256hash=$sha256hash' \
  <<<'{}')

echo $JSON

# clone down the current versions repo
# create/update the latest.json file in the correct location
# commit and push (thank you https://www.vinaygopinath.me/blog/tech/commit-to-master-branch-on-github-using-travis-ci/)
git clone https://github.com/VSCodium/versions.git
cd versions
git config user.email "travis@travis-ci.org"
git config user.name "Travis CI"
mkdir -p $VERSION_PATH
echo $JSON > $VERSION_PATH/latest.json
git add $VERSION_PATH
dateAndMonth=`date "+%D %T"`
git commit -m "Travis update: $dateAndMonth (Build $TRAVIS_BUILD_NUMBER)"
git remote rm origin
git remote add origin https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/VSCodium/versions.git > /dev/null 2>&1
git push origin master --quiet
