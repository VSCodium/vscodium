import React from 'react';
import { CheckCircle, Circle, Play, XCircle, MinusCircle } from '@phosphor-icons/react';

const STATUS_ICONS = {
  completed: { icon: CheckCircle, color: 'var(--success)' },
  in_progress: { icon: Play, color: 'var(--accent)' },
  pending: { icon: Circle, color: 'var(--text-muted)' },
  failed: { icon: XCircle, color: 'var(--error)' },
  skipped: { icon: MinusCircle, color: 'var(--border-strong)' },
};

const RISK_COLORS = {
  low: 'var(--success)',
  medium: 'var(--warning)',
  high: 'var(--error)',
};

function PlanViewer({ plans }) {
  const plan = plans[0];
  if (!plan) return <div data-testid="plan-viewer-empty" style={{ color: 'var(--text-muted)' }}>No plans available.</div>;

  return (
    <div data-testid="plan-viewer-panel">
      <h1 className="panel-title">{plan.title}</h1>
      <p className="panel-subtitle">{plan.description}</p>

      <div style={{
        display: 'flex',
        gap: '12px',
        marginBottom: '20px',
        flexWrap: 'wrap',
      }}>
        <StatusBadge label={`STATUS: ${plan.status.toUpperCase()}`} color="var(--accent)" />
        <StatusBadge label={`CREATED: ${plan.createdAt.slice(0, 10)}`} color="var(--text-muted)" />
        <StatusBadge label={`AGENT: ${plan.createdBy}`} color="var(--text-muted)" />
        {plan.approvedBy && <StatusBadge label={`APPROVED BY: ${plan.approvedBy}`} color="var(--success)" />}
      </div>

      <div style={{ border: '1px solid var(--border-subtle)' }}>
        <div style={{
          display: 'grid',
          gridTemplateColumns: '40px 32px 1fr 200px 80px 80px',
          gap: '8px',
          padding: '8px 12px',
          background: 'var(--bg-surface)',
          borderBottom: '1px solid var(--border-subtle)',
        }}>
          <span className="overline">#</span>
          <span></span>
          <span className="overline">Step</span>
          <span className="overline">Files</span>
          <span className="overline">Risk</span>
          <span className="overline">Agent</span>
        </div>

        {plan.steps.map((step, idx) => {
          const statusInfo = STATUS_ICONS[step.status] || STATUS_ICONS.pending;
          const StatusIcon = statusInfo.icon;
          const isActive = step.status === 'in_progress';

          return (
            <div
              key={step.id}
              data-testid={`plan-step-${step.id}`}
              style={{
                display: 'grid',
                gridTemplateColumns: '40px 32px 1fr 200px 80px 80px',
                gap: '8px',
                padding: '10px 12px',
                background: isActive ? 'rgba(5,160,240,0.06)' : 'var(--bg-base)',
                borderBottom: '1px solid var(--border-subtle)',
                borderLeft: isActive ? '2px solid var(--accent)' : '2px solid transparent',
                alignItems: 'flex-start',
              }}
            >
              <span style={{ fontFamily: 'var(--font-code)', fontSize: '12px', color: 'var(--text-muted)' }}>
                {step.id}
              </span>
              <StatusIcon size={16} weight="fill" color={statusInfo.color} style={{ marginTop: '2px' }} />
              <div>
                <div style={{ fontSize: '13px', color: 'var(--text-primary)' }}>{step.description}</div>
                {step.notes && (
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px', fontStyle: 'italic' }}>
                    {step.notes}
                  </div>
                )}
              </div>
              <div style={{ fontFamily: 'var(--font-code)', fontSize: '11px', color: 'var(--text-muted)', wordBreak: 'break-all' }}>
                {step.files.join(', ')}
              </div>
              <span style={{
                fontFamily: 'var(--font-code)',
                fontSize: '10px',
                color: RISK_COLORS[step.risk],
                border: `1px solid ${RISK_COLORS[step.risk]}`,
                padding: '1px 6px',
                borderRadius: '2px',
                display: 'inline-block',
                textTransform: 'uppercase',
                letterSpacing: '0.05em',
                width: 'fit-content',
              }}>
                {step.risk}
              </span>
              <span style={{ fontFamily: 'var(--font-code)', fontSize: '11px', color: 'var(--text-muted)' }}>
                {step.agentId || '-'}
              </span>
            </div>
          );
        })}
      </div>

      <div style={{
        marginTop: '12px',
        display: 'flex',
        gap: '8px',
      }}>
        <button data-testid="plan-approve-btn" disabled style={{
          padding: '6px 16px',
          fontFamily: 'var(--font-heading)',
          fontSize: '11px',
          letterSpacing: '0.1em',
          background: 'transparent',
          color: 'var(--success)',
          border: '1px solid var(--success)',
          cursor: 'not-allowed',
          opacity: 0.5,
        }}>
          APPROVE PLAN
        </button>
        <button data-testid="plan-reject-btn" disabled style={{
          padding: '6px 16px',
          fontFamily: 'var(--font-heading)',
          fontSize: '11px',
          letterSpacing: '0.1em',
          background: 'transparent',
          color: 'var(--error)',
          border: '1px solid var(--error)',
          cursor: 'not-allowed',
          opacity: 0.5,
        }}>
          REJECT PLAN
        </button>
      </div>
    </div>
  );
}

function StatusBadge({ label, color }) {
  return (
    <span style={{
      fontFamily: 'var(--font-code)',
      fontSize: '10px',
      color,
      border: `1px solid ${color}`,
      padding: '2px 8px',
      borderRadius: '2px',
      letterSpacing: '0.05em',
    }}>
      {label}
    </span>
  );
}

export default PlanViewer;
