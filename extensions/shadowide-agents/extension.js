// ShadowIDE Agents Window — MVP
//
// Activity bar icon → sidebar panel with "Open Agents Window" button + default
// target selector. The panel also wires a status bar item and an editor/title
// icon button, all pointing at the same command.
//
// Prerequisites: the `kanban` binary must be on PATH at runtime. Install via
// `npm i -g kanban`. A future iteration will bundle it inside the extension.

const vscode = require('vscode');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const COMMAND_ID = 'shadowide.openAgentsWindow';
const PREVIEW_COMMAND_ID = 'shadowide.previewAgentsDesign';
const PREVIEW_PANEL_VIEW_TYPE = 'shadowide.agentsWindowPreview';
const VIEW_ID = 'shadowide.agentsView';
const CONFIG_KEY = 'shadowide.agentsWindowTarget';
const URL_PATTERN = /(https?:\/\/127\.0\.0\.1:\d+(\/[\w\-\/]*)?)/;

let activeProc = null;

// ── kanban process ───────────────────────────────────────────────────────────

function findKanbanBinary() {
  return ['kanban', '/opt/homebrew/bin/kanban', '/usr/local/bin/kanban'];
}

async function spawnKanban(workspaceFolder) {
  for (const bin of findKanbanBinary()) {
    try {
      const proc = spawn(bin, ['--no-open', '--port', 'auto'], {
        cwd: workspaceFolder || process.env.HOME,
        env: { ...process.env, PATH: `/opt/homebrew/bin:/usr/local/bin:${process.env.PATH || ''}` },
      });

      const url = await new Promise((resolve, reject) => {
        let buf = '';
        const timer = setTimeout(() => reject(new Error('kanban did not print URL within 10s')), 10_000);
        proc.on('error', (err) => { clearTimeout(timer); reject(err); });
        proc.stdout.on('data', (chunk) => {
          buf += chunk.toString();
          const m = buf.match(URL_PATTERN);
          if (m) { clearTimeout(timer); resolve(m[1]); }
        });
        proc.stderr.on('data', (chunk) => { buf += chunk.toString(); });
        proc.on('exit', (code) => {
          if (code !== null && code !== 0) {
            clearTimeout(timer);
            reject(new Error(`kanban exited with code ${code}\n${buf}`));
          }
        });
      });

      return { proc, url };
    } catch (err) {
      if (err && err.code === 'ENOENT') continue;
      throw err;
    }
  }
  throw new Error('kanban binary not found. Install with `npm install -g kanban` then retry.');
}

// ── open helpers ─────────────────────────────────────────────────────────────

async function openInSimpleBrowser(url) {
  try {
    await vscode.commands.executeCommand('simpleBrowser.api.open', vscode.Uri.parse(url), { viewColumn: vscode.ViewColumn.Active });
    return 'simple-browser';
  } catch (_) {}
  try {
    await vscode.commands.executeCommand('simpleBrowser.show', url);
    return 'simple-browser';
  } catch (_) {}
  await vscode.env.openExternal(vscode.Uri.parse(url));
  return 'external-browser';
}

async function resolveTarget() {
  const stored = vscode.workspace.getConfiguration().get(CONFIG_KEY, 'ask');
  if (stored !== 'ask') return stored;

  const SEP = vscode.QuickPickItemKind ? vscode.QuickPickItemKind.Separator : -1;
  const items = [
    { label: '$(browser) Simple Browser', description: 'Open inside ShadowIDE as an embedded panel', target: 'simpleBrowser' },
    { label: '$(link-external) External Browser', description: "Open in your system's default browser", target: 'externalBrowser' },
    { kind: SEP, label: 'Set as default' },
    { label: '$(settings-gear) Always use Simple Browser', description: 'Save — no more picker', target: 'setDefault:simpleBrowser' },
    { label: '$(settings-gear) Always use External Browser', description: 'Save — no more picker', target: 'setDefault:externalBrowser' },
  ];

  const pick = await vscode.window.showQuickPick(items, {
    title: 'Shadow Agents — Open in…',
    placeHolder: 'Choose where to open (or pick a default to save for next time)',
    matchOnDescription: true,
  });
  if (!pick) return null;

  if (pick.target.startsWith('setDefault:')) {
    const t = pick.target.slice('setDefault:'.length);
    await vscode.workspace.getConfiguration().update(CONFIG_KEY, t, vscode.ConfigurationTarget.Global);
    vscode.window.showInformationMessage(`Shadow Agents default set to: ${t === 'simpleBrowser' ? 'Simple Browser' : 'External Browser'}.`);
    return t;
  }
  return pick.target;
}

async function openAgentsWindow() {
  const target = await resolveTarget();
  if (!target) return;

  let url;
  if (activeProc && activeProc.lastUrl) {
    url = activeProc.lastUrl;
  } else {
    let result;
    try {
      const folder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
      result = await vscode.window.withProgress(
        { location: vscode.ProgressLocation.Notification, title: 'Starting ShadowIDE Agents…' },
        () => spawnKanban(folder)
      );
    } catch (err) {
      vscode.window.showErrorMessage(`Could not start Agents Window: ${err.message || err}`);
      return;
    }
    const { proc, url: spawnedUrl } = result;
    proc.lastUrl = spawnedUrl;
    activeProc = proc;
    proc.on('exit', () => { if (activeProc === proc) activeProc = null; });
    url = spawnedUrl;
  }

  if (target === 'externalBrowser') {
    await vscode.env.openExternal(vscode.Uri.parse(url));
  } else {
    const where = await openInSimpleBrowser(url);
    if (where === 'external-browser') {
      vscode.window.showInformationMessage('Opened Shadow Agents in your default browser (Simple Browser unavailable).');
    }
  }
}

// ── sidebar panel (activity bar) ─────────────────────────────────────────────

class AgentsViewProvider {
  constructor() { this._view = null; }

  resolveWebviewView(webviewView) {
    this._view = webviewView;
    webviewView.webview.options = { enableScripts: true };
    webviewView.webview.html = this._html();

    // Push current setting into the webview once it loads
    const syncTarget = () => {
      const v = vscode.workspace.getConfiguration().get(CONFIG_KEY, 'ask');
      webviewView.webview.postMessage({ type: 'init', target: v });
    };
    syncTarget();

    webviewView.webview.onDidReceiveMessage(async (msg) => {
      if (msg.type === 'open') {
        await openAgentsWindow();
      } else if (msg.type === 'setDefault') {
        await vscode.workspace.getConfiguration().update(CONFIG_KEY, msg.value, vscode.ConfigurationTarget.Global);
      }
    });

    // Keep the selector in sync when the setting changes externally
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration(CONFIG_KEY)) syncTarget();
    });
  }

  _html() {
    return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<style>
  body {
    padding: 12px 14px;
    font-family: var(--vscode-font-family);
    font-size: var(--vscode-font-size);
    color: var(--vscode-foreground);
  }
  .launch {
    display: block;
    width: 100%;
    padding: 7px 10px;
    margin-bottom: 16px;
    background: var(--vscode-button-background);
    color: var(--vscode-button-foreground);
    border: none;
    border-radius: 2px;
    cursor: pointer;
    font: inherit;
    font-size: var(--vscode-font-size);
    text-align: center;
  }
  .launch:hover { background: var(--vscode-button-hoverBackground); }
  .label {
    display: block;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: var(--vscode-descriptionForeground);
    margin-bottom: 5px;
  }
  select {
    width: 100%;
    padding: 4px 6px;
    background: var(--vscode-dropdown-background);
    color: var(--vscode-dropdown-foreground);
    border: 1px solid var(--vscode-dropdown-border);
    border-radius: 2px;
    font: inherit;
  }
</style>
</head>
<body>
  <button class="launch" id="openBtn">Open Agents Window</button>
  <span class="label">Default target</span>
  <select id="targetSel">
    <option value="ask">Ask each time</option>
    <option value="simpleBrowser">Simple Browser (in editor)</option>
    <option value="externalBrowser">External Browser</option>
  </select>
<script>
  const vscode = acquireVsCodeApi();
  const sel = document.getElementById('targetSel');

  window.addEventListener('message', (e) => {
    if (e.data.type === 'init') sel.value = e.data.target;
  });

  document.getElementById('openBtn').addEventListener('click', () => {
    vscode.postMessage({ type: 'open' });
  });

  sel.addEventListener('change', () => {
    vscode.postMessage({ type: 'setDefault', value: sel.value });
  });
</script>
</body>
</html>`;
  }
}

// ── design preview ───────────────────────────────────────────────────────────

async function openDesignPreview(context) {
  const htmlPath = path.join(context.extensionPath, 'design-preview.html');
  let html;
  try { html = fs.readFileSync(htmlPath, 'utf8'); }
  catch (err) { vscode.window.showErrorMessage(`Design preview HTML missing: ${err.message}`); return; }

  const panel = vscode.window.createWebviewPanel(
    PREVIEW_PANEL_VIEW_TYPE, 'Shadow Agents — Design Preview',
    vscode.ViewColumn.Active,
    { enableScripts: true, retainContextWhenHidden: true }
  );
  panel.webview.html = html;
}

// ── activate / deactivate ────────────────────────────────────────────────────

function activate(context) {
  const statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
  statusBar.text = '$(robot) Agents';
  statusBar.tooltip = 'Open Shadow Agents Window';
  statusBar.command = COMMAND_ID;
  statusBar.show();

  context.subscriptions.push(
    statusBar,
    vscode.commands.registerCommand(COMMAND_ID, openAgentsWindow),
    vscode.commands.registerCommand(PREVIEW_COMMAND_ID, () => openDesignPreview(context)),
    vscode.window.registerWebviewViewProvider(VIEW_ID, new AgentsViewProvider())
  );
}

function deactivate() {
  if (activeProc) { try { activeProc.kill(); } catch (_) {} activeProc = null; }
}

module.exports = { activate, deactivate };
