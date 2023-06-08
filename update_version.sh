#!/bin/bash

set -e

if [[ "${SHOULD_BUILD}" != "yes" && "${FORCE_UPDATE}" != "true" ]]; then
  echo "Will not update version JSON because we did not build"
  exit
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Will not update version JSON because no GITHUB_TOKEN defined"
  exit
fi

if [[ "${FORCE_UPDATE}" == "true" ]]; then
  . version.sh
fi

if [[ -z "${BUILD_SOURCEVERSION}" ]]; then
  echo "Will not update version JSON because no BUILD_SOURCEVERSION defined"
  exit
fi

if [[ "${VSCODE_ARCH}" == "ppc64le" ]]; then
  echo "Skip ppc64le since only reh is published"
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
#    darwin: https://github.com/${ASSETS_REPOSITORY}/releases/download/${RELEASE_VERSION}/${APP_NAME}-darwin-${RELEASE_VERSION}.zip
# `name` is $RELEASE_VERSION
# `version` is $BUILD_SOURCEVERSION
# `productVersion` is $RELEASE_VERSION
# `hash` in <filename>.sha1
# `timestamp` is $(node -e 'console.log(Date.now())')
# `sha256hash` in <filename>.sha256

REPOSITORY_NAME="${VERSIONS_REPOSITORY/*\//}"
URL_BASE="https://github.com/${ASSETS_REPOSITORY}/releases/download/${RELEASE_VERSION}"

generateJson() {
  JSON_DATA="{}"

  # generate parts
  local url="${URL_BASE}/${ASSET_NAME}"
  local name="${RELEASE_VERSION}"
  local version="${BUILD_SOURCEVERSION}"
  local productVersion="${RELEASE_VERSION}"
  local timestamp=$(node -e 'console.log(Date.now())')

  if [[ ! -f "assets/${ASSET_NAME}" ]]; then
    echo "Downloading asset '${ASSET_NAME}'"
    gh release download --repo "${ASSETS_REPOSITORY}" "${RELEASE_VERSION}" --dir "assets" --pattern "${ASSET_NAME}*"
  fi

  local sha1hash=$(cat "assets/${ASSET_NAME}.sha1" | awk '{ print $1 }')
  local sha256hash=$(cat "assets/${ASSET_NAME}.sha256" | awk '{ print $1 }')

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

  # do not update the same version
  if [[ -f "versions/${VERSION_PATH}/latest.json" ]]; then
    CURRENT_VERSION=$( jq -r '.name' "versions/${VERSION_PATH}/latest.json" )

    if [[ "${CURRENT_VERSION}" == "${RELEASE_VERSION}" && "${FORCE_UPDATE}" != "true" ]]; then
      return
    fi
  fi

  mkdir -p "versions/${VERSION_PATH}"

  generateJson

  echo "${JSON_DATA}" > "versions/${VERSION_PATH}/latest.json"
}

# init versions repo for later commiting + pushing the json file to it
# thank you https://www.vinaygopinath.me/blog/tech/commit-to-master-branch-on-github-using-travis-ci/
git clone "https://github.com/${VERSIONS_REPOSITORY}.git"
cd "${REPOSITORY_NAME}" || { echo "'${REPOSITORY_NAME}' dir not found"; exit 1; }
git config user.email "$( echo "${GITHUB_USERNAME}" | awk '{print tolower($0)}' )-ci@not-real.com"
git config user.name "${GITHUB_USERNAME} CI"
git remote rm origin
git remote add origin "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${VERSIONS_REPOSITORY}.git" > /dev/null 2>&1
cd ..

if [[ "${OS_NAME}" == "osx" ]]; then
  ASSET_NAME="${APP_NAME}-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip"
  VERSION_PATH="${VSCODE_QUALITY}/darwin/${VSCODE_ARCH}"
  updateLatestVersion
elif [[ "${OS_NAME}" == "windows" ]]; then
  # system installer
  ASSET_NAME="${APP_NAME}Setup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
  VERSION_PATH="${VSCODE_QUALITY}/win32/${VSCODE_ARCH}/system"
  updateLatestVersion

  # user installer
  ASSET_NAME="${APP_NAME}UserSetup-${VSCODE_ARCH}-${RELEASE_VERSION}.exe"
  VERSION_PATH="${VSCODE_QUALITY}/win32/${VSCODE_ARCH}/user"
  updateLatestVersion

  # windows archive
  ASSET_NAME="${APP_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip"
  VERSION_PATH="${VSCODE_QUALITY}/win32/${VSCODE_ARCH}/archive"
  updateLatestVersion

  if [[ "${VSCODE_ARCH}" == "ia32" || "${VSCODE_ARCH}" == "x64" ]]; then
    # msi
    ASSET_NAME="${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}.msi"
    VERSION_PATH="${VSCODE_QUALITY}/win32/${VSCODE_ARCH}/msi"
    updateLatestVersion

    # updates-disabled msi
    ASSET_NAME="${APP_NAME}-${VSCODE_ARCH}-updates-disabled-${RELEASE_VERSION}.msi"
    VERSION_PATH="${VSCODE_QUALITY}/win32/${VSCODE_ARCH}/msi-updates-disabled"
    updateLatestVersion
  fi
else # linux
  # update service links to tar.gz file
  # see https://update.code.visualstudio.com/api/update/linux-x64/stable/VERSION
  # as examples
  ASSET_NAME="${APP_NAME}-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz"
  VERSION_PATH="${VSCODE_QUALITY}/linux/${VSCODE_ARCH}"
  updateLatestVersion
fi

cd "${REPOSITORY_NAME}" || { echo "'${REPOSITORY_NAME}' dir not found"; exit 1; }

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
