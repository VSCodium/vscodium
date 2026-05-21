import React, { useState } from 'react';
import {
  Files, Search, GitBranch, Play, Puzzle, Users,
  MessageCircle, Settings, Bot, ChevronDown, ChevronRight,
  File, FileCode, Folder, FolderOpen, Send, X,
  CheckCircle, Circle, AlertTriangle, Eye, Shield, Globe, Network, Code,
  Terminal, List, Minus, Plus, GitPullRequest, Sparkles
} from 'lucide-react';

const API = process.env.REACT_APP_BACKEND_URL;

/* ========== MOCK CODE ========== */
const SESSION_TS = [
  { n: 1, t: "import { Request, Response, NextFunction } from 'express';", c: 'keyword' },
  { n: 2, t: "import { verify } from 'jsonwebtoken';", c: 'keyword' },
  { n: 3, t: "import { config } from '../config';", c: 'keyword' },
  { n: 4, t: "", c: '' },
  { n: 5, t: "interface Session {", c: 'keyword' },
  { n: 6, t: "  userId: string;", c: 'normal' },
  { n: 7, t: "  email: string;", c: 'normal' },
  { n: 8, t: "  role: 'admin' | 'user' | 'viewer';", c: 'normal' },
  { n: 9, t: "  expiresAt: number;", c: 'normal' },
  { n: 10, t: "}", c: 'keyword' },
  { n: 11, t: "", c: '' },
  { n: 12, t: "export function validateSession(", c: 'fn' },
  { n: 13, t: "  req: Request,", c: 'normal' },
  { n: 14, t: "  res: Response,", c: 'normal' },
  { n: 15, t: "  next: NextFunction", c: 'normal' },
  { n: 16, t: ") {", c: 'fn' },
  { n: 17, t: "  const token = req.headers.authorization?.split(' ')[1];", c: 'normal' },
  { n: 18, t: "", c: '' },
  { n: 19, t: "  if (!token) {", c: 'normal' },
  { n: 20, t: "    return res.status(401).json({ error: 'No token' });", c: 'normal' },
  { n: 21, t: "  }", c: 'normal' },
  { n: 22, t: "", c: '' },
  { n: 23, t: "  // TODO: Add token refresh logic", c: 'comment' },
  { n: 24, t: "  // TODO: Add session expiry check", c: 'comment' },
  { n: 25, t: "", c: '' },
  { n: 26, t: "  try {", c: 'normal' },
  { n: 27, t: "    const decoded = verify(token, config.jwtSecret);", c: 'normal' },
  { n: 28, t: "    req.session = decoded as Session;", c: 'normal' },
  { n: 29, t: "    next();", c: 'normal' },
  { n: 30, t: "  } catch (err) {", c: 'normal' },
  { n: 31, t: "    return res.status(401).json({ error: 'Invalid token' });", c: 'normal' },
  { n: 32, t: "  }", c: 'normal' },
  { n: 33, t: "}", c: 'fn' },
];

const PROPOSED_EDIT = {
  startLine: 22,
  endLine: 25,
  agentId: 'coder',
  label: 'Coder: Add session expiry validation',
  lines: [
    { t: "  // Session expiry validation (added by Coder agent)", c: 'comment' },
    { t: "  const now = Math.floor(Date.now() / 1000);", c: 'normal' },
    { t: "  if (decoded.exp && decoded.exp < now) {", c: 'normal' },
    { t: "    return res.status(401).json({ error: 'Token expired' });", c: 'normal' },
    { t: "  }", c: 'normal' },
  ],
};

const MOCK_CONVERSATION = [
  { role: 'user', text: 'Refactor the auth module and add session validation with expiry checks.' },
  { role: 'assistant', agent: 'Planner', text: "I'll create a 5-step plan for this refactor:\n\n1. Read existing auth files and session.ts\n2. Add session expiry validation to validateSession()\n3. Add token refresh endpoint\n4. Security audit of changes\n5. Write integration tests\n\nStep 1 is complete. Step 2 is in progress \u2014 Coder is proposing an inline edit at line 22." },
  { role: 'assistant', agent: 'Reviewer', text: "\u26a0\ufe0f Risk: The current session.ts has no rate limiting on token verification. Consider adding a rate limiter before production." },
];

const AGENTS_DATA = [
  { id: 'planner', name: 'Planner', icon: Network, status: 'done', color: '#58A6FF', action: 'Plan ready (5 steps)' },
  { id: 'coder', name: 'Coder', icon: Code, status: 'editing', color: '#3FB950', action: 'Editing session.ts:22' },
  { id: 'reviewer', name: 'Reviewer', icon: Eye, status: 'flagged', color: '#D29922', action: 'Flagged rate limiting' },
  { id: 'security', name: 'Security', icon: Shield, status: 'scanning', color: '#F85149', action: 'Scanning changes...' },
  { id: 'browser', name: 'Browser', icon: Globe, status: 'idle', color: '#8B949E', action: 'Idle' },
];

const STATUS_COLORS = { done: 'var(--ide-success)', editing: 'var(--ide-success)', flagged: 'var(--ide-warning)', scanning: 'var(--ide-warning)', idle: 'var(--ide-text-dim)' };

/* ========== IDE SURFACE ========== */
export default function IDESurface({ data }) {
  const [composerInput, setComposerInput] = useState('');
  const [sideView, setSideView] = useState('explorer');
  const [bottomTab, setBottomTab] = useState('activity');
  const [showProposal, setShowProposal] = useState(true);

  return (
    <div data-testid="ide-surface" style={{ display: 'flex', height: '100%', background: 'var(--ide-bg)', color: 'var(--ide-text)' }}>
      {/* Activity Bar */}
      <div data-testid="activity-bar" style={{ width: 48, background: 'var(--ide-actbar)', borderRight: '1px solid var(--ide-border)', display: 'flex', flexDirection: 'column', alignItems: 'center', pt: 2 }}>
        {[
          { id: 'explorer', icon: Files },
          { id: 'search', icon: Search },
          { id: 'scm', icon: GitBranch },
          { id: 'debug', icon: Play },
          { id: 'extensions', icon: Puzzle },
          { id: 'agents', icon: Users },
        ].map(({ id, icon: I }) => (
          <button key={id} data-testid={`actbar-${id}`} onClick={() => setSideView(id)} style={{
            width: 48, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: 'none', border: 'none', cursor: 'pointer',
            borderLeft: sideView === id ? '2px solid var(--ide-accent)' : '2px solid transparent',
            color: sideView === id ? 'var(--ide-text-bright)' : 'var(--ide-text-dim)',
            opacity: sideView === id ? 1 : 0.6,
          }}><I size={18} strokeWidth={1.5} /></button>
        ))}
        <div style={{ flex: 1 }} />
        <button data-testid="actbar-composer" style={{ width: 48, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--ide-accent)', opacity: 0.9 }}>
          <MessageCircle size={18} strokeWidth={1.5} />
        </button>
        <button style={{ width: 48, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--ide-text-dim)', opacity: 0.5, marginBottom: 4 }}>
          <Settings size={16} strokeWidth={1.5} />
        </button>
      </div>

      {/* Sidebar */}
      <div data-testid="sidebar" style={{ width: 220, background: 'var(--ide-surface)', borderRight: '1px solid var(--ide-border)', overflowY: 'auto', fontSize: 12 }}>
        {sideView === 'agents' ? <AgentsSidebar /> : <ExplorerSidebar />}
      </div>

      {/* Center: Editor + Bottom */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        {/* Tab Bar */}
        <div data-testid="tab-bar" style={{ height: 34, display: 'flex', background: 'var(--ide-titlebar)', borderBottom: '1px solid var(--ide-border)' }}>
          <Tab label="session.ts" active icon={FileCode} modified />
          <Tab label="auth-module.plan" icon={GitPullRequest} />
          <div style={{ flex: 1, borderBottom: '1px solid var(--ide-border)' }} />
        </div>

        {/* Code Editor */}
        <div data-testid="code-editor" style={{ flex: 1, overflow: 'auto', background: 'var(--ide-editor)', fontFamily: 'var(--font-mono)', fontSize: 12, lineHeight: '20px' }}>
          <div style={{ padding: '4px 0', minWidth: 600 }}>
            {SESSION_TS.map(line => {
              const inProposalZone = line.n >= PROPOSED_EDIT.startLine && line.n <= PROPOSED_EDIT.endLine;
              if (line.n === PROPOSED_EDIT.startLine && showProposal) {
                return (
                  <React.Fragment key={line.n}>
                    {/* Agent proposal banner */}
                    <div data-testid="agent-proposal" style={{
                      display: 'flex', alignItems: 'center', gap: 6,
                      padding: '4px 16px 4px 64px',
                      background: 'var(--ide-accent-dim)',
                      borderLeft: '2px solid var(--ide-accent)',
                      fontSize: 11, color: 'var(--ide-accent)',
                    }}>
                      <Sparkles size={12} />
                      <span style={{ fontWeight: 500 }}>{PROPOSED_EDIT.label}</span>
                      <div style={{ flex: 1 }} />
                      <button data-testid="accept-edit" style={editBtn('var(--ide-success)')}>Accept</button>
                      <button data-testid="reject-edit" style={editBtn('var(--ide-error)')}>Reject</button>
                      <button style={editBtn('var(--ide-text-dim)')} onClick={() => setShowProposal(false)}>Dismiss</button>
                    </div>
                    {/* Proposed new lines */}
                    {PROPOSED_EDIT.lines.map((pl, pi) => (
                      <div key={`p${pi}`} style={{ display: 'flex', background: 'var(--ide-add-bg)' }}>
                        <span style={lnStyle}>+</span>
                        <span style={{ color: 'var(--ide-add)', paddingLeft: 16 }}>{pl.t}</span>
                      </div>
                    ))}
                    {/* Original line (marked for removal) */}
                    <div style={{ display: 'flex', background: 'var(--ide-del-bg)', opacity: 0.6 }}>
                      <span style={lnStyle}>{line.n}</span>
                      <span style={{ color: 'var(--ide-del)', paddingLeft: 16, textDecoration: 'line-through' }}>{line.t}</span>
                    </div>
                  </React.Fragment>
                );
              }
              if (inProposalZone && showProposal) {
                return (
                  <div key={line.n} style={{ display: 'flex', background: 'var(--ide-del-bg)', opacity: 0.6 }}>
                    <span style={lnStyle}>{line.n}</span>
                    <span style={{ color: 'var(--ide-del)', paddingLeft: 16, textDecoration: 'line-through' }}>{line.t}</span>
                  </div>
                );
              }
              return <CodeLine key={line.n} line={line} />;
            })}
          </div>
        </div>

        {/* Bottom Panel */}
        <div data-testid="bottom-panel" style={{ height: 180, borderTop: '1px solid var(--ide-border)', background: 'var(--ide-surface)', display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex', height: 30, borderBottom: '1px solid var(--ide-border)', alignItems: 'center', paddingLeft: 8 }}>
            {['activity', 'terminal', 'problems'].map(t => (
              <button key={t} data-testid={`bottom-${t}`} onClick={() => setBottomTab(t)} style={{
                padding: '0 10px', height: '100%', background: 'none', border: 'none',
                borderBottom: bottomTab === t ? '1px solid var(--ide-accent)' : '1px solid transparent',
                color: bottomTab === t ? 'var(--ide-text-bright)' : 'var(--ide-text-dim)',
                fontSize: 11, cursor: 'pointer', textTransform: 'uppercase', letterSpacing: '0.03em',
                display: 'flex', alignItems: 'center', gap: 4,
              }}>
                {t === 'activity' && <List size={11} />}
                {t === 'terminal' && <Terminal size={11} />}
                {t === 'problems' && <AlertTriangle size={11} />}
                {t} {t === 'activity' && <span style={{ fontSize: 9, color: 'var(--ide-text-dim)' }}>{data.activity?.length}</span>}
              </button>
            ))}
          </div>
          <div style={{ flex: 1, overflowY: 'auto', fontFamily: 'var(--font-mono)', fontSize: 11 }}>
            {bottomTab === 'activity' && data.activity?.map(e => (
              <div key={e.id} style={{ display: 'flex', gap: 8, padding: '1px 12px', lineHeight: '18px' }}>
                <span style={{ color: 'var(--ide-text-dim)', minWidth: 76 }}>{e.timestamp.slice(11, 23)}</span>
                <span style={{ color: e.actor === 'coder' ? 'var(--ide-success)' : e.actor === 'planner' ? 'var(--ide-accent)' : e.actor === 'reviewer' ? 'var(--ide-warning)' : e.actor === 'security' ? 'var(--ide-error)' : 'var(--ide-text-dim)', minWidth: 70 }}>[{e.actor}]</span>
                <span style={{ color: 'var(--ide-accent)', opacity: 0.5, minWidth: 64 }}>{e.category}</span>
                <span style={{ color: e.severity === 'warning' ? 'var(--ide-warning)' : 'var(--ide-text)' }}>{e.message}</span>
              </div>
            ))}
            {bottomTab === 'terminal' && <div style={{ padding: 12, color: 'var(--ide-text-dim)' }}><span style={{ color: 'var(--ide-success)' }}>cursor-ing</span>:<span style={{ color: 'var(--ide-accent)' }}>~/project</span>$ <span style={{ borderLeft: '1px solid var(--ide-accent)', animation: 'blink 1s step-end infinite' }}>&nbsp;</span><style>{`@keyframes blink{50%{opacity:0}}`}</style></div>}
            {bottomTab === 'problems' && <div style={{ padding: 12, color: 'var(--ide-warning)', display: 'flex', alignItems: 'center', gap: 6 }}><AlertTriangle size={12} /> 1 warning: No rate limiting on token verification (Reviewer)</div>}
          </div>
        </div>

        {/* Status Bar */}
        <div data-testid="status-bar" style={{
          height: 22, background: 'var(--ide-statusbar)', display: 'flex', alignItems: 'center',
          padding: '0 10px', fontSize: 11, color: '#fff', gap: 4, fontFamily: 'var(--font-ui)',
        }}>
          <SI><GitBranch size={11} /> main</SI>
          <SI>3 agents active</SI>
          <div style={{ flex: 1 }} />
          <SI>cursor-ing-mock-v1</SI>
          <SI><Shield size={11} /> No Telemetry</SI>
          <SI>Cursor ING v0.1.0</SI>
        </div>
      </div>

      {/* Composer Panel */}
      <div data-testid="composer-panel" style={{
        width: 340, background: 'var(--ide-surface)', borderLeft: '1px solid var(--ide-border)',
        display: 'flex', flexDirection: 'column',
      }}>
        <div style={{ padding: '10px 14px', borderBottom: '1px solid var(--ide-border)', display: 'flex', alignItems: 'center', gap: 6 }}>
          <Bot size={14} color="var(--ide-accent)" />
          <span style={{ fontWeight: 600, fontSize: 12, color: 'var(--ide-text-bright)' }}>Cursor ING</span>
          <span style={{ fontSize: 10, color: 'var(--ide-text-dim)', fontFamily: 'var(--font-mono)' }}>mock-v1</span>
        </div>

        <div data-testid="composer-messages" style={{ flex: 1, overflowY: 'auto', padding: '6px 0' }}>
          {MOCK_CONVERSATION.map((m, i) => (
            <div key={i} data-testid={`conv-${i}`} style={{ padding: '8px 14px', borderBottom: '1px solid var(--ide-border)' }}>
              <div style={{ fontSize: 10, color: 'var(--ide-text-dim)', marginBottom: 4, fontFamily: 'var(--font-mono)', display: 'flex', gap: 6, alignItems: 'center' }}>
                <span style={{ color: m.role === 'user' ? 'var(--ide-text-muted)' : 'var(--ide-accent)' }}>
                  {m.role === 'user' ? 'you' : m.agent?.toLowerCase()}
                </span>
                {m.agent && <span style={{ fontSize: 9, padding: '0 4px', border: '1px solid var(--ide-border)', borderRadius: 2, color: 'var(--ide-text-dim)' }}>{m.agent}</span>}
              </div>
              <div style={{
                fontSize: 12, lineHeight: 1.6, whiteSpace: 'pre-wrap', wordBreak: 'break-word',
                color: m.role === 'user' ? 'var(--ide-text)' : 'var(--ide-text-bright)',
                fontFamily: m.role === 'user' ? 'var(--font-ui)' : 'var(--font-mono)',
              }}>{m.text}</div>
              {m.agent === 'Planner' && (
                <div style={{ marginTop: 8, display: 'flex', gap: 6 }}>
                  <button data-testid="approve-plan-btn" style={{ padding: '4px 12px', fontSize: 11, fontFamily: 'var(--font-mono)', color: 'var(--ide-success)', background: 'rgba(63,185,80,0.1)', border: '1px solid var(--ide-success)', cursor: 'pointer' }}>Approve Plan</button>
                  <button style={{ padding: '4px 12px', fontSize: 11, fontFamily: 'var(--font-mono)', color: 'var(--ide-error)', background: 'transparent', border: '1px solid var(--ide-border)', cursor: 'pointer' }}>Reject</button>
                </div>
              )}
            </div>
          ))}
        </div>

        <div style={{ padding: 10, borderTop: '1px solid var(--ide-border)', display: 'flex', gap: 6 }}>
          <input data-testid="composer-input" value={composerInput} onChange={e => setComposerInput(e.target.value)}
            placeholder="Ask Cursor ING..." style={{
              flex: 1, padding: '7px 10px', background: 'var(--ide-input)', border: '1px solid var(--ide-border)',
              color: 'var(--ide-text)', fontFamily: 'var(--font-mono)', fontSize: 12, outline: 'none', borderRadius: 3,
            }}
            onFocus={e => e.currentTarget.style.borderColor = 'var(--ide-accent)'}
            onBlur={e => e.currentTarget.style.borderColor = 'var(--ide-border)'}
          />
          <button data-testid="composer-send" style={{
            padding: '7px 10px', background: 'var(--ide-accent)', color: '#fff', border: 'none',
            cursor: 'pointer', display: 'flex', alignItems: 'center', borderRadius: 3,
          }}><Send size={14} /></button>
        </div>
      </div>
    </div>
  );
}

/* Compact sidebar components */
function ExplorerSidebar() {
  const [open, setOpen] = useState({ src: true, auth: true, agents: false });
  return (
    <div data-testid="explorer-sidebar">
      <div style={{ padding: '8px 12px', fontSize: 11, fontWeight: 600, color: 'var(--ide-text-muted)', letterSpacing: '0.04em' }}>EXPLORER</div>
      <TreeItem icon={FolderOpen} label="cursor-ing-project" bold onClick={() => {}} />
      <TreeItem icon={open.src ? FolderOpen : Folder} label="src" depth={1} onClick={() => setOpen(p => ({...p, src: !p.src}))} expandable expanded={open.src} />
      {open.src && <>
        <TreeItem icon={open.auth ? FolderOpen : Folder} label="auth" depth={2} onClick={() => setOpen(p => ({...p, auth: !p.auth}))} expandable expanded={open.auth} />
        {open.auth && <>
          <TreeItem icon={FileCode} label="session.ts" depth={3} active badge="M" />
          <TreeItem icon={FileCode} label="jwt.ts" depth={3} />
          <TreeItem icon={FileCode} label="middleware.ts" depth={3} />
        </>}
        <TreeItem icon={Folder} label="routes" depth={2} />
        <TreeItem icon={Folder} label="models" depth={2} />
        <TreeItem icon={FileCode} label="app.ts" depth={2} />
      </>}
      <TreeItem icon={open.agents ? FolderOpen : Folder} label=".agents" depth={1} onClick={() => setOpen(p => ({...p, agents: !p.agents}))} expandable expanded={open.agents} />
      {open.agents && <>
        <TreeItem icon={File} label="registry.json" depth={2} />
        <TreeItem icon={Folder} label="skills" depth={2} />
        <TreeItem icon={Folder} label="brain" depth={2} />
      </>}
      <TreeItem icon={Folder} label=".cursor-ing" depth={1} />
      <TreeItem icon={File} label="AGENTS.md" depth={1} />
      <TreeItem icon={File} label="package.json" depth={1} />
    </div>
  );
}

function AgentsSidebar() {
  return (
    <div data-testid="agents-sidebar">
      <div style={{ padding: '8px 12px', fontSize: 11, fontWeight: 600, color: 'var(--ide-text-muted)', letterSpacing: '0.04em' }}>CURSOR ING AGENTS</div>
      {AGENTS_DATA.map(a => (
        <div key={a.id} data-testid={`agent-${a.id}`} style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '4px 12px', fontSize: 12, cursor: 'default' }}
          onMouseEnter={e => e.currentTarget.style.background = 'var(--ide-accent-dim)'}
          onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
        >
          <a.icon size={13} color={a.color} strokeWidth={1.8} />
          <span style={{ flex: 1, color: 'var(--ide-text)' }}>{a.name}</span>
          <span style={{ width: 6, height: 6, borderRadius: '50%', background: STATUS_COLORS[a.status] }} />
          <span style={{ fontSize: 10, color: 'var(--ide-text-muted)', maxWidth: 80, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{a.action}</span>
        </div>
      ))}
      <div style={{ margin: '8px 12px', padding: '6px 8px', background: 'var(--ide-accent-dim)', borderRadius: 3, fontSize: 11, color: 'var(--ide-accent)', border: '1px solid var(--ide-border)' }}>
        <div style={{ fontWeight: 600, marginBottom: 2 }}>Current Task</div>
        <div style={{ color: 'var(--ide-text-muted)' }}>Refactor auth module + session validation</div>
        <div style={{ color: 'var(--ide-text-dim)', fontSize: 10, marginTop: 2 }}>Step 2/5 in progress</div>
      </div>
    </div>
  );
}

/* Helpers */
function TreeItem({ icon: I, label, depth = 0, bold, active, badge, onClick, expandable, expanded }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 5,
      padding: `2px 8px 2px ${8 + depth * 14}px`,
      fontSize: 12, cursor: onClick ? 'pointer' : 'default',
      fontWeight: bold ? 600 : 400,
      color: active ? 'var(--ide-text-bright)' : 'var(--ide-text)',
      background: active ? 'var(--ide-accent-dim)' : 'transparent',
    }}
    onMouseEnter={e => { if (!active) e.currentTarget.style.background = 'rgba(255,255,255,0.03)'; }}
    onMouseLeave={e => { if (!active) e.currentTarget.style.background = active ? 'var(--ide-accent-dim)' : 'transparent'; }}
    >
      {expandable && (expanded ? <ChevronDown size={10} color="var(--ide-text-dim)" /> : <ChevronRight size={10} color="var(--ide-text-dim)" />)}
      <I size={13} color={active ? 'var(--ide-accent)' : 'var(--ide-text-muted)'} strokeWidth={1.5} />
      <span style={{ flex: 1 }}>{label}</span>
      {badge && <span style={{ fontSize: 9, color: 'var(--ide-warning)', fontWeight: 600 }}>{badge}</span>}
    </div>
  );
}

function CodeLine({ line }) {
  const colors = { keyword: '#FF7B72', fn: '#D2A8FF', comment: '#8B949E', normal: '#C9D1D9' };
  return (
    <div style={{ display: 'flex' }}>
      <span style={lnStyle}>{line.n}</span>
      <span style={{ color: colors[line.c] || 'var(--ide-text)', paddingLeft: 16, whiteSpace: 'pre' }}>{line.t}</span>
    </div>
  );
}

function Tab({ label, active, icon: I, modified }) {
  return (
    <div data-testid={`tab-${label}`} style={{
      display: 'flex', alignItems: 'center', gap: 6, padding: '0 12px', fontSize: 12,
      background: active ? 'var(--ide-tab-active)' : 'var(--ide-tab-inactive)',
      color: active ? 'var(--ide-text-bright)' : 'var(--ide-text-muted)',
      borderRight: '1px solid var(--ide-border)',
      borderBottom: active ? 'none' : '1px solid var(--ide-border)',
      cursor: 'pointer',
    }}>
      <I size={13} strokeWidth={1.5} />
      <span>{label}</span>
      {modified && <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--ide-accent)' }} />}
      <X size={12} color="var(--ide-text-dim)" style={{ marginLeft: 4 }} />
    </div>
  );
}

function SI({ children }) {
  return <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '0 6px' }}>{children}</div>;
}

const lnStyle = { color: 'var(--ide-line)', width: 48, textAlign: 'right', paddingRight: 12, userSelect: 'none', flexShrink: 0 };
const editBtn = (c) => ({ padding: '2px 8px', fontSize: 10, fontFamily: 'var(--font-mono)', color: c, background: 'transparent', border: `1px solid ${c}`, cursor: 'pointer', borderRadius: 2 });
