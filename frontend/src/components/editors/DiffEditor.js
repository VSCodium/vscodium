import React from 'react';

function DiffEditor({ diff }) {
  if (!diff) {
    return (
      <div data-testid="editor-diff-empty" style={{ flex: 1, background: 'var(--bg-editor)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-dimmed)' }}>
        No diff to review.
      </div>
    );
  }

  const hunk = diff.hunks[0];
  const oldLines = hunk.oldContent.split('\n');
  const newLines = hunk.newContent.split('\n');
  let lineCounter = hunk.startLine;

  return (
    <div data-testid="editor-diff" style={{
      flex: 1, overflow: 'auto',
      background: 'var(--bg-editor)',
      fontFamily: 'var(--font-mono)',
      fontSize: 12,
    }}>
      {/* Diff header */}
      <div style={{
        padding: '8px 16px',
        borderBottom: '1px solid var(--border)',
        display: 'flex', alignItems: 'center', gap: 12,
        fontSize: 12, color: 'var(--text-muted)',
      }}>
        <span style={{ color: 'var(--accent)' }}>{hunk.filePath}</span>
        <span style={{ color: 'var(--text-dimmed)' }}>|</span>
        <span>{diff.title}</span>
        <span style={{ color: 'var(--text-dimmed)' }}>|</span>
        <span>by {diff.agentId}</span>
        <span style={{ marginLeft: 'auto' }}>
          <StatusBadge status={diff.status} />
        </span>
      </div>

      {/* Diff body: unified diff style */}
      <div style={{ padding: '4px 0' }}>
        {/* Removed lines */}
        {oldLines.map((line, i) => (
          <DiffLine key={`r${i}`} type="remove" lineNum={lineCounter + i} content={line} />
        ))}
        {/* Separator */}
        <div style={{ padding: '2px 16px', borderTop: '1px dashed var(--border)', borderBottom: '1px dashed var(--border)' }}>
          <span style={{ fontSize: 10, color: 'var(--text-dimmed)', fontFamily: 'var(--font-mono)' }}>
            @@ -{hunk.startLine},{oldLines.length} +{hunk.startLine},{newLines.length} @@
          </span>
        </div>
        {/* Added lines */}
        {newLines.map((line, i) => (
          <DiffLine key={`a${i}`} type="add" lineNum={hunk.startLine + i} content={line} />
        ))}
      </div>

      {/* Approval bar */}
      <div style={{
        display: 'flex', gap: 8, padding: '12px 16px',
        borderTop: '1px solid var(--border)',
        position: 'sticky', bottom: 0,
        background: 'var(--bg-editor)',
        alignItems: 'center',
      }}>
        <button data-testid="diff-approve-btn" disabled style={actionBtn('var(--success)')}>
          Accept Change
        </button>
        <button data-testid="diff-reject-btn" disabled style={actionBtn('var(--error)')}>
          Reject
        </button>
        <span style={{ fontSize: 10, color: 'var(--text-dimmed)', marginLeft: 8 }}>
          [Phase 1 scaffold &mdash; no files modified]
        </span>
      </div>
    </div>
  );
}

function DiffLine({ type, lineNum, content }) {
  const isAdd = type === 'add';
  return (
    <div style={{
      display: 'flex',
      background: isAdd ? 'var(--diff-add-bg)' : 'var(--diff-remove-bg)',
      padding: '1px 0',
      minHeight: 20,
    }}>
      <span style={{
        width: 48, textAlign: 'right', paddingRight: 8,
        color: 'var(--line-number)', fontSize: 11,
        userSelect: 'none', flexShrink: 0,
      }}>{lineNum}</span>
      <span style={{
        width: 16, textAlign: 'center',
        color: isAdd ? 'var(--diff-add-text)' : 'var(--diff-remove-text)',
        fontWeight: 600, userSelect: 'none', flexShrink: 0,
      }}>{isAdd ? '+' : '-'}</span>
      <span style={{
        color: isAdd ? 'var(--diff-add-text)' : 'var(--diff-remove-text)',
        whiteSpace: 'pre',
        paddingRight: 16,
      }}>{content}</span>
    </div>
  );
}

function StatusBadge({ status }) {
  const c = status === 'pending' ? 'var(--warning)' : status === 'approved' ? 'var(--success)' : 'var(--error)';
  return (
    <span style={{
      fontSize: 10, color: c, border: `1px solid ${c}`,
      padding: '1px 6px', textTransform: 'uppercase',
      letterSpacing: '0.05em',
    }}>{status}</span>
  );
}

const actionBtn = (color) => ({
  padding: '4px 14px',
  fontSize: 11,
  fontFamily: 'var(--font-mono)',
  color,
  background: 'transparent',
  border: `1px solid ${color}`,
  cursor: 'not-allowed',
  opacity: 0.6,
});

export default DiffEditor;
