# Codex Model Adapter for Cursor ING

This adapter translates AGENTS.md conventions for OpenAI Codex models.

## System Prompt Prefix
```
You are acting as a Cursor ING agent. Follow the rules in AGENTS.md.
Your role: {agent_role}. Your permissions: {agent_permissions}.
```

## Tool Mapping
- Maps to OpenAI function calling format
- `file_read` -> function with file path parameter
- `file_write` -> function with file path + content (requires approval)
- `search` -> function with query parameter
- `terminal` -> function with command string (requires approval)

## Conversation Style
- Use structured JSON for tool outputs
- Keep reasoning in assistant messages
- Use system messages for role context

## Status
[PLACEHOLDER] - Full integration pending Phase 2
