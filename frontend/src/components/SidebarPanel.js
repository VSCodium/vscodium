import React, { useState } from 'react';
import {
  ChevronDown, ChevronRight, File, FileText, FileCode,
  Folder, FolderOpen, Network, Code, Eye,
  Shield, Globe, CheckCircle, Circle, Play, AlertTriangle
} from 'lucide-react';

const ICON_MAP = {
  planner: Network,
  coder: Code,
  reviewer: Eye,
  security: Shield,
  browser: Globe,
};

const STATUS_DOT = {
  idle: 'var(--text-dimmed)',
  coding: 'var(--success)',
  reviewing: 'var(--warning)',
  clear: 'var(--success)',
  scanning: 'var(--warning)',
  alert: 'var(--error)',
};

function SidebarPanel({ view, agents, plan, onOpenTab }) {
  if (view === 'agents') return <AgentsView agents={agents} />;
  if (view === 'explorer') return <ExplorerView plan={plan} onOpenTab={onOpenTab} />;
  return <PlaceholderView title={view} />;
}

function AgentsView({ agents }) {
  const [expanded, setExpanded] = useState(true);
  return (
    <div data-testid="sidebar-agents" style={sidebarStyle}>
      <SidebarHeader title="CURSOR ING AGENTS" />
      <TreeNode label="AGENT TEAM" expanded={expanded} onToggle={() => setExpanded(e => !e)} count={agents.length} depth={0} />
      {expanded && agents.map(a => {
        const AgentIcon = ICON_MAP[a.role] || Code;
        const dotColor = STATUS_DOT[a.status] || 'var(--text-dimmed)';
        return (
          <div key={a.id} data-testid={`agent-${a.id}`} style={{
            display: 'flex', alignItems: 'center', gap: 6,
            padding: '3px 8px 3px 28px', cursor: 'default', fontSize: 12,
            color: 'var(--text-primary)',
          }}
          onMouseEnter={e => e.currentTarget.style.background = 'var(--accent-dim)'}
          onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
          >
            <AgentIcon size={13} color={a.color} strokeWidth={1.8} />
            <span style={{ flex: 1 }}>{a.name}</span>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: dotColor, flexShrink: 0 }} />
            <span style={{ fontSize: 10, color: 'var(--text-muted)', maxWidth: 72, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {a.status}
            </span>
          </div>
        );
      })}
      <div style={{ padding: '12px', fontSize: 10, color: 'var(--text-dimmed)', lineHeight: 1.5, marginTop: 8, borderTop: '1px solid var(--border)' }}>
        Read-only by default. Writes require approval.
      </div>
    </div>
  );
}

function ExplorerView({ plan, onOpenTab }) {
  const [projOpen, setProjOpen] = useState(true);
  const [agentsOpen, setAgentsOpen] = useState(false);
  const [plansOpen, setPlansOpen] = useState(true);
  const [extOpen, setExtOpen] = useState(false);

  return (
    <div data-testid="sidebar-explorer" style={sidebarStyle}>
      <SidebarHeader title="EXPLORER" />
      <TreeNode label="CURSOR-ING" expanded={projOpen} onToggle={() => setProjOpen(p => !p)} depth={0} />
      {projOpen && (
        <>
          <FileItem icon={FileCode} label="AGENTS.md" depth={1} onClick={() => onOpenTab('welcome', 'Welcome', 'welcome')} />
          <FileItem icon={FileCode} label="CURSOR-ING.md" depth={1} onClick={() => onOpenTab('welcome', 'Welcome', 'welcome')} />

          <TreeNode label=".agents" expanded={agentsOpen} onToggle={() => setAgentsOpen(p => !p)} depth={1} />
          {agentsOpen && (
            <>
              <FileItem icon={File} label="registry.json" depth={2} />
              <FileItem icon={File} label="validate.sh" depth={2} />
              <SubFolder label="model-adapters" depth={2} items={['claude.md','codex.md','kimi.md','qwen-code.md','gemini-code.md']} />
              <SubFolder label="skills" depth={2} items={['code-review.md','plan-and-execute.md','diff-apply.md']} />
              <SubFolder label="agents" depth={2} items={['planner.md','coder.md','reviewer.md','security.md','browser.md']} />
              <SubFolder label="brain" depth={2} items={['memory.md','glossary.md','assumptions.md']} />
            </>
          )}

          <TreeNode label=".cursor-ing" expanded={plansOpen} onToggle={() => setPlansOpen(p => !p)} depth={1} />
          {plansOpen && (
            <>
              <FileItem icon={File} label="README.md" depth={2} />
              <TreeNode label="plans" expanded={true} onToggle={() => {}} depth={2} />
              {plan && (
                <FileItem
                  icon={FileText} label="auth-module.plan.json" depth={3} active
                  onClick={() => onOpenTab('plan', 'auth-module.plan', 'plan')}
                />
              )}
              <FileItem
                icon={FileCode} label="processor.diff" depth={2}
                onClick={() => onOpenTab('diff', 'processor.diff', 'diff')}
              />
            </>
          )}

          <TreeNode label="extensions/cursor-ing-ai" expanded={extOpen} onToggle={() => setExtOpen(p => !p)} depth={1} />
          {extOpen && (
            <>
              <FileItem icon={FileCode} label="extension.ts" depth={2} />
              <FileItem icon={FileCode} label="mock-provider.ts" depth={2} />
              <FileItem icon={FileCode} label="roster.ts" depth={2} />
              <FileItem icon={FileCode} label="plan-viewer.ts" depth={2} />
              <FileItem icon={FileCode} label="diff-preview.ts" depth={2} />
              <FileItem icon={FileCode} label="composer-panel.ts" depth={2} />
            </>
          )}
        </>
      )}
    </div>
  );
}

function PlaceholderView({ title }) {
  return (
    <div data-testid={`sidebar-${title}`} style={sidebarStyle}>
      <SidebarHeader title={title.toUpperCase()} />
      <div style={{ padding: '16px 12px', fontSize: 11, color: 'var(--text-dimmed)' }}>
        {title === 'search' && 'Search across workspace files.'}
        {title === 'scm' && 'No source control providers registered.'}
        {title === 'debug' && 'Run and debug configurations.'}
        {title === 'extensions' && 'Cursor ING extensions installed.'}
      </div>
    </div>
  );
}

function SidebarHeader({ title }) {
  return (
    <div style={{
      padding: '8px 12px', fontSize: 11, fontWeight: 600,
      letterSpacing: '0.05em', color: 'var(--text-muted)',
      textTransform: 'uppercase', userSelect: 'none',
    }}>{title}</div>
  );
}

function TreeNode({ label, expanded, onToggle, depth = 0, count }) {
  return (
    <div
      onClick={onToggle}
      style={{
        display: 'flex', alignItems: 'center', gap: 4,
        padding: `2px 8px 2px ${8 + depth * 12}px`,
        fontSize: 11, fontWeight: 600, color: 'var(--text-primary)',
        cursor: 'pointer', userSelect: 'none', letterSpacing: '0.02em',
      }}
      onMouseEnter={e => e.currentTarget.style.background = 'var(--accent-dim)'}
      onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
    >
      {expanded ? <ChevronDown size={12} color="var(--text-muted)" /> : <ChevronRight size={12} color="var(--text-muted)" />}
      {expanded ? <FolderOpen size={14} color="var(--warning)" strokeWidth={1.5} /> : <Folder size={14} color="var(--warning)" strokeWidth={1.5} />}
      <span style={{ flex: 1, textTransform: 'none' }}>{label}</span>
      {count != null && <span style={{ fontSize: 10, color: 'var(--text-dimmed)', fontWeight: 400 }}>{count}</span>}
    </div>
  );
}

function FileItem({ icon: Icon, label, depth = 0, active, onClick }) {
  return (
    <div
      data-testid={`file-${label}`}
      onClick={onClick}
      style={{
        display: 'flex', alignItems: 'center', gap: 6,
        padding: `2px 8px 2px ${16 + depth * 12}px`,
        fontSize: 12, cursor: onClick ? 'pointer' : 'default',
        color: active ? 'var(--text-bright)' : 'var(--text-primary)',
        background: active ? 'var(--accent-dim)' : 'transparent',
      }}
      onMouseEnter={e => { if (!active) e.currentTarget.style.background = 'rgba(255,255,255,0.03)'; }}
      onMouseLeave={e => { if (!active) e.currentTarget.style.background = active ? 'var(--accent-dim)' : 'transparent'; }}
    >
      <Icon size={13} color={active ? 'var(--accent)' : 'var(--text-muted)'} strokeWidth={1.5} />
      <span>{label}</span>
    </div>
  );
}

function SubFolder({ label, depth, items }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <div
        onClick={() => setOpen(o => !o)}
        style={{
          display: 'flex', alignItems: 'center', gap: 4,
          padding: `2px 8px 2px ${16 + depth * 12}px`,
          fontSize: 12, cursor: 'pointer', color: 'var(--text-primary)',
        }}
        onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.03)'}
        onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
      >
        {open ? <ChevronDown size={10} /> : <ChevronRight size={10} />}
        {open ? <FolderOpen size={13} color="var(--warning)" strokeWidth={1.5} /> : <Folder size={13} color="var(--warning)" strokeWidth={1.5} />}
        <span>{label}</span>
        <span style={{ fontSize: 10, color: 'var(--text-dimmed)', marginLeft: 'auto' }}>{items.length}</span>
      </div>
      {open && items.map(f => <FileItem key={f} icon={File} label={f} depth={depth + 1} />)}
    </>
  );
}

const sidebarStyle = {
  width: 240, minWidth: 240,
  background: 'var(--bg-surface)',
  borderRight: '1px solid var(--border)',
  overflowY: 'auto', overflowX: 'hidden',
};

export default SidebarPanel;
