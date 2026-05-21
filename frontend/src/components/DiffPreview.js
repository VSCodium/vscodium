import React from 'react';

function DiffPreview({ diffs }) {
  const diff = diffs[0];
  if (!diff) return <div data-testid="diff-preview-empty" style={{ color: 'var(--text-muted)' }}>No diffs pending.</div>;

  return (
    <div data-testid="diff-preview-panel">
      <h1 className="panel-title">{diff.title}</h1>
      <p className="panel-subtitle">{diff.description}</p>

      <div style={{ display: 'flex', gap: '12px', marginBottom: '16px', flexWrap: 'wrap' }}>
        <Badge label={`STATUS: ${diff.status.toUpperCase()}`} color={diff.status === 'pending' ? 'var(--warning)' : 'var(--success)'} />
        <Badge label={`AGENT: ${diff.agentId}`} color="var(--text-muted)" />
        <Badge label={diff.timestamp.slice(0, 16)} color="var(--text-muted)" />
      </div>

      <div style={{ display: 'flex', gap: '8px', marginBottom: '16px' }}>
        <button data-testid="diff-approve-btn" disabled style={{
          padding: '8px 20px',
          fontFamily: 'var(--font-heading)',
          fontSize: '12px',
          fontWeight: 600,
          letterSpacing: '0.1em',
          background: 'rgba(16,185,129,0.1)',
          color: 'var(--success)',
          border: '1px solid var(--success)',
          cursor: 'not-allowed',
          opacity: 0.7,
        }}>
          APPROVE
        </button>
        <button data-testid="diff-reject-btn" disabled style={{
          padding: '8px 20px',
          fontFamily: 'var(--font-heading)',
          fontSize: '12px',
          fontWeight: 600,
          letterSpacing: '0.1em',
          background: 'rgba(239,68,68,0.1)',
          color: 'var(--error)',
          border: '1px solid var(--error)',
          cursor: 'not-allowed',
          opacity: 0.7,
        }}>
          REJECT
        </button>
      </div>

      {diff.hunks.map((hunk, idx) => (
        <div key={idx} data-testid={`diff-hunk-${idx}`} style={{ marginBottom: '16px' }}>
          <div style={{
            padding: '8px 12px',
            background: 'var(--bg-surface)',
            border: '1px solid var(--border-subtle)',
            fontFamily: 'var(--font-code)',
            fontSize: '12px',
            color: 'var(--accent)',
          }}>
            {hunk.filePath} <span style={{ color: 'var(--text-muted)' }}>(lines {hunk.startLine}-{hunk.endLine})</span>
          </div>

          <div style={{ border: '1px solid var(--border-subtle)', borderTop: 'none' }}>
            <div style={{
              padding: '4px 12px',
              fontSize: '10px',
              color: 'var(--text-muted)',
              borderBottom: '1px solid var(--border-subtle)',
              fontFamily: 'var(--font-heading)',
              letterSpacing: '0.1em',
              textTransform: 'uppercase',
            }}>Removed</div>
            {hunk.oldContent.split('\n').map((line, i) => (
              <div key={`old-${i}`} style={{
                padding: '2px 12px',
                background: 'var(--diff-remove-bg)',
                fontFamily: 'var(--font-code)',
                fontSize: '12px',
                lineHeight: '1.6',
              }}>
                <span style={{ color: 'var(--error)', userSelect: 'none', marginRight: '8px' }}>-</span>
                <span style={{ color: 'var(--diff-remove-text)' }}>{line}</span>
              </div>
            ))}

            <div style={{
              padding: '4px 12px',
              fontSize: '10px',
              color: 'var(--text-muted)',
              borderBottom: '1px solid var(--border-subtle)',
              borderTop: '1px solid var(--border-subtle)',
              fontFamily: 'var(--font-heading)',
              letterSpacing: '0.1em',
              textTransform: 'uppercase',
            }}>Added</div>
            {hunk.newContent.split('\n').map((line, i) => (
              <div key={`new-${i}`} style={{
                padding: '2px 12px',
                background: 'var(--diff-add-bg)',
                fontFamily: 'var(--font-code)',
                fontSize: '12px',
                lineHeight: '1.6',
              }}>
                <span style={{ color: 'var(--success)', userSelect: 'none', marginRight: '8px' }}>+</span>
                <span style={{ color: 'var(--diff-add-text)' }}>{line}</span>
              </div>
            ))}
          </div>
        </div>
      ))}

      <div style={{
        marginTop: '8px',
        padding: '8px 12px',
        background: 'var(--bg-surface)',
        border: '1px solid var(--border-subtle)',
        fontSize: '11px',
        color: 'var(--text-muted)',
        fontFamily: 'var(--font-code)',
      }}>
        [Phase 1 scaffold] Approve/Reject wired in Phase 2. No files are modified.
      </div>
    </div>
  );
}

function Badge({ label, color }) {
  return (
    <span style={{
      fontFamily: 'var(--font-code)',
      fontSize: '10px',
      color,
      border: `1px solid ${color}`,
      padding: '2px 8px',
      borderRadius: '2px',
      letterSpacing: '0.05em',
    }}>
      {label}
    </span>
  );
}

export default DiffPreview;
