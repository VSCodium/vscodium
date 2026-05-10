#!/usr/bin/env bash
# Pre-bundle Shadowtrack default extensions into the ShadowIDE build.
#
# Strategy (the "bootstrap" pattern):
#   - Cline is NOT shipped as a built-in extension (built-ins can't be updated
#     by the user, which left them stranded when Cline's server-side version
#     check rejected our pinned version).
#   - Instead we ship a tiny "shadowide-bootstrap" built-in extension that
#     bundles Cline's .vsix and installs it on first launch. Once installed
#     it lives as a normal user extension with the Update button intact.
#
# Run from repo root, AFTER prepare_vscode.sh has finished and AFTER the
# gulp prepack step (which recreates .build/extensions). See build.sh.

set -euo pipefail

# {{{ pinned versions — bump deliberately, verify on open-vsx.org first
SHADOW_AGENT_PUBLISHER="saoudrizwan"
SHADOW_AGENT_NAME="claude-dev"
SHADOW_AGENT_VERSION="${SHADOW_AGENT_VERSION:-3.82.0}"
# }}}

EXT_CACHE_DIR="${EXT_CACHE_DIR:-./.build/shadowide-extensions}"
VSCODE_EXT_DIR="${VSCODE_EXT_DIR:-./vscode/.build/extensions}"
BOOTSTRAP_DIR="${VSCODE_EXT_DIR}/shadowide-bootstrap"
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

build_bootstrap_extension() {
  local cline_vsix="$1"

  rm -rf "${BOOTSTRAP_DIR}"
  mkdir -p "${BOOTSTRAP_DIR}"

  # Tiny built-in extension: on first launch, installs the bundled Cline .vsix
  # if Cline isn't already present. After that, Cline auto-updates from
  # open-vsx through the normal extension flow.
  cat > "${BOOTSTRAP_DIR}/package.json" <<'EOF'
{
  "name": "shadowide-bootstrap",
  "displayName": "ShadowIDE Bootstrap",
  "description": "Installs Shadowtrack default extensions on first launch",
  "version": "0.0.1",
  "publisher": "shadowtrack",
  "engines": { "vscode": "^1.0.0" },
  "main": "./extension.js",
  "activationEvents": ["onStartupFinished"],
  "categories": ["Other"]
}
EOF

  cat > "${BOOTSTRAP_DIR}/extension.js" <<'EOF'
const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

const TARGET_ID = 'saoudrizwan.claude-dev';
const VSIX_FILENAME = 'shadow-agent.vsix';
const STATE_KEY = 'shadowide.bootstrap.clineInstalled';

async function activate(context) {
  // Already installed? Nothing to do.
  if (vscode.extensions.getExtension(TARGET_ID)) {
    return;
  }
  // We've installed it once before; user removed it deliberately. Don't fight them.
  if (context.globalState.get(STATE_KEY)) {
    return;
  }

  const vsixPath = path.join(context.extensionPath, VSIX_FILENAME);
  if (!fs.existsSync(vsixPath)) {
    console.error('[ShadowIDE] bundled Cline .vsix not found at', vsixPath);
    return;
  }

  try {
    await vscode.window.withProgress(
      { location: vscode.ProgressLocation.Notification, title: 'Setting up Shadow Agent…' },
      async () => {
        await vscode.commands.executeCommand(
          'workbench.extensions.installExtension',
          vscode.Uri.file(vsixPath)
        );
      }
    );
    await context.globalState.update(STATE_KEY, true);

    const choice = await vscode.window.showInformationMessage(
      'Shadow Agent is ready. Reload to activate it.',
      'Reload Window'
    );
    if (choice === 'Reload Window') {
      await vscode.commands.executeCommand('workbench.action.reloadWindow');
    }
  } catch (err) {
    console.error('[ShadowIDE] Failed to install Cline:', err);
    vscode.window.showErrorMessage('Shadow Agent setup failed: ' + (err && err.message || err));
  }
}

function deactivate() {}

module.exports = { activate, deactivate };
EOF

  # Filename must match VSIX_FILENAME in extension.js above.
  cp "${cline_vsix}" "${BOOTSTRAP_DIR}/shadow-agent.vsix"
  echo "[ext] bootstrap extension built at ${BOOTSTRAP_DIR}"
}

# Remove any prior built-in Cline drop from earlier (built-in) approach.
rm -rf "${VSCODE_EXT_DIR}/${SHADOW_AGENT_PUBLISHER}.${SHADOW_AGENT_NAME}"

vsix_path="$( download_vsix "${SHADOW_AGENT_PUBLISHER}" "${SHADOW_AGENT_NAME}" "${SHADOW_AGENT_VERSION}" )"
build_bootstrap_extension "${vsix_path}"

echo "[ext] Shadow Agent bootstrap (Cline ${SHADOW_AGENT_VERSION}) bundled into ${VSCODE_EXT_DIR}"
