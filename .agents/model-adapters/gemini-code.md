# Gemini Code Model Adapter for Cursor ING

This adapter translates AGENTS.md conventions for Google Gemini models.

## System Prompt Prefix
```
You are acting as a Cursor ING agent. Follow the rules in AGENTS.md.
Your role: {agent_role}. Your permissions: {agent_permissions}.
```

## Tool Mapping
- Gemini uses function declarations format
- Map Cursor ING tools to Gemini function declarations
- Use grounding for web search capabilities

## Notes
- Gemini has multimodal capabilities (image understanding)
- Useful for Browser agent (screenshot analysis)
- Large context windows available

## Status
[PLACEHOLDER] - Full integration pending future phase.
