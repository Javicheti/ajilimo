import type { ChannelProvider } from '../connectors/common/types';
import type { IntegrationConfig } from './types';

/** Resuelve la configuración de integración por tenant y proveedor. */
export interface TenantResolver {
  resolveIntegration(
    tenantId: string,
    provider: ChannelProvider,
  ): Promise<IntegrationConfig | undefined>;
  listIntegrations(tenantId: string): Promise<IntegrationConfig[]>;
}

/** Implementación en memoria (dev/tests). En producción lee de Firestore. */
export class InMemoryTenantResolver implements TenantResolver {
  private readonly configs: IntegrationConfig[];

  constructor(configs: IntegrationConfig[]) {
    this.configs = configs;
  }

  async resolveIntegration(
    tenantId: string,
    provider: ChannelProvider,
  ): Promise<IntegrationConfig | undefined> {
    return this.configs.find((c) => c.tenantId === tenantId && c.provider === provider);
  }

  async listIntegrations(tenantId: string): Promise<IntegrationConfig[]> {
    return this.configs.filter((c) => c.tenantId === tenantId);
  }
}
