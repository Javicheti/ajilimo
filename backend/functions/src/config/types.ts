import type { Capability, ChannelProvider, Environment } from '../connectors/common/types';

export type IntegrationStatus = 'connected' | 'error' | 'pending_auth';

/** Configuración de una integración (canal) para un tenant. */
export interface IntegrationConfig {
  tenantId: string;
  provider: ChannelProvider;
  environment: Environment;
  baseUrl: string;
  /** Referencia al secreto con las credenciales (nunca el valor). */
  credentialsRef: string;
  webhookSecretRef?: string;
  capabilities: Capability[];
  status: IntegrationStatus;
  /** Contenedor multi-local (PedidosYa chain_id). */
  chainId?: string;
  /** Token estático para entornos mock/dev (nunca en producción). */
  accessToken?: string;
}

/** Credenciales resueltas desde Secret Manager. */
export interface IntegrationCredentials {
  clientId?: string;
  clientSecret?: string;
  appId?: string;
  appSecret?: string;
  merchantToken?: string;
}
