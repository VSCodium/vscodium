import React from 'react';
import { X } from 'lucide-react';

function EditorTabs({ tabs, activeTab, onSelect, onClose }) {
  return (
    <div data-testid="editor-tabs" style={{
      display: 'flex', background: 'var(--bg-base)',
      borderBottom: '1px solid var(--border)',
      height: 35, minHeight: 35, overflow: 'hidden',
    }}>
      {tabs.map(tab => {
        const isActive = tab.id === activeTab;
        return (
          <div
            key={tab.id}
            data-testid={`tab-${tab.id}`}
            onClick={() => onSelect(tab.id)}
            style={{
              display: 'flex', alignItems: 'center', gap: 6,
              padding: '0 12px', height: '100%',
              fontSize: 12, cursor: 'pointer', userSelect: 'none',
              background: isActive ? 'var(--bg-tab-active)' : 'var(--bg-tab-inactive)',
              color: isActive ? 'var(--text-bright)' : 'var(--text-muted)',
              borderRight: '1px solid var(--border)',
              borderBottom: isActive ? '1px solid var(--bg-tab-active)' : '1px solid var(--border)',
              marginBottom: isActive ? -1 : 0,
            }}
          >
            <TabDot type={tab.type} />
            <span>{tab.label}</span>
            <button
              data-testid={`tab-close-${tab.id}`}
              onClick={(e) => { e.stopPropagation(); onClose(tab.id); }}
              style={{
                background: 'none', border: 'none',
                color: 'var(--text-dimmed)', cursor: 'pointer',
                padding: 2, display: 'flex', borderRadius: 2, marginLeft: 4,
              }}
              onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
              onMouseLeave={e => e.currentTarget.style.background = 'none'}
            >
              <X size={12} />
            </button>
          </div>
        );
      })}
      <div style={{ flex: 1, borderBottom: '1px solid var(--border)' }} />
    </div>
  );
}

function TabDot({ type }) {
  const colors = { welcome: 'var(--accent)', plan: 'var(--warning)', diff: 'var(--success)', code: 'var(--text-muted)' };
  return <span style={{ width: 6, height: 6, borderRadius: '50%', background: colors[type] || 'var(--text-dimmed)', flexShrink: 0 }} />;
}

export default EditorTabs;
