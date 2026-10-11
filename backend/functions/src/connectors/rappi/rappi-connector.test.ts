import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn, type ChildProcess } from 'node:child_process';
import path from 'node:path';

import { RappiConnector } from './rappi-connector';
import type { ConnectorContext } from '../common/delivery-connector';
import { createConnector } from '../common/factory';

const PORT = 8799;
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
  throw new Error('mock-rappi no arrancó a tiempo');
}

before(async () => {
  const mockPath = path.resolve(process.cwd(), '../../mocks/mock-rappi/server.mjs');
  child = spawn(process.execPath, [mockPath], {
    env: { ...process.env, PORT: String(PORT) },
    stdio: 'ignore',
  });
  baseUrl = `http://localhost:${PORT}`;
  await waitForHealth(baseUrl);
});

after(() => {
  child?.kill();
});

function context(): ConnectorContext {
  return { baseUrl, accessToken: 'mock-token' };
}

test('listStores devuelve tiendas normalizadas', async () => {
  const stores = await new RappiConnector(context()).listStores();
  assert.ok(stores.length >= 1);
  assert.ok(stores.some((s) => s.brand === 'PINWINGS'));
});

test('getMenuItems incluye disponibilidad y horarios', async () => {
  const items = await new RappiConnector(context()).getMenuItems('900105814');
  assert.ok(items.length >= 3);
  assert.ok(items.some((item) => !item.available));
  assert.ok(items.every((item) => Array.isArray(item.daysOfWeek)));
});

test('getStoreSchedule devuelve ventanas de horario', async () => {
  const windows = await new RappiConnector(context()).getStoreSchedule('900105814');
  assert.ok(windows.length >= 1);
  assert.ok(windows[0].daysOfWeek.includes('mon'));
  assert.equal(windows[0].startTime, '11:00');
});

test('getAvailability devuelve online/offline por tienda', async () => {
  const availability = await new RappiConnector(context()).getAvailability(['900105814', '900105815']);
  const map = Object.fromEntries(availability.map((a) => [a.storeId, a.online]));
  assert.equal(map['900105814'], true);
  assert.equal(map['900105815'], false);
});

test('getOrders y takeOrder con cooking time', async () => {
  const connector = new RappiConnector(context());
  const orders = await connector.getOrders('900105814');
  assert.ok(orders.length >= 1);
  assert.ok(orders[0].items.length >= 1);
  await connector.takeOrder('900105814', orders[0].orderId, { cookingTimeMinutes: 22 });
});

test('la factory crea el conector de rappi', () => {
  const connector = createConnector('rappi', context());
  assert.equal(connector.provider, 'rappi');
  assert.ok(connector.capabilities.includes('orders'));
});
