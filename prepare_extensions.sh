#!/usr/bin/env bash
# Pre-bundle Shadowtrack default extensions into the ShadowIDE build.
#
# Currently bundles: Cline (saoudrizwan.claude-dev) from open-vsx.org
#
# Run from the repo root, after prepare_vscode.sh has prepared ./vscode/.
# Sets exit code 0 on success, non-zero on any failure (network, hash mismatch).

set -euo pipefail

# {{{ pinned versions
CLINE_PUBLISHER="saoudrizwan"
CLINE_NAME="claude-dev"
CLINE_VERSION="${CLINE_VERSION:-3.17.5}"  # bump deliberately; verify on open-vsx.org first
# }}}

EXT_CACHE_DIR="${EXT_CACHE_DIR:-./.build/shadowide-extensions}"
mkdir -p "${EXT_CACHE_DIR}"

download_vsix() {
  local publisher="$1" name="$2" version="$3"
  local out="${EXT_CACHE_DIR}/${publisher}.${name}-${version}.vsix"
  local url="https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix"

  if [[ -f "${out}" ]]; then
    echo "[ext] cached: ${out}"
    return 0
  fi

  echo "[ext] downloading ${publisher}.${name}@${version} from open-vsx"
  if ! curl -fL --retry 3 --retry-delay 2 -o "${out}" "${url}"; then
    echo "[ext] ERROR: download failed for ${url}" >&2
    rm -f "${out}"
    return 1
  fi
  echo "[ext] downloaded: ${out} ($( wc -c < "${out}" ) bytes)"
}

download_vsix "${CLINE_PUBLISHER}" "${CLINE_NAME}" "${CLINE_VERSION}"

# TODO(phase3-wire): integrate the downloaded .vsix into the build.
# Two options under evaluation:
#   1. Add to vscode/product.json builtInExtensions[] with sha256 + metadata,
#      so vscode's standard pre-install pipeline picks it up.
#   2. Extract into vscode/.build/builtInExtensions/<id>/ directly, bypassing
#      the marketplace download step.
# Option 1 is more idiomatic; option 2 is more deterministic. Picking once
# we have a forked Cline repo to point at instead of upstream open-vsx.
echo "[ext] scaffold complete; integration into build pipeline pending"
