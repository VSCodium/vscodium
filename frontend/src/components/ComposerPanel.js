import React, { useState } from 'react';

const API = process.env.REACT_APP_BACKEND_URL;

function ComposerPanel() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const sendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMsg = { role: 'user', content: input.trim(), timestamp: new Date().toISOString() };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setLoading(true);

    try {
      const res = await fetch(`${API}/api/composer/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: userMsg.content }),
      });
      const data = await res.json();
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: data.response,
        timestamp: data.timestamp,
        model: data.model,
        provider: data.provider,
      }]);
    } catch (err) {
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: 'Error: Could not reach mock provider.',
        timestamp: new Date().toISOString(),
      }]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div data-testid="composer-panel" style={{ display: 'flex', flexDirection: 'column', height: 'calc(100vh - 48px)' }}>
      <div style={{ marginBottom: '12px' }}>
        <h1 className="panel-title">Composer</h1>
        <p className="panel-subtitle">AI chat interface. Using mock provider (no API key required).</p>
      </div>

      <div style={{
        padding: '8px 12px',
        background: 'var(--bg-surface)',
        border: '1px solid var(--border-subtle)',
        marginBottom: '12px',
        display: 'flex',
        gap: '16px',
        fontFamily: 'var(--font-code)',
        fontSize: '11px',
        color: 'var(--text-muted)',
      }}>
        <span>Provider: <span style={{ color: 'var(--accent)' }}>Mock (Local)</span></span>
        <span>Model: <span style={{ color: 'var(--text-primary)' }}>cursor-ing-mock-v1</span></span>
        <span>Status: <span style={{ color: 'var(--success)' }}>Active</span></span>
      </div>

      <div style={{
        flex: 1,
        border: '1px solid var(--border-subtle)',
        overflow: 'auto',
        padding: '12px',
      }}>
        {messages.length === 0 && (
          <div style={{ color: 'var(--border-strong)', fontStyle: 'italic', fontSize: '13px' }}>
            Type a message to start. Try: "Create a plan for authentication" or "Review this code"
          </div>
        )}
        {messages.map((msg, idx) => (
          <div key={idx} data-testid={`composer-msg-${idx}`} style={{ marginBottom: '16px' }}>
            <div style={{
              fontFamily: 'var(--font-heading)',
              fontSize: '10px',
              color: 'var(--text-muted)',
              textTransform: 'uppercase',
              letterSpacing: '0.15em',
              marginBottom: '4px',
            }}>
              {msg.role === 'user' ? 'YOU' : 'CURSOR ING'}
              {msg.timestamp && ` \u2014 ${msg.timestamp.slice(11, 19)}`}
              {msg.model && ` [${msg.model}]`}
            </div>
            <div style={{
              color: msg.role === 'user' ? 'var(--text-primary)' : 'var(--accent)',
              fontSize: '13px',
              lineHeight: '1.6',
              whiteSpace: 'pre-wrap',
              fontFamily: msg.role === 'assistant' ? 'var(--font-code)' : 'var(--font-body)',
            }}>
              {msg.content}
            </div>
          </div>
        ))}
        {loading && (
          <div style={{ color: 'var(--accent)', fontFamily: 'var(--font-code)', fontSize: '12px', opacity: 0.7 }}>
            Processing...
          </div>
        )}
      </div>

      <div style={{
        display: 'flex',
        gap: '8px',
        marginTop: '8px',
      }}>
        <input
          data-testid="composer-input"
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && sendMessage()}
          placeholder="Ask Cursor ING..."
          style={{
            flex: 1,
            padding: '10px 12px',
            background: 'var(--bg-surface)',
            border: '1px solid var(--border-subtle)',
            color: 'var(--text-primary)',
            fontFamily: 'var(--font-code)',
            fontSize: '13px',
            outline: 'none',
            borderRadius: '0',
          }}
          onFocus={e => e.currentTarget.style.borderColor = 'var(--accent)'}
          onBlur={e => e.currentTarget.style.borderColor = 'var(--border-subtle)'}
        />
        <button
          data-testid="composer-send-btn"
          onClick={sendMessage}
          disabled={loading || !input.trim()}
          style={{
            padding: '10px 20px',
            background: 'var(--accent)',
            color: '#fff',
            border: 'none',
            fontFamily: 'var(--font-heading)',
            fontSize: '12px',
            fontWeight: 600,
            letterSpacing: '0.1em',
            cursor: loading ? 'not-allowed' : 'pointer',
            opacity: loading || !input.trim() ? 0.5 : 1,
          }}
        >
          SEND
        </button>
      </div>
    </div>
  );
}

export default ComposerPanel;
