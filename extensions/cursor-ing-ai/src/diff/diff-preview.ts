/**
 * Diff Preview - Cursor ING
 *
 * Shows proposed file changes with before/after comparison.
 * Requires explicit user approval before any writes are applied.
 * Trust, reversibility, and clear approval controls.
 */

import * as vscode from 'vscode';
import { ActivityLog } from '../activity/activity-log';

/** A single diff hunk */
export interface DiffHunk {
  filePath: string;
  oldContent: string;
  newContent: string;
  startLine: number;
  endLine: number;
}

/** A complete diff for review */
export interface DiffSet {
  id: string;
  title: string;
  description: string;
  agentId: string;
  timestamp: string;
  status: 'pending' | 'approved' | 'rejected';
  hunks: DiffHunk[];
}

/** Mock diff for demonstration */
const MOCK_DIFF: DiffSet = {
  id: 'diff-001',
  title: 'Add input validation to processRequest',
  description: 'Adds null check and type validation to the processRequest function',
  agentId: 'coder',
  timestamp: '2026-01-15T10:22:00.000Z',
  status: 'pending',
  hunks: [
    {
      filePath: 'src/utils/processor.ts',
      oldContent: `export function processRequest(input: string): string {
  const result = input.trim().toLowerCase();
  return result;
}`,
      newContent: `export function processRequest(input: string): string {
  if (!input || typeof input !== 'string') {
    throw new Error('Input must be a non-empty string');
  }
  const sanitized = input.replace(/[<>]/g, '');
  const result = sanitized.trim().toLowerCase();
  return result;
}`,
      startLine: 1,
      endLine: 8,
    },
  ],
};

export class DiffPreview {
  private static currentPanel: DiffPreview | undefined;
  private readonly panel: vscode.WebviewPanel;
  private diff: DiffSet;
  private activityLog: ActivityLog;

  private constructor(panel: vscode.WebviewPanel, extensionUri: vscode.Uri, activityLog: ActivityLog) {
    this.panel = panel;
    this.activityLog = activityLog;
    this.diff = MOCK_DIFF;

    this.panel.webview.html = this.getHtml();
    this.panel.onDidDispose(() => {
      DiffPreview.currentPanel = undefined;
    });
  }

  static createOrShow(extensionUri: vscode.Uri, activityLog: ActivityLog): void {
    if (DiffPreview.currentPanel) {
      DiffPreview.currentPanel.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.diffPreview',
      'Cursor ING: Diff Preview',
      vscode.ViewColumn.Two,
      { enableScripts: false }
    );

    DiffPreview.currentPanel = new DiffPreview(panel, extensionUri, activityLog);
    activityLog.log('system', 'diff_preview', 'Diff preview opened');
  }

  private escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  private getHtml(): string {
    const hunksHtml = this.diff.hunks.map(hunk => {
      const oldLines = hunk.oldContent.split('\n');
      const newLines = hunk.newContent.split('\n');

      const oldHtml = oldLines.map(line =>
        `<div style="background:rgba(239,68,68,0.15);padding:2px 8px;"><span style="color:#EF4444;user-select:none;">- </span><span style="color:#F87171;">${this.escapeHtml(line)}</span></div>`
      ).join('');

      const newHtml = newLines.map(line =>
        `<div style="background:rgba(16,185,129,0.15);padding:2px 8px;"><span style="color:#10B981;user-select:none;">+ </span><span style="color:#34D399;">${this.escapeHtml(line)}</span></div>`
      ).join('');

      return `
        <div style="margin-bottom:16px;">
          <div style="padding:8px;background:#1B2A4A;border:1px solid #2A3F6C;font-family:'JetBrains Mono',monospace;font-size:12px;color:#05A0F0;">
            ${this.escapeHtml(hunk.filePath)} (lines ${hunk.startLine}-${hunk.endLine})
          </div>
          <div style="font-family:'JetBrains Mono',monospace;font-size:12px;border:1px solid #2A3F6C;border-top:none;">
            <div style="padding:4px 8px;color:#94A3B8;font-size:11px;border-bottom:1px solid #2A3F6C;">REMOVED</div>
            ${oldHtml}
            <div style="padding:4px 8px;color:#94A3B8;font-size:11px;border-bottom:1px solid #2A3F6C;border-top:1px solid #2A3F6C;">ADDED</div>
            ${newHtml}
          </div>
        </div>
      `;
    }).join('');

    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
  <style>
    body { background:#0B1120; color:#F1F5F9; font-family:'IBM Plex Sans',sans-serif; padding:16px; margin:0; }
    h1 { font-family:'IBM Plex Mono',monospace; font-size:16px; color:#05A0F0; margin-bottom:4px; }
    .meta { font-size:12px; color:#94A3B8; margin-bottom:16px; }
    .actions { display:flex; gap:8px; margin-bottom:16px; }
    .btn { padding:6px 16px; font-family:'IBM Plex Mono',monospace; font-size:12px; border:1px solid; cursor:pointer; background:transparent; }
    .btn-approve { color:#10B981; border-color:#10B981; }
    .btn-reject { color:#EF4444; border-color:#EF4444; }
  </style>
</head>
<body>
  <h1>${this.escapeHtml(this.diff.title)}</h1>
  <div class="meta">
    ${this.escapeHtml(this.diff.description)}<br/>
    Agent: ${this.diff.agentId} | Status: ${this.diff.status.toUpperCase()} | ${this.diff.timestamp.slice(0, 16)}
  </div>
  <div class="actions">
    <button class="btn btn-approve" disabled title="[Phase 1 scaffold - approval not wired]">APPROVE</button>
    <button class="btn btn-reject" disabled title="[Phase 1 scaffold - rejection not wired]">REJECT</button>
  </div>
  ${hunksHtml}
</body>
</html>`;
  }
}
