/**
 * Servicio de secretos. La implementación real escribe/lee de Google Secret Manager
 * con nombres `tenants/{tenantId}/{provider}/{env}/...`. Nunca expone el valor al cliente.
 */
export interface SecretService {
  /** Devuelve el valor del secreto o null si no existe. */
  get(ref: string): Promise<string | null>;
  /** Crea una nueva versión del secreto. */
  put(ref: string, value: string): Promise<void>;
}

/** Implementación en memoria (tests y arranque sin GCP). */
export class InMemorySecretService implements SecretService {
  private readonly store = new Map<string, string>();

  constructor(seed?: Record<string, string>) {
    if (seed) {
      for (const [key, value] of Object.entries(seed)) this.store.set(key, value);
    }
  }

  async get(ref: string): Promise<string | null> {
    return this.store.get(ref) ?? null;
  }

  async put(ref: string, value: string): Promise<void> {
    this.store.set(ref, value);
  }
}

/** Construye la referencia estándar de un secreto. */
export function secretRef(
  tenantId: string,
  provider: string,
  environment: string,
  kind: 'oauth' | 'webhook',
): string {
  return `tenants/${tenantId}/${provider}/${environment}/${kind}`;
}
