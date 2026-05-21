import React, { useState } from 'react';
import { X, Send, Bot } from 'lucide-react';

const API = process.env.REACT_APP_BACKEND_URL;

function ComposerPanel({ onClose }) {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const send = async () => {
    if (!input.trim() || loading) return;
    const text = input.trim();
    setMessages(p => [...p, { role: 'user', content: text, ts: new Date().toISOString() }]);
    setInput('');
    setLoading(true);
    try {
      const res = await fetch(`${API}/api/composer/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: text }),
      });
      const data = await res.json();
      setMessages(p => [...p, { role: 'assistant', content: data.response, ts: data.timestamp, model: data.model }]);
    } catch {
      setMessages(p => [...p, { role: 'assistant', content: 'Error: provider unreachable.', ts: new Date().toISOString() }]);
    }
    setLoading(false);
  };

  return (
    <div data-testid="composer-panel" style={{
      width: 360, minWidth: 320,
      background: 'var(--bg-surface)',
      borderLeft: '1px solid var(--border)',
      display: 'flex', flexDirection: 'column',
    }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 6,
        padding: '8px 12px', borderBottom: '1px solid var(--border)',
        fontSize: 11, fontWeight: 600, color: 'var(--text-muted)',
        letterSpacing: '0.04em', textTransform: 'uppercase',
      }}>
        <Bot size={14} color="var(--accent)" />
        <span>Cursor ING</span>
        <span style={{ fontSize: 9, color: 'var(--text-dimmed)', fontWeight: 400, textTransform: 'none', letterSpacing: 0 }}>mock-v1</span>
        <div style={{ flex: 1 }} />
        <button data-testid="composer-close-btn" onClick={onClose} style={{ background: 'none', border: 'none', color: 'var(--text-dimmed)', cursor: 'pointer', padding: 2 }}>
          <X size={14} />
        </button>
      </div>

      <div data-testid="composer-messages" style={{ flex: 1, overflowY: 'auto', padding: '8px 0' }}>
        {messages.length === 0 && (
          <div style={{ padding: '32px 16px', textAlign: 'center' }}>
            <Bot size={28} color="var(--border-strong)" strokeWidth={1} style={{ marginBottom: 8 }} />
            <div style={{ fontSize: 12, color: 'var(--text-dimmed)', lineHeight: 1.6 }}>
              Ask Cursor ING anything.<br />
              <span style={{ fontSize: 11 }}>Try: "plan authentication" or "review code"</span>
            </div>
          </div>
        )}
        {messages.map((m, i) => (
          <div key={i} data-testid={`msg-${i}`} style={{ padding: '6px 12px', borderBottom: '1px solid var(--border)' }}>
            <div style={{
              fontSize: 10, color: 'var(--text-dimmed)', marginBottom: 3,
              fontFamily: 'var(--font-mono)', display: 'flex', gap: 6,
            }}>
              <span style={{ color: m.role === 'user' ? 'var(--text-muted)' : 'var(--accent)' }}>
                {m.role === 'user' ? 'you' : 'cursor-ing'}
              </span>
              {m.model && <span>[{m.model}]</span>}
            </div>
            <div style={{
              fontSize: 12, lineHeight: 1.5, whiteSpace: 'pre-wrap', wordBreak: 'break-word',
              color: m.role === 'user' ? 'var(--text-primary)' : 'var(--accent)',
              fontFamily: m.role === 'assistant' ? 'var(--font-mono)' : 'var(--font-ui)',
            }}>{m.content}</div>
          </div>
        ))}
        {loading && <div style={{ padding: '8px 12px', fontSize: 11, color: 'var(--accent)', fontFamily: 'var(--font-mono)' }}>thinking...</div>}
      </div>

      <div style={{ padding: 8, borderTop: '1px solid var(--border)', display: 'flex', gap: 6 }}>
        <input
          data-testid="composer-input"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && send()}
          placeholder="Ask Cursor ING..."
          style={{
            flex: 1, padding: '6px 10px',
            background: 'var(--bg-input)', border: '1px solid var(--border)',
            color: 'var(--text-primary)', fontFamily: 'var(--font-mono)',
            fontSize: 12, outline: 'none', borderRadius: 0,
          }}
          onFocus={e => e.currentTarget.style.borderColor = 'var(--accent)'}
          onBlur={e => e.currentTarget.style.borderColor = 'var(--border)'}
        />
        <button
          data-testid="composer-send-btn"
          onClick={send}
          disabled={loading || !input.trim()}
          style={{
            padding: '6px 10px',
            background: !input.trim() ? 'transparent' : 'var(--accent)',
            color: !input.trim() ? 'var(--text-dimmed)' : '#fff',
            border: `1px solid ${!input.trim() ? 'var(--border)' : 'var(--accent)'}`,
            cursor: loading ? 'wait' : 'pointer', display: 'flex', alignItems: 'center',
          }}
        >
          <Send size={14} />
        </button>
      </div>
    </div>
  );
}

export default ComposerPanel;
