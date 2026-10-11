import type { ChannelProvider, Environment } from '../connectors/common/types';
import { secretRef } from './secret-service';
import type { IntegrationConfig } from './types';

function env(name: string, fallback: string): string {
  const value = process.env[name];
  return value && value.trim() ? value.trim() : fallback;
}

export function defaultTenantId(): string {
  return env('DEFAULT_TENANT', 'demo');
}

export function currentEnvironment(): Environment {
  return env('AJILIMO_ENV', 'mock') as Environment;
}

/**
 * Carga las integraciones desde el entorno. Por defecto apunta a los **mocks
 * locales** (datos ficticios). Para producción basta con definir:
 *   RAPPI_BASE_URL / DIDI_BASE_URL / PEDIDOSYA_BASE_URL (+ chainId) y credenciales
 *   en Secret Manager — sin cambiar código.
 */
export function loadIntegrations(): IntegrationConfig[] {
  const tenantId = defaultTenantId();
  const environment = currentEnvironment();

  const configs: IntegrationConfig[] = [
    {
      tenantId,
      provider: 'rappi',
      environment,
      baseUrl: env('RAPPI_BASE_URL', 'http://localhost:8787'),
      credentialsRef: secretRef(tenantId, 'rappi', environment, 'oauth'),
      capabilities: ['stores', 'menu', 'availability', 'orders', 'promos', 'financial'],
      status: 'connected',
      accessToken: env('RAPPI_ACCESS_TOKEN', 'mock-rappi-token'),
    },
    {
      tenantId,
      provider: 'didi',
      environment,
      baseUrl: env('DIDI_BASE_URL', 'http://localhost:8790'),
      credentialsRef: secretRef(tenantId, 'didi', environment, 'oauth'),
      capabilities: ['stores', 'menu', 'availability', 'orders', 'promos', 'claims'],
      status: 'connected',
      accessToken: env('DIDI_ACCESS_TOKEN', 'mock-didi-token'),
    },
    {
      tenantId,
      provider: 'pedidosya',
      environment,
      baseUrl: env('PEDIDOSYA_BASE_URL', 'http://localhost:8791'),
      credentialsRef: secretRef(tenantId, 'pedidosya', environment, 'oauth'),
      capabilities: ['stores', 'menu', 'availability', 'orders', 'promos'],
      status: 'connected',
      accessToken: env('PEDIDOSYA_ACCESS_TOKEN', 'mock-peya-token'),
      chainId: env('PEDIDOSYA_CHAIN_ID', 'CH-DEMO'),
    },
  ];

  const only = process.env.ENABLED_CHANNELS;
  if (only) {
    const enabled = new Set(only.split(',').map((value) => value.trim() as ChannelProvider));
    return configs.filter((config) => enabled.has(config.provider));
  }
  return configs;
}
