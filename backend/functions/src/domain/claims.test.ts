import { test } from 'node:test';
import assert from 'node:assert/strict';

import { evaluateClaimDeadline } from './claims';

const created = new Date('2026-01-05T12:00:00Z');

test('reclamo holgado (ok)', () => {
  const result = evaluateClaimDeadline(created, new Date('2026-01-05T13:00:00Z'));
  assert.equal(result.urgency, 'ok');
  assert.equal(Math.round(result.hoursLeft), 23);
});

test('reclamo en advertencia (<=8 h restantes)', () => {
  const result = evaluateClaimDeadline(created, new Date('2026-01-06T06:00:00Z'));
  assert.equal(result.urgency, 'warning');
  assert.equal(Math.round(result.hoursLeft), 6);
});

test('reclamo crítico (<=4 h restantes)', () => {
  const result = evaluateClaimDeadline(created, new Date('2026-01-06T09:00:00Z'));
  assert.equal(result.urgency, 'critical');
});

test('reclamo expirado (24 h)', () => {
  const result = evaluateClaimDeadline(created, new Date('2026-01-06T13:00:00Z'));
  assert.equal(result.urgency, 'expired');
  assert.ok(result.hoursLeft < 0);
});
