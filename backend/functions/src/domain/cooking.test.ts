import { test } from 'node:test';
import assert from 'node:assert/strict';

import { evaluateCooking } from './cooking';

const start = new Date('2026-01-05T12:00:00Z');

test('cooking: en tiempo', () => {
  const result = evaluateCooking(start, new Date('2026-01-05T12:10:00Z'), 22);
  assert.equal(result.state, 'on_time');
  assert.equal(Math.round(result.elapsedMinutes), 10);
  assert.equal(Math.round(result.remainingMinutes), 12);
});

test('cooking: en riesgo (≥80% del objetivo)', () => {
  const result = evaluateCooking(start, new Date('2026-01-05T12:18:00Z'), 22);
  assert.equal(result.state, 'at_risk');
});

test('cooking: excedido', () => {
  const result = evaluateCooking(start, new Date('2026-01-05T12:25:00Z'), 22);
  assert.equal(result.state, 'overdue');
  assert.ok(result.remainingMinutes < 0);
});

test('cooking: nunca negativo en el tiempo transcurrido', () => {
  const result = evaluateCooking(new Date('2026-01-05T12:00:00Z'), new Date('2026-01-05T11:59:00Z'), 22);
  assert.equal(result.elapsedMinutes, 0);
});
