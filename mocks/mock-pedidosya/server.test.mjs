import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';

import { createApp } from './server.mjs';

let server;
let baseUrl;

before(async () => {
  server = createApp();
  await new Promise((resolve) => server.listen(0, resolve));
  baseUrl = `http://localhost:${server.address().port}`;
});

after(() => server.close());

test('health y token', async () => {
  assert.equal((await (await fetch(`${baseUrl}/health`)).json()).ok, true);
  const token = await (
    await fetch(`${baseUrl}/v2/oauth/token`, { method: 'POST', body: 'grant_type=client_credentials' })
  ).json();
  assert.equal(token.access_token, 'mock-peya-token');
});

test('vendors, catalog y status', async () => {
  const vendors = await (await fetch(`${baseUrl}/v2/chains/CH/vendors`)).json();
  assert.ok(vendors.vendors.length >= 1);
  const catalog = await (await fetch(`${baseUrl}/v2/vendors/py-101/catalog`)).json();
  assert.ok(catalog.products.length >= 1);
  const status = await (await fetch(`${baseUrl}/v2/vendors/py-102/status`)).json();
  assert.equal(status.online, false);
});
