/**
 * Cursor ING Design Studio - Extension Entry Point
 *
 * Integrates Open Design capabilities into Cursor ING IDE as an IDE-native
 * design/artifact generation panel.
 *
 * Apache 2.0 attribution: Design skills and systems adapted from Open Design.
 */

import * as vscode from 'vscode';
import { MockDesignSidecar, DesignSidecar } from './sidecar-adapter';

export function activate(context: vscode.ExtensionContext): void {
  const sidecar = new MockDesignSidecar();

  context.subscriptions.push(
    vscode.commands.registerCommand('cursorIng.openDesignStudio', () => {
      DesignStudioPanel.createOrShow(context.extensionUri, sidecar);
    }),

    vscode.commands.registerCommand('cursorIng.newDesignProject', () => {
      vscode.window.showInformationMessage('Cursor ING Design Studio: New project scaffold ready.');
    }),

    vscode.commands.registerCommand('cursorIng.previewArtifact', () => {
      vscode.window.showInformationMessage('Cursor ING: Artifact preview scaffold.');
    })
  );
}

export function deactivate(): void {}

class DesignStudioPanel {
  private static currentPanel: DesignStudioPanel | undefined;

  static createOrShow(extensionUri: vscode.Uri, sidecar: DesignSidecar): void {
    if (DesignStudioPanel.currentPanel) {
      DesignStudioPanel.currentPanel.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.designStudio',
      'Cursor ING: Design Studio',
      vscode.ViewColumn.One,
      {
        enableScripts: true,
        retainContextWhenHidden: true
      }
    );

    DesignStudioPanel.currentPanel = new DesignStudioPanel(panel, sidecar);
  }

  private constructor(
    private readonly panel: vscode.WebviewPanel,
    private readonly sidecar: DesignSidecar
  ) {
    this.panel.webview.html = this.getHtml();
    this.panel.onDidDispose(() => { DesignStudioPanel.currentPanel = undefined; });

    // Handle messages from the webview
    this.panel.webview.onDidReceiveMessage(async (message) => {
      switch (message.command) {
        case 'generate':
          await this.handleGenerate(message.data);
          return;
      }
    });
  }

  private async handleGenerate(data: any): Promise<void> {
    vscode.window.showInformationMessage(`Generating ${data.skill} with ${data.designSystem} design system...`);

    try {
      const result = await this.sidecar.generate({
        prompt: data.prompt,
        skill: data.skill,
        designSystem: data.designSystem,
        visualDirection: data.visualDirection
      });

      vscode.window.showInformationMessage(`Generated artifact: ${result.taskId}`);

      // In a real implementation, we would now trigger the artifact preview extension
      vscode.commands.executeCommand('cursorIng.openArtifactPreview', result.files[0].content);
    } catch (err: any) {
      vscode.window.showErrorMessage(`Generation failed: ${err.message}`);
    }
  }

  private getHtml(): string {
    const skills = this.sidecar.listSkills();
    const systems = this.sidecar.listDesignSystems();

    return `<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline';">
<style>
  body { background:#0D1117; color:#C9D1D9; font-family:sans-serif; padding:20px; line-height:1.4; }
  h1 { color:#58A6FF; font-size:20px; margin-top:0; }
  .section { margin-bottom:24px; }
  .label { font-size:11px; color:#8B949E; text-transform:uppercase; letter-spacing:0.05em; margin-bottom:8px; display:block; }
  textarea { width:100%; background:#161B22; border:1px solid #30363D; color:#C9D1D9; padding:8px; border-radius:6px; box-sizing:border-box; font-family:inherit; min-height:80px; margin-bottom:12px; }
  select, input { background:#161B22; border:1px solid #30363D; color:#C9D1D9; padding:6px; border-radius:6px; margin-right:8px; margin-bottom:8px; }
  button { background:#238636; color:#ffffff; border:none; padding:8px 16px; border-radius:6px; cursor:pointer; font-weight:bold; }
  button:hover { background:#2EA043; }
  .grid { display:grid; grid-template-columns: 1fr 1fr; gap:12px; }
  .card { border:1px solid #21262D; padding:12px; border-radius:6px; }
  .visual-direction { display: flex; gap: 8px; margin-bottom: 12px; }
  .direction-option { padding: 4px 12px; border: 1px solid #30363D; border-radius: 20px; font-size: 12px; cursor: pointer; }
  .direction-option.selected { background: #1f6feb; border-color: #58a6ff; }
  .status-bar { border-top: 1px solid #21262D; padding-top: 12px; margin-top: 24px; font-size: 12px; color: #8B949E; }
  .status-dot { display:inline-block; width:8px; height:8px; background:#3FB950; border-radius:50%; margin-right:4px; }
</style>
</head><body>
<h1>Cursor ING Design Studio</h1>
<p style="color:#8B949E; font-size:13px; margin-bottom:20px;">Prompt-first design artifact generation powered by Open Design.</p>

<div class="section">
  <label class="label">What are you building?</label>
  <textarea id="prompt" placeholder="e.g. A sleek crypto dashboard with real-time price charts and portfolio breakdown..."></textarea>
</div>

<div class="section">
  <div class="grid">
    <div>
      <label class="label">Skill</label>
      <select id="skill" style="width:100%">
        ${skills.map(s => `<option value="${s.name}">${s.name} - ${s.description}</option>`).join('')}
      </select>
    </div>
    <div>
      <label class="label">Design System</label>
      <select id="designSystem" style="width:100%">
        ${systems.map(s => `<option value="${s.id}">${s.name}</option>`).join('')}
      </select>
    </div>
  </div>
</div>

<div class="section">
  <label class="label">Visual Direction</label>
  <div class="visual-direction" id="visualDirection">
    <div class="direction-option selected" data-value="corporate">Corporate</div>
    <div class="direction-option" data-value="playful">Playful</div>
    <div class="direction-option" data-value="brutalist">Brutalist</div>
    <div class="direction-option" data-value="minimalist">Minimalist</div>
    <div class="direction-option" data-value="futuristic">Futuristic</div>
  </div>
</div>

<div class="section">
  <button id="generateBtn">Generate Design Artifact</button>
</div>

<div class="status-bar">
  <span class="status-dot"></span> Mock provider active &bull; No API key required &bull; 100% Privacy
</div>

<script>
  const vscode = acquireVsCodeApi();
  let selectedDirection = 'corporate';

  document.querySelectorAll('.direction-option').forEach(opt => {
    opt.addEventListener('click', () => {
      document.querySelectorAll('.direction-option').forEach(o => o.classList.remove('selected'));
      opt.classList.add('selected');
      selectedDirection = opt.dataset.value;
    });
  });

  document.getElementById('generateBtn').addEventListener('click', () => {
    const prompt = document.getElementById('prompt').value;
    const skill = document.getElementById('skill').value;
    const designSystem = document.getElementById('designSystem').value;

    vscode.postMessage({
      command: 'generate',
      data: { prompt, skill, designSystem, visualDirection: selectedDirection }
    });
  });
</script>
</body></html>`;
  }
}
