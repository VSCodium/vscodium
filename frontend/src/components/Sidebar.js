import React from 'react';
import { TreeStructure, Code, MagnifyingGlass, Shield, Globe, Stack, ListChecks, ClockCounterClockwise, GitDiff, Terminal, House } from '@phosphor-icons/react';

const NAV_ITEMS = [
  { id: 'overview', label: 'Overview', icon: House },
  { id: 'agents', label: 'Agent Roster', icon: Stack },
  { id: 'plans', label: 'Plan Viewer', icon: ListChecks },
  { id: 'activity', label: 'Activity Log', icon: ClockCounterClockwise },
  { id: 'diff', label: 'Diff Preview', icon: GitDiff },
  { id: 'composer', label: 'Composer', icon: Terminal },
];

function Sidebar({ activePanel, onNavigate }) {
  return (
    <aside data-testid="sidebar" style={{
      background: 'var(--bg-surface)',
      borderRight: '1px solid var(--border-subtle)',
      display: 'flex',
      flexDirection: 'column',
      height: '100vh',
      overflow: 'hidden',
    }}>
      <div data-testid="sidebar-brand" style={{
        padding: '16px',
        borderBottom: '1px solid var(--border-subtle)',
      }}>
        <div style={{
          fontFamily: 'var(--font-heading)',
          fontSize: '14px',
          fontWeight: 600,
          color: 'var(--accent)',
          letterSpacing: '-0.02em',
        }}>CURSOR ING</div>
        <div style={{
          fontFamily: 'var(--font-heading)',
          fontSize: '10px',
          color: 'var(--text-muted)',
          letterSpacing: '0.1em',
          marginTop: '2px',
        }}>PHASE 1 PREVIEW</div>
      </div>

      <nav style={{ flex: 1, padding: '8px 0' }}>
        {NAV_ITEMS.map(item => {
          const Icon = item.icon;
          const isActive = activePanel === item.id;
          return (
            <button
              key={item.id}
              data-testid={`nav-${item.id}`}
              onClick={() => onNavigate(item.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                width: '100%',
                padding: '8px 16px',
                border: 'none',
                background: isActive ? 'var(--bg-elevated)' : 'transparent',
                color: isActive ? 'var(--accent)' : 'var(--text-muted)',
                fontFamily: 'var(--font-body)',
                fontSize: '13px',
                cursor: 'pointer',
                textAlign: 'left',
                borderLeft: isActive ? '2px solid var(--accent)' : '2px solid transparent',
                transition: 'background 150ms ease-out, color 150ms ease-out',
              }}
              onMouseEnter={e => {
                if (!isActive) {
                  e.currentTarget.style.background = 'rgba(5,160,240,0.08)';
                  e.currentTarget.style.color = 'var(--text-primary)';
                }
              }}
              onMouseLeave={e => {
                if (!isActive) {
                  e.currentTarget.style.background = 'transparent';
                  e.currentTarget.style.color = 'var(--text-muted)';
                }
              }}
            >
              <Icon size={16} weight={isActive ? 'fill' : 'regular'} />
              {item.label}
            </button>
          );
        })}
      </nav>

      <div style={{
        padding: '12px 16px',
        borderTop: '1px solid var(--border-subtle)',
        fontSize: '10px',
        color: 'var(--border-strong)',
        fontFamily: 'var(--font-code)',
      }}>
        v0.1.0 / MIT / No telemetry
      </div>
    </aside>
  );
}

export default Sidebar;
