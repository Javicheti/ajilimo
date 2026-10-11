import { createServer } from 'node:http';

/**
 * Mock de PedidosYa (Partner API / Delivery Hero). Sin dependencias.
 * Arrancar: `node server.mjs` (puerto 8791).
 */

const VENDORS = [
  { id: 'py-101', name: 'PINWINGS — San Isidro' },
  { id: 'py-102', name: 'Makis — Miraflores' },
];

const CATALOG = {
  'py-101': [{ sku: 'alas_bbq', name: 'Alas BBQ (x8)', price: 24.9, available: true }],
  'py-102': [{ sku: 'maki_california', name: 'Maki California (x10)', price: 29.9, available: true }],
};

const STATUS = { 'py-101': { online: true }, 'py-102': { online: false } };

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

    if (path === '/health') return json(res, 200, { ok: true, service: 'mock-pedidosya' });

    if (method === 'POST' && path === '/v2/oauth/token') {
      await readBody(req);
      return json(res, 200, { access_token: 'mock-peya-token', token_type: 'Bearer', expires_in: 7200 });
    }

    if (method === 'GET' && /^\/v2\/chains\/[^/]+\/vendors$/.test(path)) {
      return json(res, 200, { vendors: VENDORS });
    }

    if (method === 'GET' && /^\/v2\/vendors\/[^/]+\/catalog$/.test(path)) {
      const vendorId = path.split('/')[3];
      return json(res, 200, { products: CATALOG[vendorId] ?? [] });
    }

    if (method === 'GET' && /^\/v2\/vendors\/[^/]+\/status$/.test(path)) {
      const vendorId = path.split('/')[3];
      return json(res, 200, STATUS[vendorId] ?? { online: false });
    }

    if (method === 'GET' && /^\/v2\/chains\/[^/]+\/orders$/.test(path)) {
      const vendorId = url.searchParams.get('vendor_id') ?? 'py-101';
      return json(res, 200, {
        orders: [
          {
            order_id: 'PY-5001',
            vendor_id: vendorId,
            status: 'NEW',
            items: [{ sku: 'alas_bbq', name: 'Alas BBQ (x8)', quantity: 1, price: 24.9 }],
          },
        ],
      });
    }

    if (method === 'PUT' && /^\/v2\/chains\/[^/]+\/orders\/[^/]+$/.test(path)) {
      const body = await readBody(req);
      return json(res, 200, { ok: true, status: body.status ?? 'ACCEPTED' });
    }

    return json(res, 404, { message: `No encontrado: ${method} ${path}` });
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? 8791);
  createApp().listen(port, () => console.log(`mock-pedidosya escuchando en http://localhost:${port}`));
}
