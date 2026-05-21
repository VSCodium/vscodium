import React from 'react';
import { GitBranch, ShieldCheck } from 'lucide-react';

function StatusBar({ providers, agents, bottomOpen, onToggleBottom }) {
  const activeProvider = providers?.find(p => p.status === 'active');
  const activeCount = agents?.filter(a => a.status !== 'idle').length || 0;

  return (
    <div data-testid="status-bar" style={{
      height: 22, minHeight: 22,
      background: 'var(--bg-statusbar)',
      display: 'flex', alignItems: 'center',
      padding: '0 8px', fontSize: 11,
      color: '#fff', fontFamily: 'var(--font-ui)',
      userSelect: 'none', gap: 2,
    }}>
      <SI><GitBranch size={12} /><span>main</span></SI>
      <SI onClick={onToggleBottom}><span>{bottomOpen ? 'Panel' : 'Panel (hidden)'}</span></SI>
      <div style={{ flex: 1 }} />
      <SI><span style={{ fontFamily: 'var(--font-mono)' }}>{activeCount > 0 ? `${activeCount} agents active` : 'agents idle'}</span></SI>
      <SI><span style={{ fontFamily: 'var(--font-mono)' }}>{activeProvider?.model || 'no provider'}</span></SI>
      <SI><ShieldCheck size={12} /><span>No Telemetry</span></SI>
      <SI><span style={{ fontFamily: 'var(--font-mono)' }}>Cursor ING v0.1.0</span></SI>
    </div>
  );
}

function SI({ children, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 4,
      padding: '0 6px', height: '100%',
      cursor: onClick ? 'pointer' : 'default',
    }}
    onMouseEnter={e => { if (onClick) e.currentTarget.style.background = 'rgba(255,255,255,0.12)'; }}
    onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
    >{children}</div>
  );
}

export default StatusBar;
