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
  brandId?: string;
  brandName?: string;
  source?: string;
  generatedAt?: string;
  stores?: BridgeStore[];
  serviceMetrics?: Record<string, unknown>;
  sales?: Record<string, unknown>;
  orders?: Array<Record<string, unknown>>;
  menus?: Array<Record<string, unknown>>;
}

interface BridgeDoc {
  defaultBrandId?: string;
  brands?: Record<string, BridgeSummary>;
}

async function loadBridgeDoc(provider: string): Promise<BridgeDoc | null> {
  try {
    const doc = await getFirestore().collection('bridges').doc(provider).get();
    return doc.exists ? (doc.data() as BridgeDoc) : null;
  } catch (error) {
    logger.warn('Bridge no disponible', { provider, error: String(error) });
    return null;
  }
}

function pickBrand(doc: BridgeDoc | null, brandId?: string): BridgeSummary | null {
  if (!doc?.brands) return null;
  const id = brandId || doc.defaultBrandId || Object.keys(doc.brands)[0];
  return id ? doc.brands[id] ?? null : null;
}

async function saveBrandSummary(provider: string, summary: BridgeSummary): Promise<void> {
  const brandId = summary.brandId || 'default';
  const ref = getFirestore().collection('bridges').doc(provider);
  const snap = await ref.get();
  const current = (snap.exists ? (snap.data() as BridgeDoc) : {}) ?? {};
  const brands: Record<string, BridgeSummary> = { ...(current.brands ?? {}) };
  brands[brandId] = { ...summary, receivedAt: new Date().toISOString() } as BridgeSummary;
  await ref.set({ defaultBrandId: brandId, brands }, { merge: false });
}

function brandParam(req: { query: Record<string, unknown> }): string | undefined {
  const value = req.query.brand;
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}

function bridgeEnabled(req: { query: Record<string, unknown> }): boolean {
  return process.env.BRIDGE_ENABLED === 'true' || req.query.source === 'bridge';
}

/**
 * BFF de AjíLimo. Modo normal (conectores) o BRIDGE (datos reales del Portal
 * Rappi, multi-marca, guardados en Firestore).
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
        await saveBrandSummary(provider, req.body as BridgeSummary);
        logger.info('Bridge actualizado', { provider, brandId: (req.body as BridgeSummary)?.brandId });
        res.status(200).json({ ok: true, provider });
        return;
      }
      const summary = pickBrand(await loadBridgeDoc(provider), brandParam(req));
      res.status(200).json({ ok: true, provider, summary });
      return;
    }

    // --- Marcas disponibles (bridge) ------------------------------------
    if (path.endsWith('/brands')) {
      const doc = await loadBridgeDoc('rappi');
      const brands = doc?.brands
        ? Object.entries(doc.brands).map(([brandId, s]) => ({ brandId, brandName: s.brandName ?? brandId }))
        : [];
      res.status(200).json({ brands, defaultBrandId: doc?.defaultBrandId ?? null });
      return;
    }

    // --- Reportes (métricas + ventas + órdenes) -------------------------
    if (path.endsWith('/reports')) {
      const summary = pickBrand(await loadBridgeDoc('rappi'), brandParam(req));
      res.status(200).json({
        source: summary ? 'bridge' : 'none',
        brandId: summary?.brandId ?? null,
        brandName: summary?.brandName ?? null,
        serviceMetrics: summary?.serviceMetrics ?? null,
        sales: summary?.sales ?? null,
        orders: summary?.orders ?? [],
        generatedAt: summary?.generatedAt ?? now.toISOString(),
      });
      return;
    }

    if (path.endsWith('/control-tower')) {
      if (bridgeEnabled(req)) {
        const summary = pickBrand(await loadBridgeDoc('rappi'), brandParam(req));
        if (summary?.stores && summary.stores.length > 0) {
          const rows = summary.stores.map((store) => ({
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
            brandId: summary.brandId ?? null,
            generatedAt: summary.generatedAt ?? now.toISOString(),
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
        const summary = pickBrand(await loadBridgeDoc('rappi'), brandParam(req));
        if (summary?.orders && summary.orders.length > 0) {
          const rows = summary.orders.map((o) => ({
            channel: 'rappi',
            storeId: '',
            storeName: String(o.store ?? ''),
            orderId: String(o.orderId ?? ''),
            status: String(o.state ?? ''),
            itemCount: 1,
            total: typeof o.total === 'number' ? o.total : 0,
          }));
          res.status(200).json({ orders: rows, source: 'bridge', generatedAt: summary.generatedAt ?? now.toISOString() });
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
      const summary = pickBrand(await loadBridgeDoc('rappi'), brandParam(req));
      res.status(200).json({
        source: summary ? 'bridge' : 'none',
        brandId: summary?.brandId ?? null,
        menus: summary?.menus ?? [],
        generatedAt: summary?.generatedAt ?? now.toISOString(),
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
