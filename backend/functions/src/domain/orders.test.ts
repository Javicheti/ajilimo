import { test } from 'node:test';
import assert from 'node:assert/strict';

import { buildOrderRows } from './orders';

test('buildOrderRows calcula ítems y total', () => {
  const rows = buildOrderRows([
    {
      channel: 'rappi',
      storeId: 'S1',
      order: {
        orderId: 'O-1',
        storeId: 'S1',
        status: 'READY',
        items: [
          { sku: 'a', name: 'A', quantity: 2, price: 10.5 },
          { sku: 'b', name: 'B', quantity: 1, price: 5 },
        ],
      },
    },
  ]);

  assert.equal(rows.length, 1);
  assert.equal(rows[0].itemCount, 3);
  assert.equal(rows[0].total, 26);
  assert.equal(rows[0].channel, 'rappi');
});
