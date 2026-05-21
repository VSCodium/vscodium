/**
 * Agent Types - Cursor ING
 *
 * Defines the agent system types: roles, statuses, permissions, and tools.
 */

/** Agent role identifiers */
export type AgentRole = 'planner' | 'coder' | 'reviewer' | 'security' | 'browser';

/** Agent operational status */
export type AgentStatus =
  | 'idle'
  | 'analyzing'
  | 'planning'
  | 'coordinating'
  | 'reading'
  | 'coding'
  | 'awaiting_review'
  | 'applying'
  | 'testing'
  | 'reviewing'
  | 'approved'
  | 'changes_requested'
  | 'scanning'
  | 'clear'
  | 'alert'
  | 'awaiting_approval'
  | 'browsing'
  | 'extracting'
  | 'blocked';

/** Agent permissions */
export type AgentPermission =
  | 'read'
  | 'write_pending_approval'
  | 'plan'
  | 'approve'
  | 'reject'
  | 'flag'
  | 'browse_pending_approval'
  | 'comment';

/** Agent tool identifiers */
export type AgentTool =
  | 'file_read'
  | 'file_write'
  | 'terminal'
  | 'search'
  | 'plan_create'
  | 'diff_view'
  | 'comment'
  | 'vuln_scan'
  | 'browser_navigate'
  | 'screenshot'
  | 'accessibility_tree';

/** Full agent definition */
export interface AgentDefinition {
  id: string;
  role: AgentRole;
  name: string;
  description: string;
  status: AgentStatus;
  permissions: AgentPermission[];
  tools: AgentTool[];
  icon: string;       // Phosphor icon name
  color: string;      // Hex color for avatar/status
  lastAction?: string;
  lastActionTime?: string;
}

/** Agent action (for activity log) */
export interface AgentAction {
  agentId: string;
  action: string;
  target: string;
  timestamp: string;
  status: 'success' | 'pending' | 'failed' | 'blocked';
  details?: string;
}
