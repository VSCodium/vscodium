#!/bin/bash

if [[ -z "${BUILD_SOURCEVERSION}" ]]; then

    APP_HASH=$( git rev-parse HEAD )

    cd vscode
    VSCODE_HASH=$( git rev-parse HEAD )
    cd ..

    if type -t "sha1sum" > /dev/null 2>&1; then
      export BUILD_SOURCEVERSION=$( echo "${APP_HASH}:${VSCODE_HASH}" | sha1sum | cut -d' ' -f1 )
    else
      npm install -g checksum

      export BUILD_SOURCEVERSION=$( echo "${APP_HASH}:${VSCODE_HASH}" | checksum )
    fi

    echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\""

    # for GH actions
    if [[ $GITHUB_ENV ]]; then
        echo "BUILD_SOURCEVERSION=$BUILD_SOURCEVERSION" >> $GITHUB_ENV
    fi
fi
