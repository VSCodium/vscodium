/**
 * Plan Types - Cursor ING
 *
 * Defines the plan file format (.plan.json) for structured task execution.
 */

/** Plan step status */
export type PlanStepStatus = 'pending' | 'in_progress' | 'completed' | 'failed' | 'skipped';

/** Plan overall status */
export type PlanStatus = 'draft' | 'approved' | 'in_progress' | 'completed' | 'failed' | 'cancelled';

/** Risk level for a plan step */
export type RiskLevel = 'low' | 'medium' | 'high';

/** A single step in a plan */
export interface PlanStep {
  id: number;
  description: string;
  status: PlanStepStatus;
  files: string[];
  risk: RiskLevel;
  notes: string;
  agentId?: string;
  startTime?: string;
  endTime?: string;
  output?: string;
}

/** Full plan file format */
export interface Plan {
  id: string;
  title: string;
  description: string;
  status: PlanStatus;
  createdAt: string;
  updatedAt: string;
  createdBy: string;
  approvedBy?: string;
  approvedAt?: string;
  steps: PlanStep[];
  metadata?: Record<string, string>;
}

/** Plan annotation (for Plannotator-inspired review) */
export interface PlanAnnotation {
  stepId: number;
  author: string;
  content: string;
  timestamp: string;
  type: 'comment' | 'approval' | 'rejection' | 'question';
}

/** Create a new empty plan */
export function createPlan(title: string, description: string): Plan {
  return {
    id: `plan-${Date.now()}`,
    title,
    description,
    status: 'draft',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    createdBy: 'planner',
    steps: [],
  };
}

/** Add a step to a plan */
export function addStep(plan: Plan, description: string, files: string[], risk: RiskLevel): Plan {
  const step: PlanStep = {
    id: plan.steps.length + 1,
    description,
    status: 'pending',
    files,
    risk,
    notes: '',
  };
  return {
    ...plan,
    steps: [...plan.steps, step],
    updatedAt: new Date().toISOString(),
  };
}

/** Mock plan for demonstration */
export const MOCK_PLAN: Plan = {
  id: 'plan-1706000000000',
  title: 'Implement user authentication module',
  description: 'Add JWT-based authentication with login, register, and token refresh endpoints.',
  status: 'approved',
  createdAt: '2026-01-15T10:00:00.000Z',
  updatedAt: '2026-01-15T10:30:00.000Z',
  createdBy: 'planner',
  approvedBy: 'user',
  approvedAt: '2026-01-15T10:15:00.000Z',
  steps: [
    {
      id: 1,
      description: 'Read existing auth-related files and understand current patterns',
      status: 'completed',
      files: ['src/auth/', 'src/config/'],
      risk: 'low',
      notes: 'Found existing session middleware to extend',
      agentId: 'planner',
      startTime: '2026-01-15T10:16:00.000Z',
      endTime: '2026-01-15T10:17:00.000Z',
    },
    {
      id: 2,
      description: 'Create JWT utility with sign/verify functions',
      status: 'completed',
      files: ['src/auth/jwt.ts'],
      risk: 'medium',
      notes: 'Using jsonwebtoken library, RS256 algorithm',
      agentId: 'coder',
      startTime: '2026-01-15T10:18:00.000Z',
      endTime: '2026-01-15T10:22:00.000Z',
    },
    {
      id: 3,
      description: 'Implement login and register endpoints',
      status: 'in_progress',
      files: ['src/routes/auth.ts', 'src/models/user.ts'],
      risk: 'medium',
      notes: '',
      agentId: 'coder',
      startTime: '2026-01-15T10:23:00.000Z',
    },
    {
      id: 4,
      description: 'Security audit of authentication implementation',
      status: 'pending',
      files: ['src/auth/', 'src/routes/auth.ts'],
      risk: 'high',
      notes: '',
      agentId: 'security',
    },
    {
      id: 5,
      description: 'Write integration tests for auth endpoints',
      status: 'pending',
      files: ['tests/auth.test.ts'],
      risk: 'low',
      notes: '',
      agentId: 'coder',
    },
  ],
};
