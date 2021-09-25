#!/bin/bash

set -e

if [[ "${SHOULD_BUILD}" != "yes" ]]; then
  echo "Will not update version JSON because we did not build"
  exit
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not update version JSON because no GITHUB_TOKEN defined"
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

URL_BASE="https://github.com/VSCodium/vscodium/releases/download/${MS_TAG}"

# to make testing on forks easier
VERSIONS_REPO="${GITHUB_USERNAME}/versions"
echo "Versions repo: ${VERSIONS_REPO}"

generateJson() {
  JSON_DATA="{}"

  # generate parts
  local url="${URL_BASE}/${ASSET_NAME}"
  local name="${MS_TAG}"
  local version="${MS_COMMIT}"
  local productVersion="${MS_TAG}"
  local timestamp=$(node -e 'console.log(Date.now())')

  if [[ ! -f "artifacts/${ASSET_NAME}" ]]; then
    echo "Downloading artifact '${ASSET_NAME}'"
    gh release download "${MS_TAG}" --dir "artifacts" --pattern "${ASSET_NAME}*"
  fi

  local sha1hash=$(cat "artifacts/${ASSET_NAME}.sha1" | awk '{ print $1 }')
  local sha256hash=$(cat "artifacts/${ASSET_NAME}.sha256" | awk '{ print $1 }')

  # check that nothing is blank (blank indicates something awry with build)
  for key in url name version productVersion sha1hash timestamp sha256hash; do
    if [[ -z "${key}" ]]; then
      echo "Variable '${key}' is empty; exiting..."
      exit 1
    fi
  done

  # generate json
  JSON_DATA=$(jq \
    --arg url             "${url}" \
    --arg name            "${name}" \
    --arg version         "${version}" \
    --arg productVersion  "${productVersion}" \
    --arg hash            "${sha1hash}" \
    --arg timestamp       "${timestamp}" \
    --arg sha256hash      "${sha256hash}" \
    '. | .url=$url | .name=$name | .version=$version | .productVersion=$productVersion | .hash=$hash | .timestamp=$timestamp | .sha256hash=$sha256hash' \
    <<<'{}')
}

updateLatestVersion() {
  echo "Generating ${VERSION_PATH}/latest.json"

  generateJson

  cd versions

  # create/update the latest.json file in the correct location
  mkdir -p "${VERSION_PATH}"
  echo "${JSON_DATA}" > "${VERSION_PATH}/latest.json"

  cd ..
}

# init versions repo for later commiting + pushing the json file to it
# thank you https://www.vinaygopinath.me/blog/tech/commit-to-master-branch-on-github-using-travis-ci/
git clone "https://github.com/${VERSIONS_REPO}.git"
cd versions
git config user.email "vscodium-ci@not-real.com"
git config user.name "VSCodium CI"
git remote rm origin
git remote add origin "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${VERSIONS_REPO}.git" > /dev/null 2>&1
cd ..

if [[ "${OS_NAME}" == "osx" ]]; then
  ASSET_NAME=VSCodium-darwin-${VSCODE_ARCH}-${MS_TAG}.zip
  VERSION_PATH="darwin/${VSCODE_ARCH}"
  updateLatestVersion
elif [[ "${OS_NAME}" == "windows" ]]; then
  # system installer
  ASSET_NAME=VSCodiumSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  VERSION_PATH="win32/${VSCODE_ARCH}/system"
  updateLatestVersion

  # user installer
  ASSET_NAME=VSCodiumUserSetup-${VSCODE_ARCH}-${MS_TAG}.exe
  VERSION_PATH="win32/${VSCODE_ARCH}/user"
  updateLatestVersion

  # windows archive
  ASSET_NAME=VSCodium-win32-${VSCODE_ARCH}-${MS_TAG}.zip
  VERSION_PATH="win32/${VSCODE_ARCH}/archive"
  updateLatestVersion

  if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
    # msi
    ASSET_NAME=VSCodium-${VSCODE_ARCH}-${MS_TAG}.msi
    VERSION_PATH="win32/${VSCODE_ARCH}/msi"
    updateLatestVersion

    # updates-disabled msi
    ASSET_NAME=VSCodium-${VSCODE_ARCH}-updates-disabled-${MS_TAG}.msi
    VERSION_PATH="win32/${VSCODE_ARCH}/msi-updates-disabled"
    updateLatestVersion
  fi
else # linux
  # update service links to tar.gz file
  # see https://update.code.visualstudio.com/api/update/linux-x64/stable/VERSION
  # as examples
  ASSET_NAME=VSCodium-linux-${VSCODE_ARCH}-${MS_TAG}.tar.gz
  VERSION_PATH="linux/${VSCODE_ARCH}"
  updateLatestVersion
fi

cd versions

git pull origin master # in case another build just pushed
git add .

CHANGES=$( git status --porcelain )

if [[ ! -z "${CHANGES}" ]]; then
  dateAndMonth=$( date "+%D %T" )
  git commit -m "CI update: ${dateAndMonth} (Build ${GITHUB_RUN_NUMBER})"
  if ! git push origin master --quiet; then
    git pull origin master
    git push origin master --quiet
  fi
fi

cd ..
