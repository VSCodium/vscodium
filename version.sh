#!/bin/bash

if [[ -z "${BUILD_SOURCEVERSION}" ]]; then

    vscodium_hash=$( git rev-parse HEAD )

    cd vscode
    vscode_hash=$( git rev-parse HEAD )
    cd ..

    if type -t "sha1sum" > /dev/null 2>&1; then
      export BUILD_SOURCEVERSION=$( echo "${vscodium_hash}:${vscode_hash}" | sha1sum | cut -d' ' -f1 )
    else
      npm install -g checksum

      export BUILD_SOURCEVERSION=$( echo "${vscodium_hash}:${vscode_hash}" | checksum )
    fi

    echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\""

    # for GH actions
    if [[ $GITHUB_ENV ]]; then
        echo "BUILD_SOURCEVERSION=$BUILD_SOURCEVERSION" >> $GITHUB_ENV
    fi
fi
