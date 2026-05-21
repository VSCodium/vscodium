/**
 * Agent Roster - Cursor ING
 *
 * Provides the agent team as a VS Code TreeDataProvider.
 * Shows agent roles, statuses, and avatars in the sidebar.
 */

import * as vscode from 'vscode';
import { AgentDefinition, AgentRole, AgentStatus } from './types';

/** Default agent roster for Phase 1 */
const DEFAULT_AGENTS: AgentDefinition[] = [
  {
    id: 'planner',
    role: 'planner',
    name: 'Planner',
    description: 'Analyzes tasks, creates structured plans, coordinates agents',
    status: 'idle',
    permissions: ['read', 'plan'],
    tools: ['file_read', 'search', 'plan_create'],
    icon: 'TreeStructure',
    color: '#05A0F0',
    lastAction: 'Ready',
  },
  {
    id: 'coder',
    role: 'coder',
    name: 'Coder',
    description: 'Implements code changes according to approved plans',
    status: 'idle',
    permissions: ['read', 'write_pending_approval'],
    tools: ['file_read', 'file_write', 'terminal', 'search'],
    icon: 'Code',
    color: '#10B981',
    lastAction: 'Ready',
  },
  {
    id: 'reviewer',
    role: 'reviewer',
    name: 'Reviewer',
    description: 'Reviews code changes for correctness and quality',
    status: 'idle',
    permissions: ['read', 'approve', 'reject'],
    tools: ['file_read', 'diff_view', 'comment'],
    icon: 'MagnifyingGlass',
    color: '#F59E0B',
    lastAction: 'Ready',
  },
  {
    id: 'security',
    role: 'security',
    name: 'Security Auditor',
    description: 'Scans for vulnerabilities, secrets, and unsafe patterns',
    status: 'idle',
    permissions: ['read', 'flag'],
    tools: ['file_read', 'search', 'vuln_scan'],
    icon: 'Shield',
    color: '#EF4444',
    lastAction: 'Ready',
  },
  {
    id: 'browser',
    role: 'browser',
    name: 'Browser Agent',
    description: 'Performs web browsing with explicit user approval',
    status: 'idle',
    permissions: ['read', 'browse_pending_approval'],
    tools: ['browser_navigate', 'screenshot', 'accessibility_tree'],
    icon: 'Globe',
    color: '#05A0F0',
    lastAction: 'Ready [PLACEHOLDER]',
  },
];

/** Status icon mapping */
function getStatusIcon(status: AgentStatus): string {
  switch (status) {
    case 'idle': return '$(circle-outline)';
    case 'analyzing':
    case 'reading':
    case 'scanning':
    case 'browsing':
    case 'extracting': return '$(loading~spin)';
    case 'planning':
    case 'coding':
    case 'reviewing': return '$(sync~spin)';
    case 'awaiting_review':
    case 'awaiting_approval':
    case 'blocked': return '$(watch)';
    case 'approved':
    case 'clear': return '$(check)';
    case 'changes_requested':
    case 'alert': return '$(warning)';
    case 'coordinating': return '$(organization)';
    case 'applying': return '$(edit)';
    case 'testing': return '$(beaker)';
    default: return '$(circle-outline)';
  }
}

export class AgentRosterProvider implements vscode.TreeDataProvider<AgentTreeItem> {
  private _onDidChangeTreeData = new vscode.EventEmitter<AgentTreeItem | undefined>();
  readonly onDidChangeTreeData = this._onDidChangeTreeData.event;

  private agents: AgentDefinition[] = [...DEFAULT_AGENTS];

  getTreeItem(element: AgentTreeItem): vscode.TreeItem {
    return element;
  }

  getChildren(_element?: AgentTreeItem): AgentTreeItem[] {
    return this.agents.map(agent => new AgentTreeItem(agent));
  }

  /** Refresh the roster display */
  refresh(): void {
    this._onDidChangeTreeData.fire(undefined);
  }

  /** Update an agent's status */
  updateStatus(agentId: string, status: AgentStatus, lastAction?: string): void {
    const agent = this.agents.find(a => a.id === agentId);
    if (agent) {
      agent.status = status;
      if (lastAction) {
        agent.lastAction = lastAction;
        agent.lastActionTime = new Date().toISOString();
      }
      this.refresh();
    }
  }

  /** Get all agents */
  getAgents(): AgentDefinition[] {
    return [...this.agents];
  }

  /** Get a specific agent */
  getAgent(id: string): AgentDefinition | undefined {
    return this.agents.find(a => a.id === id);
  }
}

class AgentTreeItem extends vscode.TreeItem {
  constructor(public readonly agent: AgentDefinition) {
    super(agent.name, vscode.TreeItemCollapsibleState.None);
    this.description = `${getStatusIcon(agent.status)} ${agent.status}`;
    this.tooltip = `${agent.name} (${agent.role})\nStatus: ${agent.status}\n${agent.description}\nLast: ${agent.lastAction ?? 'None'}`;
    this.contextValue = agent.role;
  }
}
