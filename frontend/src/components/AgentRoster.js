import React from 'react';
import { TreeStructure, Code, MagnifyingGlass, Shield, Globe } from '@phosphor-icons/react';

const ICON_MAP = {
  TreeStructure,
  Code,
  MagnifyingGlass,
  Shield,
  Globe,
};

const STATUS_COLORS = {
  idle: '#3B5284',
  coding: '#10B981',
  reviewing: '#F59E0B',
  clear: '#10B981',
  scanning: '#F59E0B',
  alert: '#EF4444',
  blocked: '#EF4444',
  analyzing: '#05A0F0',
  planning: '#05A0F0',
  reading: '#05A0F0',
};

function AgentRoster({ agents }) {
  return (
    <div data-testid="agent-roster-panel">
      <h1 className="panel-title">Agent Roster</h1>
      <p className="panel-subtitle">Multi-agent team with roles, statuses, and permissions</p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '1px', border: '1px solid var(--border-subtle)' }}>
        <div style={{
          display: 'grid',
          gridTemplateColumns: '40px 1fr 120px 160px',
          gap: '12px',
          padding: '8px 12px',
          background: 'var(--bg-surface)',
          borderBottom: '1px solid var(--border-subtle)',
        }}>
          <span className="overline" style={{ paddingTop: '2px' }}></span>
          <span className="overline">Agent</span>
          <span className="overline">Status</span>
          <span className="overline">Last Action</span>
        </div>

        {agents.map(agent => {
          const Icon = ICON_MAP[agent.icon] || Code;
          const statusColor = STATUS_COLORS[agent.status] || '#3B5284';
          return (
            <div
              key={agent.id}
              data-testid={`agent-${agent.id}`}
              style={{
                display: 'grid',
                gridTemplateColumns: '40px 1fr 120px 160px',
                gap: '12px',
                padding: '10px 12px',
                background: 'var(--bg-base)',
                borderBottom: '1px solid var(--border-subtle)',
                alignItems: 'center',
                transition: 'background 150ms ease-out',
                cursor: 'default',
              }}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(5,160,240,0.04)'}
              onMouseLeave={e => e.currentTarget.style.background = 'var(--bg-base)'}
            >
              <div style={{
                width: '32px',
                height: '32px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: 'var(--bg-surface)',
                border: '1px solid var(--border-subtle)',
                borderRadius: '2px',
              }}>
                <Icon size={16} weight="duotone" color={agent.color} />
              </div>

              <div>
                <div style={{ fontFamily: 'var(--font-heading)', fontSize: '13px', fontWeight: 500, color: 'var(--text-primary)' }}>
                  {agent.name}
                </div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '1px' }}>
                  {agent.description}
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <div style={{
                  width: '6px',
                  height: '6px',
                  borderRadius: '50%',
                  background: statusColor,
                  animation: agent.status !== 'idle' ? 'pulse 2s infinite' : 'none',
                }} />
                <span style={{
                  fontFamily: 'var(--font-code)',
                  fontSize: '11px',
                  color: statusColor,
                  textTransform: 'uppercase',
                  letterSpacing: '0.05em',
                }}>
                  {agent.status}
                </span>
              </div>

              <div style={{
                fontFamily: 'var(--font-code)',
                fontSize: '11px',
                color: 'var(--text-muted)',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap',
              }}>
                {agent.lastAction}
              </div>
            </div>
          );
        })}
      </div>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.4; }
        }
      `}</style>

      <div style={{ marginTop: '16px', padding: '12px', border: '1px solid var(--border-subtle)', background: 'var(--bg-surface)' }}>
        <div className="overline" style={{ marginBottom: '8px' }}>Permissions Model</div>
        <div style={{ fontSize: '12px', color: 'var(--text-muted)', lineHeight: '1.6' }}>
          All agents are <strong style={{ color: 'var(--text-primary)' }}>read-only by default</strong>.
          File writes, shell commands, browser actions, and network calls require <strong style={{ color: 'var(--warning)' }}>explicit approval</strong>.
        </div>
      </div>
    </div>
  );
}

export default AgentRoster;
