import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn, type ChildProcess } from 'node:child_process';
import path from 'node:path';

import { DidiConnector } from './didi-connector';
import type { ConnectorContext } from '../common/delivery-connector';
import { createConnector } from '../common/factory';

const PORT = 8790;
let child: ChildProcess | undefined;
let baseUrl = '';

async function waitForHealth(url: string): Promise<void> {
  for (let i = 0; i < 80; i += 1) {
    try {
      const res = await fetch(`${url}/health`);
      if (res.ok) return;
    } catch {
      // aún no arranca
    }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
  throw new Error('mock-didi no arrancó a tiempo');
}

before(async () => {
  const mockPath = path.resolve(process.cwd(), '../../mocks/mock-didi/server.mjs');
  child = spawn(process.execPath, [mockPath], {
    env: { ...process.env, PORT: String(PORT) },
    stdio: 'ignore',
  });
  baseUrl = `http://localhost:${PORT}`;
  await waitForHealth(baseUrl);
});

after(() => child?.kill());

function context(): ConnectorContext {
  return { baseUrl, accessToken: 'mock-didi-token' };
}

test('listStores y getOrders de DiDi', async () => {
  const connector = new DidiConnector(context());
  const stores = await connector.listStores();
  assert.ok(stores.length >= 1);

  const orders = await connector.getOrders('didi-201');
  assert.equal(orders[0].orderId, 'D-3310');
  assert.ok(orders[0].items.length >= 1);
});

test('getAvailability y getMenuItems', async () => {
  const connector = new DidiConnector(context());
  const availability = await connector.getAvailability(['didi-201', 'didi-202']);
  const map = Object.fromEntries(availability.map((a) => [a.storeId, a.online]));
  assert.equal(map['didi-201'], true);
  assert.equal(map['didi-202'], false);

  const items = await connector.getMenuItems('didi-202');
  assert.equal(items[0].available, false);
});

test('respondToClaim acepta el reembolso', async () => {
  const connector = new DidiConnector(context());
  await connector.respondToClaim('D-3310', { accept: true, note: 'pedido incompleto' });
});

test('getClaims devuelve reclamos normalizados', async () => {
  const connector = new DidiConnector(context());
  const claims = await connector.getClaims();
  assert.ok(claims.length >= 1);
  assert.ok(claims[0].claimId);
  assert.ok(claims[0].createdAt);
});

test('la factory crea el conector de didi', () => {
  const connector = createConnector('didi', context());
  assert.equal(connector.provider, 'didi');
  assert.ok(connector.capabilities.includes('claims'));
});
