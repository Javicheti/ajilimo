import { test } from 'node:test';
import assert from 'node:assert/strict';

import { evaluatePromos } from './promos';

const items = [
  { sku: 'promo_makis_alas', title: 'Promo Makis + Alas', available: true, price: 39.9 },
  { sku: 'alas_bbq', title: 'Alas BBQ', available: false, price: 24.9 },
  { sku: 'gaseosa_500', title: 'Gaseosa 500ml', available: true, price: 9.9 },
];

test('promo sin problemas no genera incidencias', () => {
  const issues = evaluatePromos(items, [
    { sku: 'promo_makis_alas', title: 'Promo Makis + Alas', shouldBeOn: true, promoPrice: 39.9 },
  ]);
  assert.equal(issues.length, 0);
});

test('detecta promo apagada/suspendida', () => {
  const issues = evaluatePromos(items, [
    { sku: 'alas_bbq', title: 'Alas BBQ', shouldBeOn: true },
  ]);
  assert.equal(issues.length, 1);
  assert.equal(issues[0].kind, 'off');
});

test('detecta venta a precio full', () => {
  const issues = evaluatePromos(items, [
    { sku: 'gaseosa_500', title: 'Gaseosa 500ml', shouldBeOn: true, promoPrice: 6.9 },
  ]);
  assert.equal(issues.length, 1);
  assert.equal(issues[0].kind, 'full_price');
  assert.ok(issues[0].message.includes('precio full'));
});

test('ignora expectativas de ítems inexistentes', () => {
  const issues = evaluatePromos(items, [
    { sku: 'no_existe', title: 'X', shouldBeOn: true },
  ]);
  assert.equal(issues.length, 0);
});
