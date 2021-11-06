#!/bin/bash

set -e

if [[ -z "${GH_CLI_TOKEN}" ]]; then
  echo "Will not release because no GH_CLI_TOKEN defined"
  exit
fi

echo "${GH_CLI_TOKEN}" | gh auth login --with-token

if [[ $( gh release view "${MS_TAG}" 2>&1 ) =~ "release not found" ]]; then
  echo "Creating release '${MS_TAG}'"
  gh release create "${MS_TAG}"
fi

cd artifacts

set +e

for FILE in *
do
  if [[ -f "${FILE}" ]] && [[ "${FILE}" != *.sha1 ]] && [[ "${FILE}" != *.sha256 ]]; then
    echo "Uploading '${FILE}'"
    gh release upload "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256"

    if [[ $? != 0 ]]; then
      for (( i=0; i<10; i++ ))
      do
        sleep $(( 15 * (i + 1)))

        echo "RE-Uploading '${FILE}'"
        gh release upload "${MS_TAG}" "${FILE}" "${FILE}.sha1" "${FILE}.sha256" --clobber

        if [[ $? == 0 ]]; then
          break
        fi
      done

      if [[ $? != 0 ]]; then
        echo "'${FILE}' hasn't been uploaded!"
        exit 1
      fi
    fi
  fi
done

cd ..
