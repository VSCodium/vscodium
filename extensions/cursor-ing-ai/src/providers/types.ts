/**
 * Provider Types - Cursor ING
 *
 * Defines the provider abstraction layer for AI model backends.
 * Phase 1: Mock provider only.
 * Future: OpenAI, Anthropic, Ollama, OpenRouter, Gemini, Kimi, Qwen, Codex.
 */

/** A single message in a conversation */
export interface Message {
  role: 'system' | 'user' | 'assistant';
  content: string;
  timestamp: string;
}

/** Request to the provider */
export interface ProviderRequest {
  messages: Message[];
  maxTokens?: number;
  temperature?: number;
  stop?: string[];
}

/** Response from the provider */
export interface ProviderResponse {
  content: string;
  model: string;
  provider: string;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  finishReason: 'stop' | 'length' | 'error';
}

/** Provider capabilities */
export interface ProviderCapabilities {
  chat: boolean;
  codeCompletion: boolean;
  embedding: boolean;
  streaming: boolean;
  functionCalling: boolean;
  vision: boolean;
}

/** Provider configuration */
export interface ProviderConfig {
  id: string;
  type: 'mock' | 'openai-compatible' | 'anthropic-compatible' | 'ollama-local' | 'openrouter-compatible';
  apiKey?: string;
  baseUrl?: string;
  model?: string;
  maxTokens?: number;
  temperature?: number;
}

/** Provider interface - all providers must implement this */
export interface AIProvider {
  readonly id: string;
  readonly name: string;
  readonly type: ProviderConfig['type'];
  readonly requiresKey: boolean;
  readonly capabilities: ProviderCapabilities;

  /** Check if the provider is available and configured */
  isAvailable(): Promise<boolean>;

  /** Send a chat completion request */
  chat(request: ProviderRequest): Promise<ProviderResponse>;

  /** Get provider status for display */
  getStatus(): ProviderStatus;
}

/** Provider status for UI display */
export interface ProviderStatus {
  id: string;
  name: string;
  available: boolean;
  model: string;
  latency?: number;
  error?: string;
}
