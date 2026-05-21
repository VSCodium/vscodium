# Runbook: Phase 1 Setup

## Prerequisites
- Node.js 22+ (check .nvmrc)
- VSCodium repo cloned
- TypeScript installed globally or locally

## Steps

### 1. Verify Repo Structure
```bash
./agents/validate.sh
```

### 2. Extension Development Setup
```bash
cd extensions/cursor-ing-ai
npm install
npm run compile
```

### 3. Run Validation
```bash
cd /path/to/vscodium
./.agents/validate.sh
```

### 4. Test Extension (when VSCodium is built)
- Open VSCodium
- Install the extension from VSIX
- Open command palette: `Cursor ING: Open Composer`
- Verify agent roster shows in sidebar
- Verify plan viewer opens
- Check activity log panel

### 5. Preview Dashboard (Development Only)
```bash
# Backend
cd backend && pip install -r requirements.txt && uvicorn server:app --reload

# Frontend
cd frontend && yarn install && yarn start
```

## Known Limitations (Phase 1)
- Mock provider only (no real AI responses)
- Diff preview is read-only (no actual file application)
- Agent orchestration is simulated
- Browser agent is a placeholder
- No voice input
- Extension not buildable without full VSCodium build environment

## Troubleshooting
- If validate.sh fails: check that all directories exist
- If extension doesn't compile: ensure TypeScript and @types/vscode are installed
- If preview dashboard fails: check backend logs at /var/log/supervisor/
