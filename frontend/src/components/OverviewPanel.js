import React from 'react';
import { CheckCircle, Stack, TreeStructure, GitDiff, ClockCounterClockwise, Plugs } from '@phosphor-icons/react';

function OverviewPanel({ stats, agents, providers }) {
  if (!stats) return null;

  const activeProvider = providers.find(p => p.status === 'active');
  const activeAgents = agents.filter(a => a.status !== 'idle').length;

  return (
    <div data-testid="overview-panel">
      <h1 className="panel-title">Cursor ING</h1>
      <p className="panel-subtitle">Privacy-first, open-source AI IDE on VSCodium / Phase 1 Preview Dashboard</p>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))',
        gap: '1px',
        border: '1px solid var(--border-subtle)',
        marginBottom: '24px',
      }}>
        <StatCard icon={CheckCircle} label="Validation" value={`${stats.totalFiles} checks passed`} color="var(--success)" />
        <StatCard icon={Stack} label="Agents" value={`${stats.agentDefinitions} defined / ${activeAgents} active`} color="var(--accent)" />
        <StatCard icon={Plugs} label="Provider" value={activeProvider?.name || 'None'} color="var(--accent)" />
        <StatCard icon={TreeStructure} label="Skills" value={`${stats.skills} skills`} color="var(--warning)" />
        <StatCard icon={GitDiff} label="Extension" value={`${stats.extensionFiles} TypeScript files`} color="var(--accent)" />
        <StatCard icon={ClockCounterClockwise} label="Activity" value={`${stats.activityEntries} log entries`} color="var(--text-muted)" />
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr',
        gap: '16px',
      }}>
        <div style={{ border: '1px solid var(--border-subtle)', padding: '16px' }}>
          <div className="overline" style={{ marginBottom: '12px' }}>Phase 1 Acceptance Criteria</div>
          {[
            'Repo audit completed',
            'AGENTS.md created',
            '.agents/ scaffold with registry, model-adapters, skills, agents, brain',
            'AI composer extension skeleton',
            'Mock/local provider (no API key)',
            'Agent roster with statuses and avatars',
            'Plan file format and plan viewer scaffold',
            'Activity log model',
            'Diff-preview/apply scaffold',
            'Documentation with run/test/limitations',
          ].map((item, i) => (
            <div key={i} style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '4px 0',
              fontSize: '12px',
            }}>
              <CheckCircle size={14} weight="fill" color="var(--success)" />
              <span style={{ color: 'var(--text-primary)' }}>{item}</span>
            </div>
          ))}
        </div>

        <div style={{ border: '1px solid var(--border-subtle)', padding: '16px' }}>
          <div className="overline" style={{ marginBottom: '12px' }}>Architecture</div>
          <pre style={{
            fontFamily: 'var(--font-code)',
            fontSize: '11px',
            lineHeight: '1.6',
            color: 'var(--text-muted)',
            margin: 0,
            whiteSpace: 'pre-wrap',
          }}>
{`User Interface
  Composer | Agents | Plans | Diffs
        |
Extension Host (TypeScript)
  commands, webviews, tree views
        |
Agent Orchestrator
  Planner > Coder > Reviewer > Security
        |
Provider Abstraction
  Mock | OpenAI | Anthropic | Ollama
        |
Activity Log / Audit Trail
        |
VSCodium / VS Code Runtime`}
          </pre>
        </div>
      </div>

      <div style={{
        marginTop: '16px',
        border: '1px solid var(--border-subtle)',
        padding: '16px',
      }}>
        <div className="overline" style={{ marginBottom: '12px' }}>Providers</div>
        <div style={{ display: 'flex', gap: '1px', flexWrap: 'wrap' }}>
          {providers.map(p => (
            <div key={p.id} data-testid={`provider-${p.id}`} style={{
              padding: '8px 16px',
              background: p.status === 'active' ? 'rgba(5,160,240,0.1)' : 'var(--bg-surface)',
              border: `1px solid ${p.status === 'active' ? 'var(--accent)' : 'var(--border-subtle)'}`,
              fontFamily: 'var(--font-code)',
              fontSize: '11px',
            }}>
              <div style={{ color: p.status === 'active' ? 'var(--accent)' : 'var(--text-muted)', marginBottom: '2px' }}>
                {p.name}
              </div>
              <div style={{ fontSize: '10px', color: 'var(--border-strong)' }}>
                {p.status.toUpperCase()} | Key: {p.requiresKey ? 'Required' : 'None'}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, color }) {
  return (
    <div style={{
      padding: '12px 16px',
      background: 'var(--bg-surface)',
      display: 'flex',
      alignItems: 'center',
      gap: '12px',
    }}>
      <Icon size={20} weight="duotone" color={color} />
      <div>
        <div className="overline" style={{ marginBottom: '2px' }}>{label}</div>
        <div style={{ fontSize: '13px', color: 'var(--text-primary)', fontFamily: 'var(--font-heading)', fontWeight: 500 }}>
          {value}
        </div>
      </div>
    </div>
  );
}

export default OverviewPanel;
