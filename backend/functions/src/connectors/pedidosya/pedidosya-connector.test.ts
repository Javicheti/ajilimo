import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn, type ChildProcess } from 'node:child_process';
import path from 'node:path';

import { PedidosYaConnector } from './pedidosya-connector';
import type { ConnectorContext } from '../common/delivery-connector';
import { createConnector } from '../common/factory';

const PORT = 8791;
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
  throw new Error('mock-pedidosya no arrancó a tiempo');
}

before(async () => {
  const mockPath = path.resolve(process.cwd(), '../../mocks/mock-pedidosya/server.mjs');
  child = spawn(process.execPath, [mockPath], {
    env: { ...process.env, PORT: String(PORT) },
    stdio: 'ignore',
  });
  baseUrl = `http://localhost:${PORT}`;
  await waitForHealth(baseUrl);
});

after(() => child?.kill());

function context(): ConnectorContext {
  return { baseUrl, accessToken: 'mock-peya-token', chainId: 'CH-1' };
}

test('listStores, catálogo y disponibilidad', async () => {
  const connector = new PedidosYaConnector(context());
  const stores = await connector.listStores();
  assert.ok(stores.length >= 1);

  const items = await connector.getMenuItems('py-101');
  assert.equal(items[0].sku, 'alas_bbq');

  const availability = await connector.getAvailability(['py-101', 'py-102']);
  const map = Object.fromEntries(availability.map((a) => [a.storeId, a.online]));
  assert.equal(map['py-101'], true);
  assert.equal(map['py-102'], false);
});

test('getOrders y takeOrder', async () => {
  const connector = new PedidosYaConnector(context());
  const orders = await connector.getOrders('py-101');
  assert.equal(orders[0].orderId, 'PY-5001');
  await connector.takeOrder('py-101', 'PY-5001');
});

test('requiere chainId', async () => {
  const connector = new PedidosYaConnector({ baseUrl, accessToken: 'x' });
  await assert.rejects(() => connector.listStores());
});

test('la factory crea el conector de pedidosya', () => {
  const connector = createConnector('pedidosya', context());
  assert.equal(connector.provider, 'pedidosya');
});
