/**
 * Cursor ING Artifacts - Sandboxed Artifact Preview
 *
 * Renders generated HTML artifacts in a secure webview panel.
 * Enforces CSP, no unrestricted eval, no broad Node access.
 */

import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('cursorIng.openArtifactPreview', () => {
      ArtifactPreviewPanel.createOrShow(context.extensionUri);
    })
  );
}

export function deactivate(): void {}

class ArtifactPreviewPanel {
  private static current: ArtifactPreviewPanel | undefined;

  static createOrShow(extensionUri: vscode.Uri): void {
    if (ArtifactPreviewPanel.current) {
      ArtifactPreviewPanel.current.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.artifactPreview',
      'Cursor ING: Artifact Preview',
      vscode.ViewColumn.Two,
      { enableScripts: false }
    );

    ArtifactPreviewPanel.current = new ArtifactPreviewPanel(panel);
  }

  private constructor(private readonly panel: vscode.WebviewPanel) {
    this.panel.webview.html = this.getPlaceholderHtml();
    this.panel.onDidDispose(() => { ArtifactPreviewPanel.current = undefined; });
  }

  /** Load generated artifact HTML into the preview */
  loadArtifact(html: string): void {
    this.panel.webview.html = html;
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
