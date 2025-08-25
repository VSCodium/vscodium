#!/usr/bin/env bash

#!/usr/bin/env bash
set -euo pipefail

# Generate BUILD_SOURCEVERSION if not already set
if [[ -z "${BUILD_SOURCEVERSION:-}" ]]; then
  SOURCE_INPUT="${RELEASE_VERSION/-*/}"

  if command -v sha1sum &> /dev/null; then
    echo "Using sha1sum to generate BUILD_SOURCEVERSION"
    BUILD_SOURCEVERSION=$(echo -n "${SOURCE_INPUT}" | sha1sum | awk '{print $1}')
  elif command -v openssl &> /dev/null; then
    echo "Using openssl to generate BUILD_SOURCEVERSION"
    BUILD_SOURCEVERSION=$(echo -n "${SOURCE_INPUT}" | openssl dgst -sha1 | awk '{print $2}')
  else
    echo "Using npx checksum as fallback"
    if ! command -v checksum &> /dev/null; then
      npm install checksum --no-save
    fi
    BUILD_SOURCEVERSION=$(npx checksum <<< "${SOURCE_INPUT}")
  fi

  echo "BUILD_SOURCEVERSION=\"${BUILD_SOURCEVERSION}\""

  # Export to GitHub Actions environment if available
  if [[ -n "${GITHUB_ENV:-}" ]]; then
    echo "BUILD_SOURCEVERSION=${BUILD_SOURCEVERSION}" >> "${GITHUB_ENV}"
  fi
fi

export BUILD_SOURCEVERSION
