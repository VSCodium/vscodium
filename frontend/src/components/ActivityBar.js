import React from 'react';
import {
  Files, Search, GitBranch, Bug, Puzzle,
  Users, Bot, MessageCircle, Settings
} from 'lucide-react';

const TOP_ITEMS = [
  { id: 'explorer', icon: Files, label: 'Explorer' },
  { id: 'search', icon: Search, label: 'Search' },
  { id: 'scm', icon: GitBranch, label: 'Source Control' },
  { id: 'debug', icon: Bug, label: 'Run and Debug' },
  { id: 'extensions', icon: Puzzle, label: 'Extensions' },
  { id: 'agents', icon: Users, label: 'Cursor ING Agents' },
];

function ActivityBar({ active, onSelect, composerOpen, onToggleComposer }) {
  return (
    <div data-testid="activity-bar" style={{
      width: 48, minWidth: 48,
      background: 'var(--bg-activitybar)',
      borderRight: '1px solid var(--border)',
      display: 'flex', flexDirection: 'column',
      alignItems: 'center', paddingTop: 4,
    }}>
      {TOP_ITEMS.map(item => {
        const Icon = item.icon;
        const isActive = active === item.id;
        return (
          <button
            key={item.id}
            data-testid={`actbar-${item.id}`}
            title={item.label}
            onClick={() => onSelect(item.id)}
            style={{
              width: 48, height: 48,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              background: 'none', border: 'none',
              borderLeft: isActive ? '2px solid var(--accent)' : '2px solid transparent',
              cursor: 'pointer',
              opacity: isActive ? 1 : 0.45,
              color: isActive ? 'var(--text-bright)' : 'var(--text-muted)',
              transition: 'opacity 100ms',
            }}
            onMouseEnter={e => { if (!isActive) e.currentTarget.style.opacity = '0.75'; }}
            onMouseLeave={e => { if (!isActive) e.currentTarget.style.opacity = '0.45'; }}
          >
            <Icon size={20} strokeWidth={1.5} />
          </button>
        );
      })}

      <div style={{ flex: 1 }} />

      <button
        data-testid="actbar-composer-toggle"
        title="Toggle AI Composer"
        onClick={onToggleComposer}
        style={{
          width: 48, height: 48,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          background: 'none', border: 'none',
          borderLeft: composerOpen ? '2px solid var(--accent)' : '2px solid transparent',
          cursor: 'pointer',
          opacity: composerOpen ? 1 : 0.45,
          color: composerOpen ? 'var(--accent)' : 'var(--text-muted)',
          marginBottom: 4,
        }}
      >
        <MessageCircle size={20} strokeWidth={1.5} />
      </button>

      <button
        data-testid="actbar-settings"
        title="Manage"
        style={{
          width: 48, height: 48,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          background: 'none', border: 'none',
          cursor: 'pointer', opacity: 0.35,
          color: 'var(--text-muted)', marginBottom: 4,
        }}
      >
        <Settings size={18} strokeWidth={1.5} />
      </button>
    </div>
  );
}

export default ActivityBar;
