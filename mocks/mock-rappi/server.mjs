import { createServer } from 'node:http';
import { createHmac, randomUUID } from 'node:crypto';

/**
 * Mock de Rappi — replica el contrato documentado (RESTs API / Public API)
 * y emite webhooks firmados con HMAC-SHA256 para poder probar la plataforma
 * sin credenciales reales.
 *
 * Sin dependencias externas. Arrancar: `node server.mjs` (puerto 8787).
 */

export const WEBHOOK_SECRET = 'mock-rappi-secret';

const STORES = [
  { store_id: '900105814', name: 'PINWINGS — Surco', brand: 'PINWINGS' },
  { store_id: '900105815', name: 'PINWINGS — Miraflores', brand: 'PINWINGS' },
  { store_id: '900105816', name: 'Makis — Centro', brand: 'Makis' },
];

const ITEMS_BY_STORE = {
  '900105814': [
    item(1001, 'promo_makis_alas', 'Promo Makis + Alas', 39.9, true),
    item(1002, 'alas_bbq', 'Alas BBQ (x8)', 24.9, false),
    item(1003, 'gaseosa_500', 'Gaseosa 500ml', 6.9, true),
  ],
  '900105815': [item(1001, 'promo_makis_alas', 'Promo Makis + Alas', 39.9, true)],
  '900105816': [item(2001, 'maki_california', 'Maki California (x10)', 29.9, true)],
};

function item(id, sku, title, price, available) {
  return {
    id,
    sku,
    item_type: 'ITEM',
    title_info: { title, overrides: [] },
    price_info: { price, overrides: [] },
    suspension_info: {
      suspend_until: null,
      suspend_reason: available ? null : 'Is stocked out',
      overrides: [],
      is_available: available,
    },
    schedules_info: {
      schedules: [
        { days_of_week: 'mon,tue,wed,thu,fri,sat,sun,hol', time_periods: [{ start_time: '11:00', end_time: '23:30' }] },
      ],
      overrides: [],
    },
  };
}

/** Firma un payload igual que Rappi: HMAC_SHA256 sobre `${t}.${payload}`. */
export function signPayload(payload, secret = WEBHOOK_SECRET, timestamp = Math.floor(Date.now() / 1000)) {
  const sign = createHmac('sha256', secret).update(`${timestamp}.${payload}`).digest('hex');
  return `t=${timestamp},sign=${sign}`;
}

/** Construye un payload de ejemplo por evento. */
export function buildEvent(event, overrides = {}) {
  switch (event) {
    case 'NEW_ORDER':
      return {
        order_detail: {
          order_id: overrides.order_id ?? String(randomUUID()).slice(0, 8),
          store_id: overrides.store_id ?? '900105814',
          items: overrides.items ?? [{ id: '1001', name: 'Promo Makis + Alas', sku: 'promo_makis_alas', quantity: 2, price: 39.9 }],
          totals: { total_order: 79.8, total_to_pay: 79.8 },
        },
      };
    case 'STORE_CONNECTIVITY':
      return {
        external_store_id: overrides.store_id ?? '900105814',
        enabled: overrides.enabled ?? false,
        message: 'The Store is not enabled to operate',
      };
    case 'ORDER_EVENT_CANCEL':
      return { event: overrides.reason ?? 'canceled_with_charge', order_id: overrides.order_id ?? '106', store_id: overrides.store_id ?? '900105814' };
    default:
      return { event, ...overrides };
  }
}

/** Dispara un webhook firmado al endpoint dado. */
export async function fireWebhook(targetUrl, event, overrides = {}, secret = WEBHOOK_SECRET) {
  const payload = JSON.stringify(buildEvent(event, overrides));
  const headers = {
    'content-type': 'application/json',
    'rappi-signature': signPayload(payload, secret),
  };
  const res = await fetch(targetUrl, { method: 'POST', headers, body: payload });
  return { status: res.status, payload, signature: headers['rappi-signature'] };
}

function json(res, status, body) {
  const data = JSON.stringify(body);
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(data);
}

function readBody(req) {
  return new Promise((resolve) => {
    let raw = '';
    req.on('data', (chunk) => (raw += chunk));
    req.on('end', () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch {
        resolve({});
      }
    });
  });
}

export function createApp() {
  return createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');
    const path = url.pathname;
    const method = req.method;

    if (path === '/health') {
      return json(res, 200, { ok: true, service: 'mock-rappi' });
    }

    if (method === 'POST' && path === '/restaurants/auth/v1/token/login/integrations') {
      return json(res, 200, { access_token: 'mock-access-token', token_type: 'Bearer' });
    }

    if (method === 'GET' && path === '/api/v2/restaurants-integrations-public-api/stores-pa') {
      return json(res, 200, { stores: STORES.map((s) => ({ ...s, integrationId: 'mock-integration', rappiId: s.store_id })) });
    }

    if (method === 'POST' && path === '/api/v2/restaurants-integrations-public-api/availability/stores') {
      const body = await readBody(req);
      const ids = Array.isArray(body) ? body : (body.stores ?? []);
      const result = {};
      for (const id of ids.length ? ids : STORES.map((s) => s.store_id)) {
        result[id] = id !== '900105815';
      }
      return json(res, 200, result);
    }

    const itemsMatch = path.match(/^\/restaurants\/menu\/v1\/stores\/(\d+)\/items$/);
    if (method === 'GET' && itemsMatch) {
      const storeId = itemsMatch[1];
      return json(res, 200, ITEMS_BY_STORE[storeId] ?? []);
    }

    const scheduleMatch = path.match(/^\/api\/rest-ops-utils\/store\/schedule\/(\d+)$/);
    if (method === 'GET' && scheduleMatch) {
      return json(res, 200, {
        storeId: scheduleMatch[1],
        schedules: [
          {
            days_of_week: 'mon,tue,wed,thu,fri,sat,sun',
            time_periods: [{ start_time: '11:00', end_time: '23:30' }],
          },
        ],
      });
    }

    const ordersMatch = path.match(/^\/restaurants\/orders\/v1\/stores\/(\d+)\/orders$/);
    if (method === 'GET' && ordersMatch) {
      return json(res, 200, [
        {
          order_id: 'mock-1',
          store_id: ordersMatch[1],
          status: 'READY',
          items: [{ sku: 'promo_makis_alas', name: 'Promo Makis + Alas', quantity: 1, price: 39.9 }],
        },
      ]);
    }

    const takeMatch = path.match(
      /^\/restaurants\/orders\/v1\/stores\/(\d+)\/orders\/([^/]+)(?:\/cooking_time\/(\d+))?\/take$/,
    );
    if (method === 'PUT' && takeMatch) {
      const cooking = takeMatch[3] ? Number(takeMatch[3]) : null;
      return json(res, 200, { message: 'Order taken', order_id: takeMatch[2], cooking_time: cooking });
    }

    if (method === 'POST' && path === '/_simulate/webhook') {
      const body = await readBody(req);
      const target = body.url ?? 'http://localhost:8788/webhooks/rappi';
      const result = await fireWebhook(target, body.event ?? 'NEW_ORDER', body.overrides ?? {});
      return json(res, 200, result);
    }

    return json(res, 404, { message: `No encontrado: ${method} ${path}` });
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? 8787);
  createApp().listen(port, () => {
    console.log(`mock-rappi escuchando en http://localhost:${port}`);
  });
}
