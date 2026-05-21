/**
 * Mock Provider - Cursor ING
 *
 * Deterministic, local-only provider that works without API keys.
 * Returns hardcoded responses for testing and demonstration.
 * No network calls, no telemetry, no secrets.
 */

import {
  AIProvider,
  ProviderCapabilities,
  ProviderRequest,
  ProviderResponse,
  ProviderStatus,
} from './types';

const MOCK_RESPONSES: Record<string, string> = {
  default: 'I am the Cursor ING mock provider. I produce deterministic responses for testing. No API key required.',
  plan: `Here is a structured plan for the requested task:

1. **Analyze** - Read relevant files and understand the codebase context
2. **Design** - Propose the approach with clear steps
3. **Implement** - Write code changes as diffs
4. **Review** - Check for correctness and security issues
5. **Test** - Verify changes work as expected
6. **Document** - Update relevant documentation

Each step requires explicit approval before proceeding.`,
  code: `\`\`\`typescript
// Example generated code (mock)
export function processRequest(input: string): string {
  // Validate input
  if (!input || input.trim().length === 0) {
    throw new Error('Input must not be empty');
  }

  // Process
  const result = input.trim().toLowerCase();

  // Return processed result
  return result;
}
\`\`\``,
  review: `## Code Review

**File**: src/example.ts
**Severity**: Info

### Findings:
1. **Line 5** - Consider adding input type validation
2. **Line 12** - Edge case: handle unicode characters
3. **Line 18** - Good: error handling is present

### Verdict: Approved with minor suggestions`,
  security: `## Security Scan

**Status**: Clear

### Checks:
- [x] No hardcoded secrets or API keys
- [x] No telemetry or tracking code
- [x] No unsafe eval/exec patterns
- [x] No SQL injection vectors
- [x] Input validation present
- [x] License headers present

No security issues detected.`,
};

export class MockProvider implements AIProvider {
  readonly id = 'mock';
  readonly name = 'Mock Provider (Local)';
  readonly type = 'mock' as const;
  readonly requiresKey = false;
  readonly capabilities: ProviderCapabilities = {
    chat: true,
    codeCompletion: true,
    embedding: false,
    streaming: false,
    functionCalling: false,
    vision: false,
  };

  async isAvailable(): Promise<boolean> {
    return true; // Always available, no external dependencies
  }

  async chat(request: ProviderRequest): Promise<ProviderResponse> {
    const lastMessage = request.messages[request.messages.length - 1];
    const content = lastMessage?.content?.toLowerCase() ?? '';

    // Select response based on content keywords
    let responseContent: string;
    if (content.includes('plan') || content.includes('task')) {
      responseContent = MOCK_RESPONSES.plan;
    } else if (content.includes('code') || content.includes('implement') || content.includes('write')) {
      responseContent = MOCK_RESPONSES.code;
    } else if (content.includes('review') || content.includes('check')) {
      responseContent = MOCK_RESPONSES.review;
    } else if (content.includes('security') || content.includes('scan') || content.includes('audit')) {
      responseContent = MOCK_RESPONSES.security;
    } else {
      responseContent = MOCK_RESPONSES.default;
    }

    // Simulate minimal processing delay
    await new Promise(resolve => setTimeout(resolve, 100));

    return {
      content: responseContent,
      model: 'cursor-ing-mock-v1',
      provider: this.id,
      usage: {
        promptTokens: content.split(/\s+/).length,
        completionTokens: responseContent.split(/\s+/).length,
        totalTokens: content.split(/\s+/).length + responseContent.split(/\s+/).length,
      },
      finishReason: 'stop',
    };
  }

  getStatus(): ProviderStatus {
    return {
      id: this.id,
      name: this.name,
      available: true,
      model: 'cursor-ing-mock-v1',
      latency: 100,
    };
  }
}
