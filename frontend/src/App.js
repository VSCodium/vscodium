import React, { useState, useEffect, useCallback } from 'react';
import './App.css';
import IDESurface from './surfaces/IDESurface';
import WebPortal from './surfaces/WebPortal';

const API = process.env.REACT_APP_BACKEND_URL;

function App() {
  const [surface, setSurface] = useState('ide');
  const [data, setData] = useState({ agents: [], plan: null, activity: [], diff: null, providers: [] });

  const fetchData = useCallback(async () => {
    try {
      const [ag, pl, ac, df, pr] = await Promise.all([
        fetch(`${API}/api/agents`).then(r => r.json()),
        fetch(`${API}/api/plans`).then(r => r.json()),
        fetch(`${API}/api/activity`).then(r => r.json()),
        fetch(`${API}/api/diff`).then(r => r.json()),
        fetch(`${API}/api/providers`).then(r => r.json()),
      ]);
      setData({ agents: ag, plan: pl[0] || null, activity: ac, diff: df[0] || null, providers: pr });
    } catch (err) { console.error(err); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  return (
    <div data-testid="app-root" style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Tiny surface switcher at very top */}
      <div data-testid="surface-switcher" style={{
        height: 28, display: 'flex', alignItems: 'center',
        background: surface === 'ide' ? 'var(--ide-titlebar)' : 'var(--web-sidebar)',
        borderBottom: `1px solid ${surface === 'ide' ? 'var(--ide-border)' : 'var(--web-border)'}`,
        padding: '0 12px', gap: 0, fontSize: 11, userSelect: 'none',
      }}>
        <SurfaceTab id="ide" label="Cursor ING IDE" active={surface === 'ide'} onClick={setSurface} dark />
        <SurfaceTab id="web" label="Web Portal" active={surface === 'web'} onClick={setSurface} dark={surface === 'ide'} />
        <div style={{ flex: 1 }} />
        <span style={{ fontSize: 10, color: surface === 'ide' ? 'var(--ide-text-dim)' : 'var(--web-text-dim)', fontFamily: 'var(--font-mono)' }}>
          Phase 1 Preview
        </span>
      </div>
      <div style={{ flex: 1, overflow: 'hidden' }}>
        {surface === 'ide' ? <IDESurface data={data} /> : <WebPortal />}
      </div>
    </div>
  );
}

function SurfaceTab({ id, label, active, onClick, dark }) {
  return (
    <button data-testid={`switch-${id}`} onClick={() => onClick(id)} style={{
      padding: '0 14px', height: '100%', border: 'none', cursor: 'pointer',
      fontSize: 11, fontWeight: active ? 600 : 400, letterSpacing: '0.01em',
      background: active
        ? (id === 'ide' ? 'var(--ide-bg)' : 'var(--web-surface)')
        : 'transparent',
      color: active
        ? (id === 'ide' ? 'var(--ide-accent)' : 'var(--web-accent)')
        : (dark ? 'var(--ide-text-dim)' : 'var(--web-text-dim)'),
      borderBottom: active ? `2px solid ${id === 'ide' ? 'var(--ide-accent)' : 'var(--web-accent)'}` : '2px solid transparent',
    }}>{label}</button>
  );
}

export default App;
