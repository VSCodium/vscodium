# Claude Model Adapter for Cursor ING

This adapter translates AGENTS.md conventions for Claude (Anthropic) models.

## System Prompt Prefix
When using Claude as a Cursor ING agent, prepend:
```
You are acting as a Cursor ING agent. Follow the rules in AGENTS.md.
Your role: {agent_role}. Your permissions: {agent_permissions}.
```

## Tool Mapping
- `file_read` -> Claude tool_use with file reading
- `file_write` -> Claude tool_use with file writing (requires approval)
- `search` -> Claude tool_use with code search
- `terminal` -> Claude tool_use with command execution (requires approval)

## Conversation Style
- Claude prefers structured XML-like sections
- Use `<thinking>` for reasoning traces
- Use `<action>` for tool calls
- Use `<output>` for final responses

## Token Limits
- Claude Sonnet: 200k context, 8k output
- Claude Opus: 200k context, 32k output
- Adjust plan granularity accordingly

## Status
[PLACEHOLDER] - Full integration pending Phase 2
