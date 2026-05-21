import React from 'react';

const SEVERITY_COLORS = {
  info: 'var(--text-muted)',
  warning: 'var(--warning)',
  error: 'var(--error)',
};

const ACTOR_COLORS = {
  system: 'var(--border-strong)',
  user: 'var(--accent)',
  planner: '#05A0F0',
  coder: '#10B981',
  reviewer: '#F59E0B',
  security: '#EF4444',
  browser: '#05A0F0',
};

function ActivityLog({ entries }) {
  return (
    <div data-testid="activity-log-panel">
      <h1 className="panel-title">Activity Log</h1>
      <p className="panel-subtitle">Structured audit trail of all agent and system actions ({entries.length} entries)</p>

      <div style={{
        border: '1px solid var(--border-subtle)',
        maxHeight: 'calc(100vh - 160px)',
        overflow: 'auto',
      }}>
        <div style={{
          display: 'grid',
          gridTemplateColumns: '90px 80px 80px 1fr',
          gap: '12px',
          padding: '8px 12px',
          background: 'var(--bg-surface)',
          borderBottom: '1px solid var(--border-subtle)',
          position: 'sticky',
          top: 0,
          zIndex: 1,
        }}>
          <span className="overline">Time</span>
          <span className="overline">Actor</span>
          <span className="overline">Category</span>
          <span className="overline">Message</span>
        </div>

        {entries.map(entry => (
          <div
            key={entry.id}
            data-testid={`activity-entry-${entry.id}`}
            style={{
              display: 'grid',
              gridTemplateColumns: '90px 80px 80px 1fr',
              gap: '12px',
              padding: '4px 12px',
              borderBottom: '1px solid var(--bg-surface)',
              fontFamily: 'var(--font-code)',
              fontSize: '12px',
              lineHeight: '1.6',
              transition: 'background 100ms',
            }}
            onMouseEnter={e => e.currentTarget.style.background = 'rgba(5,160,240,0.03)'}
            onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
          >
            <span style={{ color: 'var(--border-strong)' }}>
              {entry.timestamp.slice(11, 23)}
            </span>
            <span style={{ color: ACTOR_COLORS[entry.actor] || 'var(--text-muted)' }}>
              [{entry.actor}]
            </span>
            <span style={{ color: 'var(--accent)', opacity: 0.7 }}>
              {entry.category}
            </span>
            <span style={{ color: SEVERITY_COLORS[entry.severity] || 'var(--text-muted)' }}>
              {entry.message}
            </span>
          </div>
        ))}
      </div>

      <div style={{
        marginTop: '12px',
        padding: '8px 12px',
        background: 'var(--bg-surface)',
        border: '1px solid var(--border-subtle)',
        fontSize: '11px',
        color: 'var(--text-muted)',
        fontFamily: 'var(--font-code)',
      }}>
        All actions logged locally. No telemetry. No external network calls.
      </div>
    </div>
  );
}

export default ActivityLog;
