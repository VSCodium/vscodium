#!/usr/bin/env bash
# Pre-bundle Shadowtrack default extensions into the ShadowIDE build.
#
# Currently bundles upstream Cline (saoudrizwan.claude-dev) from open-vsx.
# We will swap to a Shadowtrack fork ("Shadow Agent") once it exists; this
# script is the integration point.
#
# Run from repo root, AFTER prepare_vscode.sh has finished (so vscode/ exists
# and npm ci has run) and BEFORE the gulp packaging step.

set -euo pipefail

# {{{ pinned versions — bump deliberately, verify on open-vsx.org first
SHADOW_AGENT_PUBLISHER="saoudrizwan"
SHADOW_AGENT_NAME="claude-dev"
SHADOW_AGENT_VERSION="${SHADOW_AGENT_VERSION:-3.17.5}"
# }}}

EXT_CACHE_DIR="${EXT_CACHE_DIR:-./.build/shadowide-extensions}"
VSCODE_EXT_DIR="${VSCODE_EXT_DIR:-./vscode/.build/extensions}"
mkdir -p "${EXT_CACHE_DIR}"

download_vsix() {
  local publisher="$1" name="$2" version="$3"
  local out="${EXT_CACHE_DIR}/${publisher}.${name}-${version}.vsix"
  local url="https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix"

  if [[ -f "${out}" ]]; then
    echo "[ext] cached: ${out}" >&2
    echo "${out}"
    return 0
  fi

  echo "[ext] downloading ${publisher}.${name}@${version} from open-vsx" >&2
  if ! curl -fL --retry 3 --retry-delay 2 -o "${out}" "${url}"; then
    echo "[ext] ERROR: download failed for ${url}" >&2
    rm -f "${out}"
    return 1
  fi
  echo "[ext] downloaded: ${out} ($( wc -c < "${out}" ) bytes)" >&2
  echo "${out}"
}

extract_vsix() {
  local vsix="$1" target_id="$2"
  local target="${VSCODE_EXT_DIR}/${target_id}"

  mkdir -p "${VSCODE_EXT_DIR}"
  rm -rf "${target}"
  local tmp
  tmp="$( mktemp -d )"

  unzip -q "${vsix}" -d "${tmp}"
  if [[ ! -d "${tmp}/extension" ]]; then
    echo "[ext] ERROR: ${vsix} has no extension/ subdir" >&2
    rm -rf "${tmp}"
    return 1
  fi

  mv "${tmp}/extension" "${target}"
  rm -rf "${tmp}"
  echo "[ext] installed: ${target}"
}

vsix_path="$( download_vsix "${SHADOW_AGENT_PUBLISHER}" "${SHADOW_AGENT_NAME}" "${SHADOW_AGENT_VERSION}" )"
extract_vsix "${vsix_path}" "${SHADOW_AGENT_PUBLISHER}.${SHADOW_AGENT_NAME}"

echo "[ext] Shadow Agent (Cline) bundled into ${VSCODE_EXT_DIR}"
