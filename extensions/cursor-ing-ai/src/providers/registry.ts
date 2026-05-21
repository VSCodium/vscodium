/**
 * Provider Registry - Cursor ING
 *
 * Singleton factory that manages AI provider instances.
 * Supports registration, lookup, and active provider switching.
 */

import { AIProvider, ProviderConfig } from './types';

export class ProviderRegistry {
  private static instance: ProviderRegistry;
  private providers: Map<string, AIProvider> = new Map();
  private activeProviderId: string = 'mock';

  private constructor() {}

  static getInstance(): ProviderRegistry {
    if (!ProviderRegistry.instance) {
      ProviderRegistry.instance = new ProviderRegistry();
    }
    return ProviderRegistry.instance;
  }

  /** Register a provider instance */
  register(id: string, provider: AIProvider): void {
    this.providers.set(id, provider);
  }

  /** Unregister a provider */
  unregister(id: string): void {
    this.providers.delete(id);
    if (this.activeProviderId === id) {
      this.activeProviderId = 'mock';
    }
  }

  /** Get a provider by ID */
  get(id: string): AIProvider | undefined {
    return this.providers.get(id);
  }

  /** Get the active provider */
  getActive(): AIProvider | undefined {
    return this.providers.get(this.activeProviderId);
  }

  /** Set the active provider */
  setActive(id: string): boolean {
    if (this.providers.has(id)) {
      this.activeProviderId = id;
      return true;
    }
    return false;
  }

  /** Get all registered provider IDs */
  getRegisteredIds(): string[] {
    return Array.from(this.providers.keys());
  }

  /** Get status of all providers */
  getAllStatuses(): { id: string; name: string; active: boolean; available: boolean }[] {
    return Array.from(this.providers.entries()).map(([id, provider]) => ({
      id,
      name: provider.name,
      active: id === this.activeProviderId,
      available: true, // Sync check; use isAvailable() for async
    }));
  }

  /**
   * Create a provider from config.
   * [PLACEHOLDER] - Phase 2 will add real provider factories.
   */
  static createFromConfig(_config: ProviderConfig): AIProvider | null {
    // Phase 1: Only mock provider is implemented
    // Phase 2: Factory pattern for OpenAI, Anthropic, Ollama, OpenRouter
    return null;
  }
}
