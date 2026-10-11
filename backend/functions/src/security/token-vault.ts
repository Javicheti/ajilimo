export interface TokenResult {
  token: string;
  expiresInSeconds: number;
}

export type TokenFetcher = () => Promise<TokenResult>;

interface CacheEntry {
  token: string;
  expiresAt: number;
}

/**
 * Cachea tokens por clave (tenant/tienda) con margen de seguridad y los renueva
 * automáticamente antes de expirar.
 */
export class TokenVault {
  private readonly cache = new Map<string, CacheEntry>();
  private readonly skewMs: number;

  constructor(options?: { skewMs?: number }) {
    this.skewMs = options?.skewMs ?? 60_000;
  }

  async get(key: string, fetcher: TokenFetcher): Promise<string> {
    const now = Date.now();
    const entry = this.cache.get(key);
    if (entry && entry.expiresAt - this.skewMs > now) {
      return entry.token;
    }

    const result = await fetcher();
    this.cache.set(key, {
      token: result.token,
      expiresAt: now + result.expiresInSeconds * 1000,
    });
    return result.token;
  }

  invalidate(key: string): void {
    this.cache.delete(key);
  }

  clear(): void {
    this.cache.clear();
  }
}
