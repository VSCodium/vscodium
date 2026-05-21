import React from 'react';
import { X, Terminal, List, AlertTriangle } from 'lucide-react';

const TABS = [
  { id: 'activity', label: 'ACTIVITY LOG', icon: List },
  { id: 'terminal', label: 'TERMINAL', icon: Terminal },
  { id: 'problems', label: 'PROBLEMS', icon: AlertTriangle },
];

const ACTOR_COLORS = {
  system: 'var(--text-dimmed)',
  user: 'var(--accent)',
  planner: '#05A0F0',
  coder: '#10B981',
  reviewer: '#F59E0B',
  security: '#EF4444',
};

function BottomPanel({ activeTab, onTabChange, activity, onClose }) {
  return (
    <div data-testid="bottom-panel" style={{
      height: 200, minHeight: 120,
      borderTop: '1px solid var(--border)',
      background: 'var(--bg-surface)',
      display: 'flex', flexDirection: 'column',
    }}>
      <div style={{
        display: 'flex', alignItems: 'center',
        borderBottom: '1px solid var(--border)',
        height: 30, minHeight: 30, paddingLeft: 8,
      }}>
        {TABS.map(tab => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button key={tab.id} data-testid={`bottom-tab-${tab.id}`} onClick={() => onTabChange(tab.id)}
              style={{
                display: 'flex', alignItems: 'center', gap: 4,
                padding: '0 10px', height: '100%',
                background: 'none', border: 'none',
                borderBottom: isActive ? '1px solid var(--accent)' : '1px solid transparent',
                color: isActive ? 'var(--text-bright)' : 'var(--text-dimmed)',
                fontSize: 11, cursor: 'pointer',
                textTransform: 'uppercase', letterSpacing: '0.04em',
              }}
            >
              <Icon size={12} strokeWidth={1.5} />
              {tab.label}
              {tab.id === 'activity' && <span style={{ fontSize: 9, color: 'var(--text-dimmed)', marginLeft: 2 }}>{activity?.length || 0}</span>}
            </button>
          );
        })}
        <div style={{ flex: 1 }} />
        <button data-testid="bottom-close-btn" onClick={onClose} style={{ background: 'none', border: 'none', color: 'var(--text-dimmed)', cursor: 'pointer', padding: '0 8px' }}>
          <X size={12} />
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', fontFamily: 'var(--font-mono)', fontSize: 11 }}>
        {activeTab === 'activity' && (
          <div data-testid="activity-log">
            {(activity || []).map(e => (
              <div key={e.id} data-testid={`log-${e.id}`} style={{ display: 'flex', gap: 8, padding: '2px 12px', lineHeight: '18px' }}
                onMouseEnter={ev => ev.currentTarget.style.background = 'rgba(255,255,255,0.02)'}
                onMouseLeave={ev => ev.currentTarget.style.background = 'transparent'}
              >
                <span style={{ color: 'var(--text-dimmed)', minWidth: 80, flexShrink: 0 }}>{e.timestamp.slice(11, 23)}</span>
                <span style={{ color: ACTOR_COLORS[e.actor] || 'var(--text-dimmed)', minWidth: 70, flexShrink: 0 }}>[{e.actor}]</span>
                <span style={{ color: 'var(--accent)', minWidth: 70, flexShrink: 0, opacity: 0.6 }}>{e.category}</span>
                <span style={{ color: e.severity === 'warning' ? 'var(--warning)' : 'var(--text-primary)' }}>{e.message}</span>
              </div>
            ))}
          </div>
        )}
        {activeTab === 'terminal' && (
          <div data-testid="terminal-panel" style={{ padding: '8px 12px', color: 'var(--text-dimmed)' }}>
            <span style={{ color: 'var(--success)' }}>cursor-ing</span>
            <span style={{ color: 'var(--text-dimmed)' }}>:</span>
            <span style={{ color: 'var(--accent)' }}>~/project</span>
            <span style={{ color: 'var(--text-primary)' }}>$ </span>
            <span style={{ borderLeft: '1px solid var(--accent)', animation: 'blink 1s step-end infinite' }}>&nbsp;</span>
            <style>{`@keyframes blink { 50% { opacity: 0; } }`}</style>
          </div>
        )}
        {activeTab === 'problems' && (
          <div data-testid="problems-panel" style={{ padding: '8px 12px', color: 'var(--text-dimmed)' }}>No problems detected.</div>
        )}
      </div>
    </div>
  );
}

export default BottomPanel;
