import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';

import { createApp, signDidi, DIDI_WEBHOOK_SECRET } from './server.mjs';

let server;
let baseUrl;

before(async () => {
  server = createApp();
  await new Promise((resolve) => server.listen(0, resolve));
  baseUrl = `http://localhost:${server.address().port}`;
});

after(() => server.close());

test('health', async () => {
  const res = await fetch(`${baseUrl}/health`);
  assert.equal((await res.json()).ok, true);
});

test('lista de tiendas y órdenes', async () => {
  const stores = await (await fetch(`${baseUrl}/v1/shop/list`)).json();
  assert.ok(stores.stores.length >= 1);
  const orders = await (await fetch(`${baseUrl}/v1/order/list?shop_id=didi-201`)).json();
  assert.equal(orders.orders[0].order_id, 'D-3310');
});

test('responder reclamo devuelve accepted', async () => {
  const res = await fetch(`${baseUrl}/v1/order/apply/refund`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ order_id: 'D-3310', accept: true }),
  });
  const body = await res.json();
  assert.equal(body.accepted, true);
});

test('lista de reclamos', async () => {
  const data = await (await fetch(`${baseUrl}/v1/order/claims`)).json();
  assert.ok(data.claims.length >= 1);
  assert.equal(data.claims[0].claim_id, 'C-1');
});

test('firma MD5 = MD5(payload + secret)', () => {
  const payload = '{"order_id":"D-3310"}';
  const expected = createHash('md5').update(`${payload}${DIDI_WEBHOOK_SECRET}`).digest('hex');
  assert.equal(signDidi(payload), expected);
});
