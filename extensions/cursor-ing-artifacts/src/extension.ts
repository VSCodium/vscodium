/**
 * Cursor ING Artifacts - Sandboxed Artifact Preview
 *
 * Renders generated HTML artifacts in a secure webview panel.
 * Enforces CSP, no unrestricted eval, no broad Node access.
 */

import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('cursorIng.openArtifactPreview', (html?: string) => {
      ArtifactPreviewPanel.createOrShow(context.extensionUri, html);
    })
  );
}

export function deactivate(): void {}

class ArtifactPreviewPanel {
  private static current: ArtifactPreviewPanel | undefined;

  static createOrShow(extensionUri: vscode.Uri, html?: string): void {
    if (ArtifactPreviewPanel.current) {
      if (html) {
        ArtifactPreviewPanel.current.loadArtifact(html);
      }
      ArtifactPreviewPanel.current.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.artifactPreview',
      'Cursor ING: Artifact Preview',
      vscode.ViewColumn.Two,
      {
        enableScripts: true,
        retainContextWhenHidden: true
      }
    );

    ArtifactPreviewPanel.current = new ArtifactPreviewPanel(panel, html);
  }

  private constructor(private readonly panel: vscode.WebviewPanel, initialHtml?: string) {
    if (initialHtml) {
      this.loadArtifact(initialHtml);
    } else {
      this.panel.webview.html = this.getPlaceholderHtml();
    }

    this.panel.onDidDispose(() => { ArtifactPreviewPanel.current = undefined; });

    // Handle messages from the webview (e.g. export requests)
    this.panel.webview.onDidReceiveMessage((message) => {
      switch (message.command) {
        case 'export':
          vscode.window.showInformationMessage(`Exporting artifact as ${message.format}... (Mock)`);
          return;
      }
    });
  }

  /** Load generated artifact HTML into the preview container */
  loadArtifact(artifactHtml: string): void {
    this.panel.webview.html = this.wrapArtifact(artifactHtml);
  }

  private wrapArtifact(artifactHtml: string): string {
    // We wrap the artifact in a shell that provides export buttons
    return `<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; frame-src 'self' data:;">
<style>
  body { background:#0D1117; color:#C9D1D9; font-family:sans-serif; margin:0; padding:0; display:flex; flex-direction:column; height:100vh; overflow:hidden; }
  .toolbar { background:#161B22; border-bottom:1px solid #30363D; padding:8px 16px; display:flex; align-items:center; gap:12px; }
  .title { font-size:13px; font-weight:bold; color:#58A6FF; flex-grow:1; }
  .export-btn { background:#21262D; color:#C9D1D9; border:1px solid #30363D; padding:4px 8px; border-radius:4px; font-size:11px; cursor:pointer; }
  .export-btn:hover { background:#30363D; }
  .preview-container { flex-grow:1; background:#ffffff; position:relative; }
  iframe { width:100%; height:100%; border:none; background:#ffffff; }
</style>
</head><body>
<div class="toolbar">
  <div class="title">Artifact Preview</div>
  <button class="export-btn" onclick="exportAs('html')">HTML</button>
  <button class="export-btn" onclick="exportAs('pdf')">PDF</button>
  <button class="export-btn" onclick="exportAs('pptx')">PPTX</button>
  <button class="export-btn" onclick="exportAs('zip')">ZIP</button>
  <button class="export-btn" onclick="exportAs('img')">Image</button>
</div>
<div class="preview-container">
  <iframe id="preview" srcdoc="${artifactHtml.replace(/"/g, '&quot;')}" sandbox="allow-scripts"></iframe>
</div>
<script>
  const vscode = acquireVsCodeApi();
  function exportAs(format) {
    vscode.postMessage({ command: 'export', format });
  }
</script>
</body></html>`;
  }

  private getPlaceholderHtml(): string {
    return `<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
<style>
  body { background:#0D1117; color:#8B949E; font-family:sans-serif; display:flex; align-items:center; justify-content:center; height:100vh; margin:0; }
  .msg { text-align:center; }
  h2 { color:#58A6FF; font-size:16px; }
</style>
</head><body>
<div class="msg">
<h2>Artifact Preview</h2>
<p>No artifact loaded. Generate a design from Design Studio to preview here.</p>
<p style="font-size:11px;color:#484F58;">Future exports: HTML, PDF, PPTX, ZIP, Markdown, images</p>
</div>
</body></html>`;
  }
}
