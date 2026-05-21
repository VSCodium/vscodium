/**
 * Activity Log - Cursor ING
 *
 * Structured audit trail of all agent and system actions.
 * Every file read, edit, command, browser action, and handoff is logged.
 * No telemetry - all data stays local.
 */

import * as vscode from 'vscode';

/** Activity log entry */
export interface ActivityEntry {
  id: string;
  timestamp: string;
  actor: string;       // 'system' | 'user' | agent ID
  category: string;    // 'file_read' | 'file_write' | 'command' | 'provider' | 'plan' | etc.
  message: string;
  details?: string;
  severity: 'info' | 'warning' | 'error';
}

export class ActivityLog {
  private entries: ActivityEntry[] = [];
  private outputChannel: vscode.OutputChannel;
  private panel: vscode.WebviewPanel | undefined;
  private maxEntries = 1000;

  constructor() {
    this.outputChannel = vscode.window.createOutputChannel('Cursor ING Activity');
  }

  /** Add an entry to the log */
  log(actor: string, category: string, message: string, details?: string, severity: 'info' | 'warning' | 'error' = 'info'): void {
    const entry: ActivityEntry = {
      id: `log-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      timestamp: new Date().toISOString(),
      actor,
      category,
      message,
      details,
      severity,
    };

    this.entries.push(entry);
    if (this.entries.length > this.maxEntries) {
      this.entries = this.entries.slice(-this.maxEntries);
    }

    // Write to VS Code output channel
    const ts = entry.timestamp.slice(11, 23);
    const prefix = `[${ts}] [${actor}/${category}]`;
    this.outputChannel.appendLine(`${prefix} ${message}`);

    // Update webview if open
    if (this.panel) {
      this.panel.webview.html = this.getPanelHtml();
    }
  }

  /** Get all entries */
  getEntries(): ActivityEntry[] {
    return [...this.entries];
  }

  /** Get recent entries */
  getRecent(count: number): ActivityEntry[] {
    return this.entries.slice(-count);
  }

  /** Show activity log in a webview panel */
  showPanel(extensionUri: vscode.Uri): void {
    if (this.panel) {
      this.panel.reveal();
      return;
    }

    this.panel = vscode.window.createWebviewPanel(
      'cursorIng.activityLog',
      'Cursor ING: Activity Log',
      vscode.ViewColumn.Two,
      { enableScripts: false }
    );

    this.panel.webview.html = this.getPanelHtml();
    this.panel.onDidDispose(() => {
      this.panel = undefined;
    });
  }

  private getSeverityColor(severity: string): string {
    switch (severity) {
      case 'warning': return '#F59E0B';
      case 'error': return '#EF4444';
      default: return '#94A3B8';
    }
  }

  private getPanelHtml(): string {
    const recent = this.entries.slice(-50).reverse();
    const rows = recent.map(e => `
      <div style="display:flex;gap:12px;padding:4px 8px;border-bottom:1px solid #1B2A4A;font-family:'JetBrains Mono',monospace;font-size:12px;">
        <span style="color:#3B5284;min-width:90px;">${e.timestamp.slice(11, 23)}</span>
        <span style="color:${this.getSeverityColor(e.severity)};min-width:80px;">[${e.actor}]</span>
        <span style="color:#05A0F0;min-width:80px;">${e.category}</span>
        <span style="color:#F1F5F9;flex:1;">${e.message}</span>
      </div>
    `).join('');

    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
  <style>
    body { background:#0B1120; color:#F1F5F9; margin:0; padding:12px; }
    h2 { font-family:'IBM Plex Mono',monospace; font-size:14px; color:#05A0F0; margin:0 0 12px 0; }
    .log-container { max-height:calc(100vh - 60px); overflow-y:auto; }
  </style>
</head>
<body>
  <h2>ACTIVITY LOG (${this.entries.length} entries)</h2>
  <div class="log-container">
    ${rows || '<div style="color:#94A3B8;padding:8px;">No activity recorded yet.</div>'}
  </div>
</body>
</html>`;
  }
}
