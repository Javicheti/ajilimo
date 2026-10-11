import { test } from 'node:test';
import assert from 'node:assert/strict';

import { aggregateSales, groupBy, weekKey, type SalesOrder } from './reporting';

const orders: SalesOrder[] = [
  {
    orderId: '1',
    brand: 'PINWINGS',
    channel: 'rappi',
    storeId: 'S1',
    outcome: 'completed',
    paidAmount: 84.7,
    date: '2026-01-05',
    lines: [
      { category: 'alas', quantity: 8 },
      { category: 'gaseosa', quantity: 2 },
    ],
  },
  {
    orderId: '2',
    brand: 'PINWINGS',
    channel: 'rappi',
    storeId: 'S1',
    outcome: 'cancelled_paid',
    paidAmount: 30,
    date: '2026-01-05',
    lines: [{ category: 'alas', quantity: 4 }],
  },
  {
    orderId: '3',
    brand: 'Makis',
    channel: 'didi',
    storeId: 'S2',
    outcome: 'cancelled_unpaid',
    paidAmount: 0,
    date: '2026-01-06',
    lines: [{ category: 'makis', quantity: 10 }],
  },
];

test('aggregateSales agrupa por marca y cuenta alas/gaseosas', () => {
  const rows = aggregateSales(orders, groupBy.brand);
  const pinwings = rows.find((row) => row.key === 'PINWINGS')!;
  assert.equal(pinwings.completedOrders, 1);
  assert.equal(pinwings.cancelledPaidOrders, 1);
  assert.equal(pinwings.cancelledUnpaidOrders, 0);
  assert.equal(pinwings.paidAmount, 114.7);
  assert.equal(pinwings.wingUnits, 12);
  assert.equal(pinwings.sodaUnits, 2);

  const makis = rows.find((row) => row.key === 'Makis')!;
  assert.equal(makis.cancelledUnpaidOrders, 1);
  assert.equal(makis.wingUnits, 0);
});

test('aggregateSales por día separa fechas', () => {
  const rows = aggregateSales(orders, groupBy.day);
  assert.equal(rows.length, 2);
  const day5 = rows.find((row) => row.key === '2026-01-05')!;
  assert.equal(day5.completedOrders, 1);
  assert.equal(day5.cancelledPaidOrders, 1);
});

test('weekKey produce formato yyyy-Www', () => {
  assert.match(weekKey('2026-01-05'), /^2026-W\d{2}$/);
});
