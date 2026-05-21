/**
 * Composer Panel - Cursor ING
 *
 * AI chat/command interface webview panel.
 * Phase 1: Uses mock provider for deterministic responses.
 * Future: Real AI provider integration, streaming, function calling.
 */

import * as vscode from 'vscode';
import { ProviderRegistry } from '../providers/registry';
import { ActivityLog } from '../activity/activity-log';
import { Message } from '../providers/types';

export class ComposerPanel {
  private static currentPanel: ComposerPanel | undefined;
  private readonly panel: vscode.WebviewPanel;
  private registry: ProviderRegistry;
  private activityLog: ActivityLog;
  private messages: Message[] = [];

  private constructor(
    panel: vscode.WebviewPanel,
    extensionUri: vscode.Uri,
    registry: ProviderRegistry,
    activityLog: ActivityLog
  ) {
    this.panel = panel;
    this.registry = registry;
    this.activityLog = activityLog;

    // Add system message
    this.messages.push({
      role: 'system',
      content: 'You are Cursor ING, a privacy-first AI coding assistant. You help developers by analyzing code, creating plans, and generating changes with explicit approval.',
      timestamp: new Date().toISOString(),
    });

    this.panel.webview.html = this.getHtml();
    this.panel.onDidDispose(() => {
      ComposerPanel.currentPanel = undefined;
    });
  }

  static createOrShow(
    extensionUri: vscode.Uri,
    registry: ProviderRegistry,
    activityLog: ActivityLog
  ): void {
    if (ComposerPanel.currentPanel) {
      ComposerPanel.currentPanel.panel.reveal();
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      'cursorIng.composer',
      'Cursor ING: Composer',
      vscode.ViewColumn.Two,
      { enableScripts: false }
    );

    ComposerPanel.currentPanel = new ComposerPanel(panel, extensionUri, registry, activityLog);
    activityLog.log('system', 'composer', 'Composer panel opened');
  }

  private escapeHtml(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  private getHtml(): string {
    const provider = this.registry.getActive();
    const providerStatus = provider?.getStatus();

    const messagesHtml = this.messages
      .filter(m => m.role !== 'system')
      .map(m => {
        const isUser = m.role === 'user';
        const color = isUser ? '#F1F5F9' : '#05A0F0';
        const label = isUser ? 'YOU' : 'CURSOR ING';
        return `
          <div style="margin-bottom:12px;">
            <div style="font-family:'IBM Plex Mono',monospace;font-size:10px;color:#94A3B8;text-transform:uppercase;letter-spacing:0.1em;margin-bottom:4px;">${label} &mdash; ${m.timestamp.slice(11, 19)}</div>
            <div style="color:${color};font-size:13px;line-height:1.5;white-space:pre-wrap;">${this.escapeHtml(m.content)}</div>
          </div>
        `;
      })
      .join('');

    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline';">
  <style>
    body { background:#0B1120; color:#F1F5F9; font-family:'IBM Plex Sans',sans-serif; padding:16px; margin:0; display:flex; flex-direction:column; height:100vh; box-sizing:border-box; }
    .header { font-family:'IBM Plex Mono',monospace; font-size:14px; color:#05A0F0; padding-bottom:12px; border-bottom:1px solid #2A3F6C; margin-bottom:12px; }
    .provider-info { font-size:11px; color:#94A3B8; }
    .messages { flex:1; overflow-y:auto; }
    .input-area { border-top:1px solid #2A3F6C; padding-top:12px; }
    .input-hint { font-family:'JetBrains Mono',monospace; font-size:12px; color:#3B5284; }
  </style>
</head>
<body>
  <div class="header">
    CURSOR ING COMPOSER
    <div class="provider-info">
      Provider: ${providerStatus?.name ?? 'None'} | Model: ${providerStatus?.model ?? 'N/A'} | Status: ${providerStatus?.available ? 'Active' : 'Unavailable'}
    </div>
  </div>
  <div class="messages">
    ${messagesHtml || '<div style="color:#3B5284;font-style:italic;">Type a message to start. Try: "Create a plan for..." or "Review this code..."</div>'}
  </div>
  <div class="input-area">
    <div class="input-hint">&gt; [Phase 1 scaffold - interactive input not wired. See extension commands.]</div>
  </div>
</body>
</html>`;
  }
}
