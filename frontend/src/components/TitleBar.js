import React from 'react';

function TitleBar() {
  return (
    <div data-testid="titlebar" style={{
      height: 30,
      background: 'var(--bg-titlebar)',
      borderBottom: '1px solid var(--border)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: 11,
      color: 'var(--text-muted)',
      fontFamily: 'var(--font-ui)',
      userSelect: 'none',
      WebkitAppRegion: 'drag',
      letterSpacing: '0.02em',
    }}>
      <span style={{ color: 'var(--text-dimmed)' }}>auth-module.plan</span>
      <span style={{ margin: '0 6px', color: 'var(--text-dimmed)' }}>&mdash;</span>
      <span style={{ color: 'var(--accent)', fontWeight: 500 }}>Cursor ING</span>
    </div>
  );
}

export default TitleBar;
