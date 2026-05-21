/**
 * Plan Viewer - Cursor ING
 *
 * Webview panel for viewing and editing plans.
 * Shows plan steps, statuses, annotations, and approval controls.
 */

import * as vscode from 'vscode';
import { Plan, MOCK_PLAN } from './types';
import { ActivityLog } from '../activity/activity-log';

export class PlanViewer {
  private static currentPanel: PlanViewer | undefined;
  private readonly panel: vscode.WebviewPanel;
  private readonly extensionUri: vscode.Uri;
  private plan: Plan;
  private activityLog: ActivityLog;

  private constructor(panel: vscode.WebviewPanel, extensionUri: vscode.Uri, activityLog: ActivityLog) {
    this.panel = panel;
    this.extensionUri = extensionUri;
    this.activityLog = activityLog;
    this.plan = MOCK_PLAN;

    this.panel.webview.html = this.getHtml();
    this.panel.onDidDispose(() => {
      PlanViewer.currentPanel = undefined;
    });
  }

  static createOrShow(extensionUri: vscode.Uri, activityLog: ActivityLog): void {
    if (PlanViewer.currentPanel) {
      PlanViewer.currentPanel.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.planViewer',
      'Cursor ING: Plan Viewer',
      vscode.ViewColumn.Two,
      { enableScripts: false }
    );

    PlanViewer.currentPanel = new PlanViewer(panel, extensionUri, activityLog);
    activityLog.log('system', 'plan_viewer', 'Plan viewer opened');
  }

  private getStepStatusIcon(status: string): string {
    switch (status) {
      case 'completed': return '&#x2714;';
      case 'in_progress': return '&#x25B6;';
      case 'failed': return '&#x2718;';
      case 'skipped': return '&#x2015;';
      default: return '&#x25CB;';
    }
  }

  private getRiskBadge(risk: string): string {
    const colors: Record<string, string> = {
      low: '#10B981',
      medium: '#F59E0B',
      high: '#EF4444',
    };
    return `<span style="color:${colors[risk] ?? '#94A3B8'};font-size:11px;border:1px solid ${colors[risk] ?? '#94A3B8'};padding:1px 6px;border-radius:2px;">${risk.toUpperCase()}</span>`;
  }

  private getHtml(): string {
    const stepsHtml = this.plan.steps.map(step => `
      <tr style="border-bottom:1px solid #2A3F6C;">
        <td style="padding:8px;font-family:'JetBrains Mono',monospace;color:#94A3B8;">${step.id}</td>
        <td style="padding:8px;">${this.getStepStatusIcon(step.status)}</td>
        <td style="padding:8px;color:#F1F5F9;">${step.description}</td>
        <td style="padding:8px;font-family:'JetBrains Mono',monospace;color:#94A3B8;font-size:12px;">${step.files.join(', ')}</td>
        <td style="padding:8px;">${this.getRiskBadge(step.risk)}</td>
        <td style="padding:8px;color:#94A3B8;font-size:12px;">${step.agentId ?? '-'}</td>
      </tr>
    `).join('');

    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
  <style>
    body { background:#0B1120; color:#F1F5F9; font-family:'IBM Plex Sans',sans-serif; padding:16px; margin:0; }
    h1 { font-family:'IBM Plex Mono',monospace; font-size:18px; color:#05A0F0; margin-bottom:4px; }
    .meta { font-size:12px; color:#94A3B8; margin-bottom:16px; }
    .status-badge { display:inline-block; padding:2px 8px; border-radius:2px; font-size:11px; font-weight:600; }
    table { width:100%; border-collapse:collapse; }
    th { text-align:left; padding:8px; font-size:11px; text-transform:uppercase; letter-spacing:0.1em; color:#94A3B8; border-bottom:2px solid #2A3F6C; }
  </style>
</head>
<body>
  <h1>${this.plan.title}</h1>
  <div class="meta">
    ${this.plan.description}<br/>
    Status: <span class="status-badge" style="background:#1B2A4A;color:#05A0F0;border:1px solid #05A0F0;">${this.plan.status.toUpperCase()}</span>
    &nbsp;|&nbsp; Created: ${this.plan.createdAt.slice(0, 10)}
    &nbsp;|&nbsp; Agent: ${this.plan.createdBy}
  </div>
  <table>
    <thead>
      <tr>
        <th>#</th><th></th><th>Step</th><th>Files</th><th>Risk</th><th>Agent</th>
      </tr>
    </thead>
    <tbody>
      ${stepsHtml}
    </tbody>
  </table>
</body>
</html>`;
  }
}
