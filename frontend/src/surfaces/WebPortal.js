import React, { useState } from 'react';
import {
  Bot, Zap, Bug, Puzzle, Link, Users, BarChart3, Plus,
  GitFork, GitBranch, Server, CheckCircle, Circle,
  ChevronRight, Shield, Sparkles, ArrowRight, ExternalLink
} from 'lucide-react';

const NAV = [
  { id: 'agent', label: 'New Agent', icon: Bot },
  { id: 'automations', label: 'Automations', icon: Zap },
  { id: 'bugbot', label: 'Bugbot', icon: Bug },
  { id: 'plugins', label: 'Plugins', icon: Puzzle },
  { id: 'integrations', label: 'Integrations', icon: Link },
  { id: 'canvases', label: 'Shared Canvases', icon: Users, soon: true },
  { id: 'members', label: 'Members', icon: Users, soon: true },
  { id: 'usage', label: 'Usage', icon: BarChart3, soon: true },
];

const SETUP_STEPS = [
  { label: 'Connect GitHub or GitLab', done: true, icon: GitFork },
  { label: 'Add a local project repository', done: true, icon: GitBranch },
  { label: 'Configure mock/local provider', done: true, icon: Server },
  { label: 'Enable first plugin', done: false, icon: Puzzle },
  { label: 'Run first agent task', done: false, icon: Bot },
];

const PLUGINS = [
  { name: 'Code Review Agent', desc: 'Automated PR review with security checks', tag: 'Built-in', color: '#0969DA' },
  { name: 'TypeScript Fixer', desc: 'Auto-fix TypeScript errors across project', tag: 'Popular', color: '#1A7F37' },
  { name: 'Doc Generator', desc: 'Generate API docs from code', tag: 'New', color: '#8250DF' },
  { name: 'Test Writer', desc: 'Generate unit tests for functions', tag: 'Popular', color: '#1A7F37' },
];

const AUTOMATIONS = [
  { name: 'PR Review on Push', desc: 'Auto-review every pull request', status: 'active' },
  { name: 'Security Scan Nightly', desc: 'Scan codebase for vulnerabilities at 2am', status: 'active' },
  { name: 'Stale Branch Cleanup', desc: 'Archive branches older than 30 days', status: 'paused' },
];

export default function WebPortal() {
  const [view, setView] = useState('agent');

  return (
    <div data-testid="web-portal" style={{ display: 'flex', height: '100%', background: 'var(--web-bg)', color: 'var(--web-text)', fontFamily: 'var(--font-ui)' }}>
      {/* Left Nav */}
      <nav data-testid="portal-nav" style={{
        width: 220, background: 'var(--web-sidebar)', borderRight: '1px solid var(--web-border)',
        display: 'flex', flexDirection: 'column', padding: '16px 0',
      }}>
        <div style={{ padding: '0 16px 16px', display: 'flex', alignItems: 'center', gap: 8, borderBottom: '1px solid var(--web-border-light)', marginBottom: 8 }}>
          <div style={{ width: 28, height: 28, borderRadius: 6, background: 'var(--web-accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Sparkles size={16} color="#fff" />
          </div>
          <div>
            <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--web-text)' }}>Cursor ING</div>
            <div style={{ fontSize: 10, color: 'var(--web-text-dim)' }}>Web Portal</div>
          </div>
        </div>

        {NAV.map(n => (
          <button key={n.id} data-testid={`nav-${n.id}`} onClick={() => setView(n.id)}
            style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '7px 16px', border: 'none', width: '100%',
              background: view === n.id ? 'var(--web-accent-light)' : 'transparent',
              color: view === n.id ? 'var(--web-accent)' : 'var(--web-text-muted)',
              fontWeight: view === n.id ? 600 : 400,
              fontSize: 13, cursor: 'pointer', textAlign: 'left',
              borderRight: view === n.id ? '2px solid var(--web-accent)' : '2px solid transparent',
            }}
          >
            <n.icon size={15} strokeWidth={1.5} />
            <span style={{ flex: 1 }}>{n.label}</span>
            {n.soon && <span style={{ fontSize: 9, color: 'var(--web-text-dim)', background: 'var(--web-border-light)', padding: '1px 5px', borderRadius: 3 }}>Soon</span>}
          </button>
        ))}

        <div style={{ flex: 1 }} />
        <div style={{ padding: '12px 16px', borderTop: '1px solid var(--web-border-light)', fontSize: 10, color: 'var(--web-text-dim)' }}>
          <Shield size={11} /> No telemetry / MIT license / v0.1.0
        </div>
      </nav>

      {/* Main Content */}
      <main data-testid="portal-content" style={{ flex: 1, overflowY: 'auto', padding: '32px 40px' }}>
        {view === 'agent' && <NewAgentView />}
        {view === 'plugins' && <PluginsView />}
        {view === 'automations' && <AutomationsView />}
        {view === 'integrations' && <IntegrationsView />}
        {view === 'bugbot' && <BugbotView />}
        {['canvases', 'members', 'usage'].includes(view) && <ComingSoon name={view} />}
      </main>
    </div>
  );
}

function NewAgentView() {
  return (
    <div data-testid="new-agent-view" style={{ maxWidth: 680 }}>
      <h1 style={{ fontSize: 22, fontWeight: 600, color: 'var(--web-text)', marginBottom: 4 }}>New Agent</h1>
      <p style={{ fontSize: 14, color: 'var(--web-text-muted)', marginBottom: 24 }}>Describe a task and an agent will plan, code, review, and deliver it.</p>

      {/* Prompt box */}
      <div data-testid="agent-prompt" style={{
        background: 'var(--web-surface)', border: '1px solid var(--web-border)',
        borderRadius: 8, padding: 20, marginBottom: 28,
        boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
      }}>
        <textarea data-testid="prompt-input" placeholder="Describe what you want the agent to do...&#10;&#10;e.g. 'Refactor the auth module, add session validation, write tests'" style={{
          width: '100%', height: 80, resize: 'none', border: '1px solid var(--web-border-light)',
          borderRadius: 6, padding: '12px 14px', fontSize: 14, fontFamily: 'var(--font-ui)',
          color: 'var(--web-text)', background: 'var(--web-bg)', outline: 'none',
          lineHeight: 1.5,
        }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>
          <select style={{ padding: '6px 10px', border: '1px solid var(--web-border)', borderRadius: 6, fontSize: 12, color: 'var(--web-text-muted)', background: 'var(--web-surface)' }}>
            <option>Mock Provider (local)</option>
            <option disabled>OpenAI (Phase 2)</option>
            <option disabled>Anthropic (Phase 2)</option>
            <option disabled>Ollama (Phase 2)</option>
          </select>
          <select style={{ padding: '6px 10px', border: '1px solid var(--web-border)', borderRadius: 6, fontSize: 12, color: 'var(--web-text-muted)', background: 'var(--web-surface)' }}>
            <option>Full team (Planner + Coder + Reviewer + Security)</option>
            <option>Solo agent</option>
          </select>
          <div style={{ flex: 1 }} />
          <button data-testid="start-agent-btn" style={{
            padding: '8px 20px', background: 'var(--web-accent)', color: '#fff',
            border: 'none', borderRadius: 6, fontSize: 13, fontWeight: 600,
            cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6,
          }}>
            <Sparkles size={14} /> Start Agent
          </button>
        </div>
      </div>

      {/* Setup Checklist */}
      <div style={{ marginBottom: 28 }}>
        <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 12, color: 'var(--web-text)' }}>Setup Checklist</h3>
        <div style={{ background: 'var(--web-surface)', border: '1px solid var(--web-border)', borderRadius: 8, overflow: 'hidden' }}>
          {SETUP_STEPS.map((s, i) => (
            <div key={i} data-testid={`setup-${i}`} style={{
              display: 'flex', alignItems: 'center', gap: 10, padding: '10px 16px',
              borderBottom: i < SETUP_STEPS.length - 1 ? '1px solid var(--web-border-light)' : 'none',
            }}>
              {s.done ? <CheckCircle size={16} color="var(--web-success)" /> : <Circle size={16} color="var(--web-text-dim)" />}
              <s.icon size={14} color="var(--web-text-muted)" strokeWidth={1.5} />
              <span style={{ fontSize: 13, color: s.done ? 'var(--web-text)' : 'var(--web-text-muted)', flex: 1 }}>{s.label}</span>
              {!s.done && <button style={{ fontSize: 11, color: 'var(--web-accent)', background: 'none', border: '1px solid var(--web-accent)', padding: '3px 10px', borderRadius: 4, cursor: 'pointer' }}>Configure</button>}
            </div>
          ))}
        </div>
      </div>

      {/* Suggested Plugins */}
      <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 12 }}>Suggested Plugins</h3>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {PLUGINS.slice(0, 2).map(p => <PluginCard key={p.name} plugin={p} />)}
      </div>
    </div>
  );
}

function PluginsView() {
  return (
    <div data-testid="plugins-view" style={{ maxWidth: 720 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 600 }}>Plugins</h1>
          <p style={{ fontSize: 13, color: 'var(--web-text-muted)' }}>Extend Cursor ING with agent skills and tools.</p>
        </div>
        <button style={{ padding: '8px 16px', background: 'var(--web-accent)', color: '#fff', border: 'none', borderRadius: 6, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4 }}>
          <Plus size={14} /> Add Plugin
        </button>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {PLUGINS.map(p => <PluginCard key={p.name} plugin={p} />)}
      </div>
    </div>
  );
}

function AutomationsView() {
  return (
    <div data-testid="automations-view" style={{ maxWidth: 720 }}>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 4 }}>Automations</h1>
      <p style={{ fontSize: 13, color: 'var(--web-text-muted)', marginBottom: 20 }}>Scheduled and event-triggered agent tasks.</p>
      <div style={{ background: 'var(--web-surface)', border: '1px solid var(--web-border)', borderRadius: 8, overflow: 'hidden' }}>
        {AUTOMATIONS.map((a, i) => (
          <div key={a.name} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderBottom: i < AUTOMATIONS.length - 1 ? '1px solid var(--web-border-light)' : 'none' }}>
            <Zap size={16} color={a.status === 'active' ? 'var(--web-success)' : 'var(--web-text-dim)'} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 500 }}>{a.name}</div>
              <div style={{ fontSize: 12, color: 'var(--web-text-muted)' }}>{a.desc}</div>
            </div>
            <span style={{
              fontSize: 11, padding: '2px 8px', borderRadius: 10,
              background: a.status === 'active' ? 'rgba(26,127,55,0.1)' : 'var(--web-border-light)',
              color: a.status === 'active' ? 'var(--web-success)' : 'var(--web-text-dim)',
            }}>{a.status}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function IntegrationsView() {
  const integrations = [
    { name: 'GitHub', desc: 'Connected', icon: GitFork, connected: true },
    { name: 'GitLab', desc: 'Not connected', icon: GitBranch, connected: false },
    { name: 'Mock Provider', desc: 'Active (local, no key)', icon: Server, connected: true },
  ];
  return (
    <div data-testid="integrations-view" style={{ maxWidth: 720 }}>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 4 }}>Integrations</h1>
      <p style={{ fontSize: 13, color: 'var(--web-text-muted)', marginBottom: 20 }}>Connect repositories, providers, and external services.</p>
      <div style={{ background: 'var(--web-surface)', border: '1px solid var(--web-border)', borderRadius: 8, overflow: 'hidden' }}>
        {integrations.map((ig, i) => (
          <div key={ig.name} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderBottom: i < integrations.length - 1 ? '1px solid var(--web-border-light)' : 'none' }}>
            <ig.icon size={18} color={ig.connected ? 'var(--web-accent)' : 'var(--web-text-dim)'} strokeWidth={1.5} />
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 500 }}>{ig.name}</div>
              <div style={{ fontSize: 12, color: ig.connected ? 'var(--web-success)' : 'var(--web-text-muted)' }}>{ig.desc}</div>
            </div>
            {!ig.connected && <button style={{ fontSize: 11, color: 'var(--web-accent)', background: 'none', border: '1px solid var(--web-accent)', padding: '4px 12px', borderRadius: 4, cursor: 'pointer' }}>Connect</button>}
          </div>
        ))}
      </div>
    </div>
  );
}

function BugbotView() {
  return (
    <div data-testid="bugbot-view" style={{ maxWidth: 720 }}>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 4 }}>Bugbot</h1>
      <p style={{ fontSize: 13, color: 'var(--web-text-muted)', marginBottom: 20 }}>Automatically detect, triage, and fix bugs.</p>
      <div style={{ padding: 24, background: 'var(--web-surface)', border: '1px solid var(--web-border)', borderRadius: 8, textAlign: 'center' }}>
        <Bug size={32} color="var(--web-text-dim)" strokeWidth={1} style={{ marginBottom: 8 }} />
        <div style={{ fontSize: 14, color: 'var(--web-text-muted)' }}>No bugs detected in current session.</div>
        <div style={{ fontSize: 12, color: 'var(--web-text-dim)', marginTop: 4 }}>Bugbot runs automatically when agents are active.</div>
      </div>
    </div>
  );
}

function ComingSoon({ name }) {
  return (
    <div data-testid={`${name}-view`} style={{ maxWidth: 720 }}>
      <h1 style={{ fontSize: 22, fontWeight: 600, marginBottom: 4, textTransform: 'capitalize' }}>{name}</h1>
      <p style={{ fontSize: 14, color: 'var(--web-text-muted)' }}>Coming in a future phase.</p>
    </div>
  );
}

function PluginCard({ plugin }) {
  return (
    <div style={{
      background: 'var(--web-surface)', border: '1px solid var(--web-border)', borderRadius: 8,
      padding: 16, cursor: 'pointer', transition: 'border-color 150ms, box-shadow 150ms',
    }}
    onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--web-accent)'; e.currentTarget.style.boxShadow = '0 2px 8px rgba(9,105,218,0.08)'; }}
    onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--web-border)'; e.currentTarget.style.boxShadow = 'none'; }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
        <Puzzle size={16} color={plugin.color} />
        <span style={{ fontSize: 13, fontWeight: 600 }}>{plugin.name}</span>
        <span style={{ fontSize: 10, color: plugin.color, background: `${plugin.color}15`, padding: '1px 6px', borderRadius: 3, marginLeft: 'auto' }}>{plugin.tag}</span>
      </div>
      <div style={{ fontSize: 12, color: 'var(--web-text-muted)', lineHeight: 1.5 }}>{plugin.desc}</div>
      <div style={{ marginTop: 10, display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--web-accent)' }}>
        Enable <ArrowRight size={12} />
      </div>
    </div>
  );
}
