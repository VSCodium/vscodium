/**
 * Cursor ING - AI Composer Extension
 * Main entry point for the VS Code/VSCodium extension.
 *
 * Privacy-first, open-source, no telemetry.
 * MIT License.
 */

import * as vscode from 'vscode';
import { ProviderRegistry } from './providers/registry';
import { MockProvider } from './providers/mock-provider';
import { AgentRosterProvider } from './agents/roster';
import { ActivityLog } from './activity/activity-log';
import { PlanViewer } from './plans/plan-viewer';
import { DiffPreview } from './diff/diff-preview';
import { ComposerPanel } from './composer/composer-panel';

let activityLog: ActivityLog;

export function activate(context: vscode.ExtensionContext): void {
  // Initialize activity log first (other components depend on it)
  activityLog = new ActivityLog();
  activityLog.log('system', 'extension', 'Cursor ING activated');

  // Register mock provider
  const registry = ProviderRegistry.getInstance();
  registry.register('mock', new MockProvider());
  activityLog.log('system', 'provider', 'MockProvider registered');

  // Agent roster tree view
  const agentRoster = new AgentRosterProvider();
  vscode.window.registerTreeDataProvider('cursorIng.agentRoster', agentRoster);

  // Commands
  context.subscriptions.push(
    vscode.commands.registerCommand('cursorIng.openComposer', () => {
      activityLog.log('user', 'command', 'Open Composer');
      ComposerPanel.createOrShow(context.extensionUri, registry, activityLog);
    }),

    vscode.commands.registerCommand('cursorIng.showAgentRoster', () => {
      activityLog.log('user', 'command', 'Show Agent Roster');
      agentRoster.refresh();
    }),

    vscode.commands.registerCommand('cursorIng.openPlanViewer', () => {
      activityLog.log('user', 'command', 'Open Plan Viewer');
      PlanViewer.createOrShow(context.extensionUri, activityLog);
    }),

    vscode.commands.registerCommand('cursorIng.showActivityLog', () => {
      activityLog.log('user', 'command', 'Show Activity Log');
      activityLog.showPanel(context.extensionUri);
    }),

    vscode.commands.registerCommand('cursorIng.openDiffPreview', () => {
      activityLog.log('user', 'command', 'Open Diff Preview');
      DiffPreview.createOrShow(context.extensionUri, activityLog);
    })
  );

  activityLog.log('system', 'extension', 'All commands registered');
}

export function deactivate(): void {
  if (activityLog) {
    activityLog.log('system', 'extension', 'Cursor ING deactivated');
  }
}
