import React from 'react';
import { CheckCircle, Circle, Play, XCircle, AlertTriangle } from 'lucide-react';

const STATUS = {
  completed: { Icon: CheckCircle, color: 'var(--success)' },
  in_progress: { Icon: Play, color: 'var(--accent)' },
  pending: { Icon: Circle, color: 'var(--text-dimmed)' },
  failed: { Icon: XCircle, color: 'var(--error)' },
};

const RISK = { low: 'var(--success)', medium: 'var(--warning)', high: 'var(--error)' };

function PlanEditor({ plan }) {
  if (!plan) return <div data-testid="editor-plan-empty" style={{ flex: 1, background: 'var(--bg-editor)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-dimmed)' }}>No plan loaded.</div>;

  return (
    <div data-testid="editor-plan" style={{ flex: 1, overflow: 'auto', background: 'var(--bg-editor)', fontFamily: 'var(--font-mono)', fontSize: 12 }}>
      <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--border)' }}>
        <Line num={1}><span style={{ color: 'var(--accent)' }}>## </span><span style={{ color: 'var(--text-bright)', fontWeight: 500 }}>{plan.title}</span></Line>
        <Line num={2}><span style={{ color: 'var(--text-muted)' }}>{plan.description}</span></Line>
        <Line num={3}>
          <span style={{ color: 'var(--text-dimmed)' }}>status: </span>
          <Badge text={plan.status} color="var(--accent)" />
          <span style={{ color: 'var(--text-dimmed)', marginLeft: 8 }}>by: {plan.createdBy}</span>
          {plan.approvedBy && <><span style={{ color: 'var(--text-dimmed)', marginLeft: 8 }}>approved: </span><Badge text={plan.approvedBy} color="var(--success)" /></>}
        </Line>
      </div>

      <div style={{ padding: '4px 0' }}>
        <Line num={4}><span style={{ color: 'var(--text-dimmed)' }}>---</span></Line>
        {plan.steps.map((step, idx) => {
          const s = STATUS[step.status] || STATUS.pending;
          const SIcon = s.Icon;
          const ln = 5 + idx * 3;
          const active = step.status === 'in_progress';
          return (
            <div key={step.id} data-testid={`plan-step-${step.id}`} style={{
              borderLeft: active ? '2px solid var(--accent)' : '2px solid transparent',
              background: active ? 'var(--accent-dim)' : 'transparent',
              padding: '4px 16px 4px 14px',
            }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 8 }}>
                <Ln n={ln} />
                <SIcon size={13} color={s.color} style={{ marginTop: 2, flexShrink: 0 }} />
                <span style={{ color: s.color, minWidth: 16 }}>{step.id}.</span>
                <span style={{ color: 'var(--text-primary)' }}>{step.description}</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, paddingLeft: 44, marginTop: 1 }}>
                <Ln n={ln + 1} />
                <span style={{ color: 'var(--text-dimmed)', fontSize: 11 }}>files: {step.files.join(', ')}</span>
                <RiskBadge risk={step.risk} />
                <span style={{ color: 'var(--text-dimmed)', fontSize: 11 }}>agent: {step.agentId || '-'}</span>
              </div>
              {step.notes && (
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, paddingLeft: 44, marginTop: 1 }}>
                  <Ln n={ln + 2} />
                  <span style={{ color: 'var(--text-dimmed)', fontSize: 11, fontStyle: 'italic' }}>// {step.notes}</span>
                </div>
              )}
            </div>
          );
        })}
      </div>

      <div style={{ display: 'flex', gap: 8, padding: '12px 16px', borderTop: '1px solid var(--border)', position: 'sticky', bottom: 0, background: 'var(--bg-editor)', alignItems: 'center' }}>
        <button data-testid="plan-approve-btn" disabled style={btnS('var(--success)')}>Approve Plan</button>
        <button data-testid="plan-reject-btn" disabled style={btnS('var(--error)')}>Reject</button>
        <button data-testid="plan-comment-btn" disabled style={btnS('var(--text-muted)')}>Comment</button>
        <span style={{ fontSize: 10, color: 'var(--text-dimmed)', marginLeft: 8 }}>[Phase 1 scaffold]</span>
      </div>
    </div>
  );
}

function Line({ num, children }) {
  return <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 2 }}><Ln n={num} />{children}</div>;
}
function Ln({ n }) { return <span style={{ color: 'var(--line-number)', fontSize: 11, width: 28, textAlign: 'right', flexShrink: 0, fontFamily: 'var(--font-mono)' }}>{n}</span>; }
function Badge({ text, color }) { return <span style={{ fontSize: 10, color, border: `1px solid ${color}`, padding: '0 5px', borderRadius: 2, lineHeight: '16px' }}>{text}</span>; }
function RiskBadge({ risk }) { return <span style={{ fontSize: 9, color: RISK[risk], border: `1px solid ${RISK[risk]}`, padding: '0 4px', borderRadius: 2, textTransform: 'uppercase', letterSpacing: '0.05em', lineHeight: '14px' }}>{risk}</span>; }
const btnS = (c) => ({ padding: '4px 12px', fontSize: 11, fontFamily: 'var(--font-mono)', color: c, background: 'transparent', border: `1px solid ${c}`, cursor: 'not-allowed', opacity: 0.6, borderRadius: 0 });

export default PlanEditor;
