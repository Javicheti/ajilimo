import { createServer } from 'node:http';
import assert from 'node:assert/strict';
import { test, before, after } from 'node:test';
import { createHmac } from 'node:crypto';

import { createApp, fireWebhook, signPayload, WEBHOOK_SECRET } from './server.mjs';

let baseUrl;
let server;

before(async () => {
  server = createApp();
  await new Promise((resolve) => server.listen(0, resolve));
  baseUrl = `http://localhost:${server.address().port}`;
});

after(() => server.close());

test('health responde ok', async () => {
  const res = await fetch(`${baseUrl}/health`);
  const body = await res.json();
  assert.equal(res.status, 200);
  assert.equal(body.ok, true);
});

test('lista de tiendas', async () => {
  const res = await fetch(`${baseUrl}/api/v2/restaurants-integrations-public-api/stores-pa`);
  const body = await res.json();
  assert.ok(Array.isArray(body.stores));
  assert.ok(body.stores.some((s) => s.brand === 'PINWINGS'));
});

test('items incluyen suspension_info', async () => {
  const res = await fetch(`${baseUrl}/restaurants/menu/v1/stores/900105814/items`);
  const body = await res.json();
  assert.ok(body.length > 0);
  assert.ok(body[0].suspension_info.hasOwnProperty('is_available'));
});

test('disponibilidad devuelve booleano por tienda', async () => {
  const res = await fetch(`${baseUrl}/api/v2/restaurants-integrations-public-api/availability/stores`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(['900105814', '900105815']),
  });
  const body = await res.json();
  assert.equal(body['900105814'], true);
  assert.equal(body['900105815'], false);
});

test('webhook llega firmado y la firma es verificable', async () => {
  let received = null;
  const receiver = createServer((req, res) => {
    let raw = '';
    req.on('data', (c) => (raw += c));
    req.on('end', () => {
      received = { raw, signature: req.headers['rappi-signature'] };
      res.writeHead(200);
      res.end('OK');
    });
  });
  await new Promise((resolve) => receiver.listen(0, resolve));
  const target = `http://localhost:${receiver.address().port}/webhooks/rappi`;

  const result = await fireWebhook(target, 'STORE_CONNECTIVITY', { store_id: '900105814', enabled: false });
  assert.equal(result.status, 200);
  assert.ok(received);

  const [tPart, signPart] = received.signature.split(',');
  const t = tPart.replace('t=', '');
  const expected = createHmac('sha256', WEBHOOK_SECRET).update(`${t}.${received.raw}`).digest('hex');
  assert.equal(signPart, `sign=${expected}`);

  receiver.close();
});

test('signPayload es determinista para mismo timestamp', () => {
  const a = signPayload('{"x":1}', 'secret', 1000);
  const b = signPayload('{"x":1}', 'secret', 1000);
  assert.equal(a, b);
  assert.match(a, /^t=1000,sign=[0-9a-f]{64}$/);
});
