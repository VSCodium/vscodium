/**
 * Cursor ING Design Studio - Extension Entry Point
 *
 * Integrates Open Design capabilities into Cursor ING IDE as an IDE-native
 * design/artifact generation panel.
 *
 * Apache 2.0 attribution: Design skills and systems adapted from Open Design.
 */

import * as vscode from 'vscode';
import { MockDesignSidecar } from './sidecar-adapter';

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

  static createOrShow(extensionUri: vscode.Uri, sidecar: MockDesignSidecar): void {
    if (DesignStudioPanel.currentPanel) {
      DesignStudioPanel.currentPanel.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.designStudio',
      'Cursor ING: Design Studio',
      vscode.ViewColumn.One,
      { enableScripts: false }
    );

    DesignStudioPanel.currentPanel = new DesignStudioPanel(panel, sidecar);
  }

  private constructor(
    private readonly panel: vscode.WebviewPanel,
    private readonly sidecar: MockDesignSidecar
  ) {
    this.panel.webview.html = this.getHtml();
    this.panel.onDidDispose(() => { DesignStudioPanel.currentPanel = undefined; });
  }

  private getHtml(): string {
    const skills = this.sidecar.listSkills();
    const systems = this.sidecar.listDesignSystems();

    return `<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
<style>
  body { background:#0D1117; color:#C9D1D9; font-family:sans-serif; padding:16px; }
  h1 { color:#58A6FF; font-size:18px; }
  .section { margin:16px 0; }
  .label { font-size:11px; color:#8B949E; text-transform:uppercase; letter-spacing:0.05em; }
</style>
</head><body>
<h1>Cursor ING Design Studio</h1>
<p style="color:#8B949E">Generate prototypes, landing pages, dashboards, and design artifacts.</p>
<div class="section">
  <div class="label">Available Skills (${skills.length})</div>
  ${skills.map(s => `<div style="padding:4px 0;font-size:13px;">${s.name} &mdash; <span style="color:#8B949E">${s.description}</span></div>`).join('')}
</div>
<div class="section">
  <div class="label">Design Systems (${systems.length})</div>
  ${systems.map(s => `<span style="display:inline-block;padding:2px 8px;margin:2px;border:1px solid #21262D;font-size:12px;">${s}</span>`).join('')}
</div>
<div class="section">
  <div class="label">Status</div>
  <div style="font-size:12px;color:#3FB950;">Mock sidecar active / No API key required</div>
</div>
</body></html>`;
  }
}
