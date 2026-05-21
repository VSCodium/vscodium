# Brain: Assumptions

Documented assumptions for Cursor ING Phase 1.

## Architecture Assumptions
1. VS Code extension APIs are sufficient for AI composer, agent panels, and diff views
2. Webview panels can handle the agent roster, plan viewer, and activity log UI
3. The provider abstraction can be generic enough for OpenAI, Anthropic, Ollama, and OpenRouter
4. Mock provider responses are sufficient to demonstrate the architecture

## Legal Assumptions
1. All code in extensions/cursor-ing-ai/ is original (MIT-compatible)
2. No Cursor proprietary code, assets, or UI has been copied
3. VSCodium's MIT license is compatible with Cursor ING additions
4. Vendor references in .agents/vendor/ are inspiration only until license review

## Build Assumptions
1. The extension can be developed independently of the VSCodium build pipeline
2. Extension development uses standard VS Code extension tools (vsce, yo)
3. The extension will be distributed via Open VSX or direct VSIX install
4. No changes to prepare_vscode.sh, build.sh, or patches/ are needed in Phase 1

## Environment Assumptions
1. Node.js 22+ available (per .nvmrc)
2. TypeScript for extension code
3. No Electron core modifications needed
4. Extension testing via VS Code extension test framework
