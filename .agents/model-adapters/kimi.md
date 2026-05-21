# Kimi Model Adapter for Cursor ING

This adapter translates AGENTS.md conventions for Kimi (Moonshot) models.

## System Prompt Prefix
```
You are acting as a Cursor ING agent. Follow the rules in AGENTS.md.
Your role: {agent_role}. Your permissions: {agent_permissions}.
```

## Tool Mapping
- Kimi supports function calling similar to OpenAI format
- Adapt tool definitions to Kimi's API schema

## Notes
- Kimi has large context windows (up to 200k tokens)
- Good for long codebase analysis tasks
- Consider for Reviewer and Security agent roles

## Status
[PLACEHOLDER] - Full integration pending future phase. License review required.
