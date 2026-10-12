import { getFirestore } from 'firebase-admin/firestore';
import { onRequest } from 'firebase-functions/v2/https';

import { createConnector } from '../connectors/common/factory';
import { DidiConnector } from '../connectors/didi/didi-connector';
import { loadIntegrations } from '../config/runtime-config';
import type { IntegrationConfig } from '../config/types';
import { buildControlTower, type ChannelStoreInput } from '../domain/control-tower';
import { buildOrderRows } from '../domain/orders';
import { isWithinSchedule } from '../domain/schedule';
import { logger } from '../shared/logger';
import type { ChannelProvider, Order } from '../connectors/common/types';

function contextOf(config: IntegrationConfig) {
  return { baseUrl: config.baseUrl, accessToken: config.accessToken, chainId: config.chainId };
}

interface BridgeStore {
  storeId: string;
  name: string;
  brand?: string;
  isEnabled?: boolean;
  isPublished?: boolean;
}

interface BridgeSummary {
  source?: string;
  generatedAt?: string;
  stores?: BridgeStore[];
  serviceMetrics?: Record<string, unknown>;
  sales?: Record<string, unknown>;
  orders?: Array<Record<string, unknown>>;
  menus?: Array<Record<string, unknown>>;
}

async function loadBridge(provider: string): Promise<BridgeSummary | null> {
  try {
    const doc = await getFirestore().collection('bridges').doc(provider).get();
    return doc.exists ? (doc.data() as BridgeSummary) : null;
  } catch (error) {
    logger.warn('Bridge no disponible', { provider, error: String(error) });
    return null;
  }
}

async function saveBridge(provider: string, summary: BridgeSummary): Promise<void> {
  await getFirestore()
    .collection('bridges')
    .doc(provider)
    .set({ ...summary, receivedAt: new Date().toISOString() }, { merge: true });
}

function bridgeEnabled(req: { query: Record<string, unknown> }): boolean {
  return process.env.BRIDGE_ENABLED === 'true' || req.query.source === 'bridge';
}

/**
 * BFF de AjíLimo. Sirve datos normalizados a las apps.
 * - Modo normal: conectores (mocks/real).
 * - Modo BRIDGE: datos reales del Portal Rappi (scraper) guardados en Firestore.
 */
export const api = onRequest({ cors: true, region: 'us-central1' }, async (req, res) => {
  const path = (req.url ?? '/').split('?')[0];
  const now = new Date();

  try {
    // --- Bridge: ingesta (scraper publica aquí) --------------------------
    if (path.includes('/bridge/')) {
      const provider = path.split('/bridge/')[1]?.split('/')[0] || 'rappi';
      if (req.method === 'POST' || req.method === 'PUT') {
        const token = req.get('x-bridge-token');
        if (process.env.BRIDGE_TOKEN && token !== process.env.BRIDGE_TOKEN) {
          res.status(401).json({ ok: false, error: 'invalid_token' });
          return;
        }
        await saveBridge(provider, req.body as BridgeSummary);
        logger.info('Bridge actualizado', { provider });
        res.status(200).json({ ok: true, provider });
        return;
      }
      const summary = await loadBridge(provider);
      res.status(200).json({ ok: true, provider, summary });
      return;
    }

    // --- Bridge: reportes (métricas + ventas + órdenes reales) -----------
    if (path.endsWith('/reports')) {
      const bridge = await loadBridge('rappi');
      res.status(200).json({
        source: bridge ? 'bridge' : 'none',
        serviceMetrics: bridge?.serviceMetrics ?? null,
        sales: bridge?.sales ?? null,
        orders: bridge?.orders ?? [],
        generatedAt: bridge?.generatedAt ?? now.toISOString(),
      });
      return;
    }

    if (path.endsWith('/control-tower')) {
      // Bridge primero (datos reales del portal).
      if (bridgeEnabled(req)) {
        const bridge = await loadBridge('rappi');
        if (bridge?.stores && bridge.stores.length > 0) {
          const rows = bridge.stores.map((store) => ({
            channel: 'rappi' as ChannelProvider,
            storeId: store.storeId,
            name: store.name,
            brand: store.brand,
            status: store.isEnabled ? 'open' : 'paused',
          }));
          res.status(200).json({
            rows,
            channels: [{ provider: 'rappi', ok: true }],
            source: 'bridge',
            generatedAt: bridge.generatedAt ?? now.toISOString(),
          });
          return;
        }
      }

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
      res.status(200).json({ rows: buildControlTower(rows), channels, source: 'connectors', generatedAt: now.toISOString() });
      return;
    }

    if (path.endsWith('/orders')) {
      if (bridgeEnabled(req)) {
        const bridge = await loadBridge('rappi');
        if (bridge?.orders && bridge.orders.length > 0) {
          const rows = bridge.orders.map((o) => ({
            channel: 'rappi',
            storeId: '',
            storeName: String(o.store ?? ''),
            orderId: String(o.orderId ?? ''),
            status: String(o.state ?? ''),
            itemCount: 1,
            total: typeof o.total === 'number' ? o.total : 0,
          }));
          res.status(200).json({ orders: rows, source: 'bridge', generatedAt: bridge.generatedAt ?? now.toISOString() });
          return;
        }
      }

      const entries: Array<{ channel: IntegrationConfig['provider']; storeId: string; storeName?: string; order: Order }> = [];
      for (const config of loadIntegrations()) {
        try {
          const connector = createConnector(config.provider, contextOf(config));
          const stores = await connector.listStores();
          for (const store of stores.slice(0, 5)) {
            const orders = await connector.getOrders(store.storeId).catch(() => []);
            for (const order of orders) entries.push({ channel: config.provider, storeId: store.storeId, storeName: store.name, order });
          }
        } catch (error) {
          logger.warn('Órdenes: canal no disponible', { provider: config.provider, error: String(error) });
        }
      }
      res.status(200).json({ orders: buildOrderRows(entries), source: 'connectors', generatedAt: now.toISOString() });
      return;
    }

    if (path.endsWith('/menu')) {
      const bridge = await loadBridge('rappi');
      res.status(200).json({
        source: bridge ? 'bridge' : 'none',
        menus: bridge?.menus ?? [],
        generatedAt: bridge?.generatedAt ?? now.toISOString(),
      });
      return;
    }

    if (path.endsWith('/claims')) {
      const claims: Array<Record<string, unknown>> = [];
      for (const config of loadIntegrations()) {
        if (config.provider !== 'didi') continue;
        try {
          const connector = createConnector('didi', contextOf(config)) as DidiConnector;
          for (const claim of await connector.getClaims()) claims.push({ ...claim, channel: 'didi' });
        } catch (error) {
          logger.warn('Reclamos: canal no disponible', { provider: config.provider, error: String(error) });
        }
      }
      res.status(200).json({ claims, generatedAt: now.toISOString() });
      return;
    }

    if (path.endsWith('/connections')) {
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
