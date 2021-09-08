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
#    darwin: https://github.com/VSCodium/vscodium/releases/download/${MS_TAG}/VSCodium-darwin-${MS_TAG}.zip
# `name` is $MS_TAG
# `version` is $MS_COMMIT
# `productVersion` is $MS_TAG
# `hash` in <filename>.sha1
# `timestamp` is $(node -e 'console.log(Date.now())')
# `sha256hash` in <filename>.sha256

URL_BASE=https://github.com/VSCodium/vscodium/releases/download/${MS_TAG}

# to make testing on forks easier
VERSIONS_REPO="${GITHUB_USERNAME}/versions"
echo "Versions repo:" $VERSIONS_REPO

# generateJson <assetName>
# e.g. generateJson VSCodium-darwin-1.33.0.zip
generateJson() {
  local assetName=$1

  # generate parts
  local url=${URL_BASE}/${assetName}
  local name=$MS_TAG
  local version=$MS_COMMIT
  local productVersion=$MS_TAG
  local timestamp=$(node -e 'console.log(Date.now())')

  local sha1hash=$(cat ${assetName}.sha1 | awk '{ print $1 }')
  local sha256hash=$(cat ${assetName}.sha256 | awk '{ print $1 }')

  # check that nothing is blank (blank indicates something awry with build)
  for key in url name version productVersion sha1hash timestamp sha256hash; do
    if [[ "${!key}" == "" ]]; then
      echo "Missing data for version update; exiting..."
      exit 1
    fi
  done

  # generate json
  local json=$(jq \
    --arg url             "${url}" \
    --arg name            "${name}" \
    --arg version         "${version}" \
    --arg productVersion  "${productVersion}" \
    --arg hash            "${sha1hash}" \
    --arg timestamp       "${timestamp}" \
    --arg sha256hash      "${sha256hash}" \
    '. | .url=$url | .name=$name | .version=$version | .productVersion=$productVersion | .hash=$hash | .timestamp=$timestamp | .sha256hash=$sha256hash' \
    <<<'{}')

  echo "$json"
}

updateLatestVersion() {
  cd versions

  local versionPath=$1
  local json=$2

  # create/update the latest.json file in the correct location
  mkdir -p $versionPath
  echo $json > $versionPath/latest.json

  cd ..
}

# init versions repo for later commiting + pushing the json file to it
# thank you https://www.vinaygopinath.me/blog/tech/commit-to-master-branch-on-github-using-travis-ci/
git clone https://github.com/${VERSIONS_REPO}.git
cd versions
git config user.email "vscodium-ci@not-real.com"
git config user.name "VSCodium CI"
git remote rm origin
git remote add origin https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${VERSIONS_REPO}.git > /dev/null 2>&1
cd ..

if [[ "$OS_NAME" == "osx" ]]; then
  # zip, sha1, and sha256 files are all at top level dir
  ASSET_NAME=VSCodium-darwin-${VSCODE_ARCH}-${MS_TAG}.zip
  VERSION_PATH="darwin/${VSCODE_ARCH}"
  JSON="$(generateJson ${ASSET_NAME})"
  updateLatestVersion "$VERSION_PATH" "$JSON"
elif [[ "$OS_NAME" == "windows" ]]; then
  # system installer
  ASSET_NAME=VSCodiumSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  VERSION_PATH="win32/${VSCODE_ARCH}/system"
  JSON="$(generateJson ${ASSET_NAME})"
  updateLatestVersion "$VERSION_PATH" "$JSON"

  # user installer
  ASSET_NAME=VSCodiumUserSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  VERSION_PATH="win32/${VSCODE_ARCH}/user"
  JSON="$(generateJson ${ASSET_NAME})"
  updateLatestVersion "$VERSION_PATH" "$JSON"

  # windows archive
  ASSET_NAME=VSCodium-win32-${VSCODE_ARCH}-${MS_TAG}.zip
  VERSION_PATH="win32/${VSCODE_ARCH}/archive"
  JSON="$(generateJson ${ASSET_NAME})"
  updateLatestVersion "$VERSION_PATH" "$JSON"
  
  if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
    # msi
    ASSET_NAME=VSCodium-${VSCODE_ARCH}-${MS_TAG}.msi
    VERSION_PATH="win32/${VSCODE_ARCH}/msi"
    JSON="$(generateJson ${ASSET_NAME})"
    updateLatestVersion "$VERSION_PATH" "$JSON"
    
    # updates-disabled msi
    ASSET_NAME=VSCodium-${VSCODE_ARCH}-updates-disabled-${MS_TAG}.msi
    VERSION_PATH="win32/${VSCODE_ARCH}/msi-updates-disabled"
    JSON="$(generateJson ${ASSET_NAME})"
    updateLatestVersion "$VERSION_PATH" "$JSON"
  fi
else # linux
  # update service links to tar.gz file
  # see https://update.code.visualstudio.com/api/update/linux-x64/stable/VERSION
  # as examples
  ASSET_NAME=VSCodium-linux-${VSCODE_ARCH}-${MS_TAG}.tar.gz
  VERSION_PATH="linux/${VSCODE_ARCH}"
  JSON="$(generateJson ${ASSET_NAME})"
  updateLatestVersion "$VERSION_PATH" "$JSON"
fi

cd versions

git pull origin master # in case another build just pushed
git add .
dateAndMonth=`date "+%D %T"`
git commit -m "CI update: $dateAndMonth (Build $GITHUB_RUN_NUMBER)"
if ! git push origin master --quiet; then
  git pull origin master
  git push origin master --quiet
fi

cd ..
