#!/usr/bin/env bash

if [[ -z "${BUILD_SOURCEVERSION}" ]]; then

    if type -t "sha1sum" &> /dev/null; then
      BUILD_SOURCEVERSION=$( echo "${RELEASE_VERSION/-*/}" | sha1sum | cut -d' ' -f1 )
    else
      npm install -g checksum

      BUILD_SOURCEVERSION=$( echo "${RELEASE_VERSION/-*/}" | checksum )
    fi

    echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\""

    # for GH actions
    if [[ "${GITHUB_ENV}" ]]; then
        echo "BUILD_SOURCEVERSION=${BUILD_SOURCEVERSION}" >> "${GITHUB_ENV}"
    fi
fi

export BUILD_SOURCEVERSION
