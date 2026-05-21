import React from 'react';
import { CheckCircle, Plug } from 'lucide-react';

function WelcomeEditor({ stats, agents, providers }) {
  const activeProvider = providers?.find(p => p.status === 'active');

  return (
    <div data-testid="editor-welcome" style={{
      flex: 1, overflow: 'auto',
      background: 'var(--bg-editor)',
      padding: '32px 48px',
      fontFamily: 'var(--font-ui)',
    }}>
      <div style={{ maxWidth: 640 }}>
        <h1 style={{
          fontFamily: 'var(--font-heading)', fontSize: 24, fontWeight: 500,
          color: 'var(--accent)', marginBottom: 4, letterSpacing: '-0.02em',
        }}>Cursor ING</h1>
        <p style={{ fontSize: 13, color: 'var(--text-muted)', marginBottom: 28 }}>
          Privacy-first, open-source AI IDE on VSCodium &mdash; Phase 1
        </p>

        <Section title="Start">
          <Cmd label="Open Composer" key1="Ctrl+Shift+I" desc="AI chat and code generation" />
          <Cmd label="Open Plan" key1="Ctrl+Shift+P" desc="View execution plans" />
          <Cmd label="Agent Roster" key1="Ctrl+Shift+A" desc="View agent team" />
          <Cmd label="Diff Preview" key1="Ctrl+Shift+D" desc="Review changes" />
        </Section>

        <Section title="Recent">
          <div style={{ fontSize: 12, display: 'flex', alignItems: 'center', gap: 6, padding: '2px 0', color: 'var(--text-primary)' }}>
            <span style={{ color: 'var(--warning)' }}>&#9670;</span>
            auth-module.plan <span style={{ color: 'var(--text-dimmed)' }}>&mdash; 5 steps, 2 done</span>
          </div>
        </Section>

        <Section title="Phase 1 Status">
          {[
            'Repo audit completed',
            'AGENTS.md canonical instruction file',
            '.agents/ three-layer harness',
            'Extension skeleton (TypeScript)',
            'Mock provider (no API key)',
            'Agent roster (5 agents)',
            'Plan format + viewer',
            'Activity log model',
            'Diff-preview scaffold',
            'Validation (53 checks)',
          ].map((item, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: 'var(--text-primary)', padding: '1px 0' }}>
              <CheckCircle size={13} color="var(--success)" />
              {item}
            </div>
          ))}
        </Section>

        <Section title="Provider">
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: 'var(--text-primary)' }}>
            <Plug size={13} color="var(--accent)" />
            {activeProvider?.name || 'None'}
            <span style={{ color: 'var(--text-dimmed)' }}>|</span>
            <span style={{ color: 'var(--text-muted)' }}>{activeProvider?.model}</span>
            <span style={{ color: 'var(--success)', fontSize: 11 }}>Active</span>
          </div>
          <div style={{ fontSize: 11, color: 'var(--text-dimmed)', marginTop: 4 }}>
            {providers?.filter(p => p.status === 'planned').map(p => p.name).join(' / ')} &mdash; Phase 2
          </div>
        </Section>
      </div>
    </div>
  );
}

function Section({ title, children }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <div style={{
        fontSize: 11, fontWeight: 600, color: 'var(--text-muted)',
        textTransform: 'uppercase', letterSpacing: '0.06em',
        marginBottom: 8, paddingBottom: 4, borderBottom: '1px solid var(--border)',
      }}>{title}</div>
      {children}
    </div>
  );
}

function Cmd({ label, key1, desc }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '2px 0', fontSize: 12, cursor: 'pointer' }}
      onMouseEnter={e => e.currentTarget.firstChild.style.color = 'var(--accent)'}
      onMouseLeave={e => e.currentTarget.firstChild.style.color = 'var(--text-primary)'}
    >
      <span style={{ color: 'var(--text-primary)', transition: 'color 100ms' }}>{label}</span>
      <span style={{
        fontSize: 10, color: 'var(--text-dimmed)', fontFamily: 'var(--font-mono)',
        padding: '1px 4px', border: '1px solid var(--border)', borderRadius: 2,
      }}>{key1}</span>
      <span style={{ color: 'var(--text-dimmed)', fontSize: 11 }}>{desc}</span>
    </div>
  );
}

export default WelcomeEditor;
