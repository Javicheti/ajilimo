import { createServer } from 'node:http';
import { createHash } from 'node:crypto';

/**
 * Mock de DiDi Food — replica endpoints mínimos para probar el conector y los
 * reclamos, con firma MD5 (`MD5(rawBody + app_secret)`).
 * Sin dependencias. Arrancar: `node server.mjs` (puerto 8790).
 */

export const DIDI_WEBHOOK_SECRET = 'mock-didi-secret';

const STORES = [
  { shop_id: 'didi-201', name: 'PINWINGS — Miraflores' },
  { shop_id: 'didi-202', name: 'Makis — Centro' },
];

const MENU = {
  'didi-201': [
    { sku: 'alas_bbq', name: 'Alas BBQ (x8)', price: 24.9, available: true },
  ],
  'didi-202': [
    { sku: 'maki_california', name: 'Maki California (x10)', price: 29.9, available: false },
  ],
};

const STATUS = { 'didi-201': true, 'didi-202': false };

export function signDidi(payload, secret = DIDI_WEBHOOK_SECRET) {
  return createHash('md5').update(`${payload}${secret}`).digest('hex');
}

function json(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(body));
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

    if (path === '/health') return json(res, 200, { ok: true, service: 'mock-didi' });

    if (method === 'GET' && path === '/v1/auth/authtoken/get') {
      return json(res, 200, { auth_token: 'mock-didi-token', token_expiration_time: 3600 });
    }

    if (method === 'GET' && path === '/v1/shop/list') {
      return json(res, 200, { stores: STORES });
    }

    if (method === 'GET' && path === '/v1/menu/list') {
      const shopId = url.searchParams.get('shop_id') ?? '';
      return json(res, 200, { items: MENU[shopId] ?? [] });
    }

    if (method === 'GET' && path === '/v1/shop/status') {
      return json(res, 200, { statuses: STATUS });
    }

    if (method === 'GET' && path === '/v1/order/list') {
      const shopId = url.searchParams.get('shop_id') ?? 'didi-201';
      return json(res, 200, {
        orders: [
          {
            order_id: 'D-3310',
            shop_id: shopId,
            status: 'READY',
            items: [{ sku: 'alas_bbq', name: 'Alas BBQ (x8)', quantity: 2, price: 24.9 }],
          },
        ],
      });
    }

    if (method === 'GET' && path === '/v1/order/claims') {
      const now = Date.now();
      return json(res, 200, {
        claims: [
          { claim_id: 'C-1', order_id: 'D-3310', reason: 'quality', amount: 31.8, created_at: new Date(now - 2 * 3600e3).toISOString() },
          { claim_id: 'C-2', order_id: 'D-3305', reason: 'incomplete', amount: 45.0, created_at: new Date(now - 18 * 3600e3).toISOString() },
          { claim_id: 'C-3', order_id: 'D-3299', reason: 'insufficient', amount: 22.5, created_at: new Date(now - 21 * 3600e3).toISOString() },
        ],
      });
    }

    if (method === 'POST' && path === '/v1/order/confirm') {
      const body = await readBody(req);
      return json(res, 200, { ok: true, order_id: body.order_id });
    }

    if (method === 'POST' && path === '/v1/order/apply/refund') {
      const body = await readBody(req);
      return json(res, 200, { accepted: body.accept === true, order_id: body.order_id });
    }

    if (method === 'POST' && path === '/_simulate/webhook') {
      const body = await readBody(req);
      const payload = JSON.stringify(body.payload ?? { order_id: 'D-3310' });
      const signature = signDidi(payload);
      const target = body.url;
      if (target) {
        const result = await fetch(target, {
          method: 'POST',
          headers: { 'content-type': 'application/json', 'didi-header-sign': signature },
          body: payload,
        });
        return json(res, 200, { sent: true, status: result.status, signature });
      }
      return json(res, 200, { signature, payload });
    }

    return json(res, 404, { message: `No encontrado: ${method} ${path}` });
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? 8790);
  createApp().listen(port, () => console.log(`mock-didi escuchando en http://localhost:${port}`));
}
