#!/bin/bash

# thanks to https://www.jviotti.com/2016/03/16/how-to-code-sign-os-x-electron-apps-in-travis-ci.html
# for the helpful instructions
# if [[ "$SHOULD_BUILD" == "yes" ]]; then
#   if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
#     if [ -d "VSCode-darwin" ]; then # just in case the build failed
#       cd VSCode-darwin
#       export CERTIFICATE_P12=VSCodium.p12
#       echo $CERTIFICATE_OSX_P12 | base64 --decode > $CERTIFICATE_P12
#       export KEYCHAIN=build.keychain
#       security create-keychain -p mysecretpassword $KEYCHAIN
#       security default-keychain -s $KEYCHAIN
#       security unlock-keychain -p mysecretpassword $KEYCHAIN
#       security import $CERTIFICATE_P12 -k $KEYCHAIN -P $CERTIFICATE_OSX_PASSWORD -T /usr/bin/codesign
#       
#       # https://docs.travis-ci.com/user/common-build-problems/
#       security set-key-partition-list -S apple-tool:,apple: -s -k mysecretpassword $KEYCHAIN
#       
#       codesign --deep --force --verbose --sign "$CERTIFICATE_OSX_ID" VSCodium.app
#     fi
#   fi
# fi
