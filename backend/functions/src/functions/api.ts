import { onRequest } from 'firebase-functions/v2/https';

import { createConnector } from '../connectors/common/factory';
import { loadIntegrations } from '../config/runtime-config';
import type { IntegrationConfig } from '../config/types';
import { buildControlTower, type ChannelStoreInput } from '../domain/control-tower';
import { isWithinSchedule } from '../domain/schedule';
import { logger } from '../shared/logger';

function contextOf(config: IntegrationConfig) {
  return {
    baseUrl: config.baseUrl,
    accessToken: config.accessToken,
    chainId: config.chainId,
  };
}

/**
 * BFF (backend-for-frontend) de AjíLimo. Sirve datos ya normalizados a las apps.
 * Hoy lee de los mocks locales; con credenciales reales solo cambia la config
 * (`RAPPI_BASE_URL`, etc.) y el backend de secretos.
 */
export const api = onRequest({ cors: true, region: 'us-central1' }, async (req, res) => {
  const path = req.url ?? '/';
  const now = new Date();

  try {
    if (path.includes('/control-tower')) {
      const rows: ChannelStoreInput[] = [];
      const channels: Array<{ provider: string; ok: boolean; error?: string }> = [];

      for (const config of loadIntegrations()) {
        try {
          const connector = createConnector(config.provider, contextOf(config));
          const stores = await connector.listStores();
          const availability = await connector.getAvailability(stores.map((s) => s.storeId));
          const onlineByStore = new Map(availability.map((a) => [a.storeId, a.online]));

          for (const store of stores) {
            const windows = await connector.getStoreSchedule(store.storeId).catch(() => []);
            rows.push({
              channel: config.provider,
              storeId: store.storeId,
              name: store.name,
              brand: store.brand,
              online: onlineByStore.get(store.storeId) ?? false,
              withinSchedule: isWithinSchedule(now, windows),
            });
          }
          channels.push({ provider: config.provider, ok: true });
        } catch (error) {
          channels.push({ provider: config.provider, ok: false, error: String(error) });
          logger.warn('Canal no disponible', { provider: config.provider, error: String(error) });
        }
      }

      res.status(200).json({ rows: buildControlTower(rows), channels, generatedAt: now.toISOString() });
      return;
    }

    if (path.includes('/connections')) {
      const integrations = loadIntegrations().map((config) => ({
        provider: config.provider,
        environment: config.environment,
        baseUrl: config.baseUrl,
        status: config.status,
        capabilities: config.capabilities,
        credentialsConfigured: false,
      }));
      res.status(200).json({ integrations, generatedAt: now.toISOString() });
      return;
    }

    res.status(404).json({ message: `Ruta no encontrada: ${path}` });
  } catch (error) {
    logger.error('Error en BFF', { path, error: String(error) });
    res.status(500).json({ message: 'Error interno', error: String(error) });
  }
});
