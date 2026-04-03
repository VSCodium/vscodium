#!/usr/bin/env bash

if [[ -n "${CERTIFICATE_OSX_P12_DATA}" ]]; then
  if [[ "${CI_BUILD}" == "no" ]]; then
    RUNNER_TEMP="${TMPDIR}"
  fi

  CERTIFICATE_P12="${APP_NAME}.p12"
  KEYCHAIN="${RUNNER_TEMP}/buildagent.keychain"
  AGENT_TEMPDIRECTORY="${RUNNER_TEMP}"
  # shellcheck disable=SC2006
  KEYCHAINS=`security list-keychains | xargs`

  rm -f "${KEYCHAIN}"

  echo "${CERTIFICATE_OSX_P12_DATA}" | base64 --decode > "${CERTIFICATE_P12}"

  echo "+ create temporary keychain"
  security create-keychain -p pwd "${KEYCHAIN}"
  security set-keychain-settings -lut 21600 "${KEYCHAIN}"
  security unlock-keychain -p pwd "${KEYCHAIN}"
  # shellcheck disable=SC2086
  security list-keychains -s $KEYCHAINS "${KEYCHAIN}"
  # security show-keychain-info "${KEYCHAIN}"

  echo "+ import certificate to keychain"
  security import "${CERTIFICATE_P12}" -k "${KEYCHAIN}" -P "${CERTIFICATE_OSX_P12_PASSWORD}" -T /usr/bin/codesign
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k pwd "${KEYCHAIN}" > /dev/null
  # security find-identity "${KEYCHAIN}"

  CODESIGN_IDENTITY="$( security find-identity -v -p codesigning "${KEYCHAIN}" | grep -oEi "([0-9A-F]{40})" | head -n 1 )"

  echo "+ signing"
  export CODESIGN_IDENTITY AGENT_TEMPDIRECTORY

  DEBUG="electron-osx-sign*" node vscode/build/darwin/sign.ts "$( pwd )"
  # codesign --display --entitlements :- ""

  echo "+ notarize"

  cd "VSCode-darwin-${VSCODE_ARCH}"
  ZIP_FILE="./${APP_NAME}-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip"

  zip -r -X -y "${ZIP_FILE}" ./*.app

  xcrun notarytool store-credentials "${APP_NAME}" --apple-id "${CERTIFICATE_OSX_ID}" --team-id "${CERTIFICATE_OSX_TEAM_ID}" --password "${CERTIFICATE_OSX_APP_PASSWORD}" --keychain "${KEYCHAIN}"
  # xcrun notarytool history --keychain-profile "${APP_NAME}" --keychain "${KEYCHAIN}"
  xcrun notarytool submit "${ZIP_FILE}" --keychain-profile "${APP_NAME}" --wait --keychain "${KEYCHAIN}"

  echo "+ attach staple"
  xcrun stapler staple ./*.app
  # spctl --assess -vv --type install ./*.app

  rm "${ZIP_FILE}"

  cd ..
fi

if [[ "${SHOULD_BUILD_ZIP}" != "no" ]]; then
  echo "Building and moving ZIP"
  cd "VSCode-darwin-${VSCODE_ARCH}"
  zip -r -X -y "../assets/${APP_NAME}-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" ./*.app
  cd ..
fi

if [[ -n "${CERTIFICATE_OSX_P12_DATA}" && "${SHOULD_BUILD_DMG}" != "no" ]]; then
  echo "Building and moving DMG"
  pushd "VSCode-darwin-${VSCODE_ARCH}"
  npx create-dmg ./*.app .
  mv ./*.dmg "../assets/${APP_NAME}.${VSCODE_ARCH}.${RELEASE_VERSION}.dmg"
  popd
fi

if [[ "${SHOULD_BUILD_SRC}" == "yes" ]]; then
  git archive --format tar.gz --output="./assets/${APP_NAME}-${RELEASE_VERSION}-src.tar.gz" HEAD
  git archive --format zip --output="./assets/${APP_NAME}-${RELEASE_VERSION}-src.zip" HEAD
fi

if [[ -n "${CERTIFICATE_OSX_P12_DATA}" ]]; then
  echo "+ clean"
  security delete-keychain "${KEYCHAIN}"
  # shellcheck disable=SC2086
  security list-keychains -s $KEYCHAINS
fi
