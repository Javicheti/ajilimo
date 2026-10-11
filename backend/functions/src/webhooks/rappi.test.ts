import { test } from 'node:test';
import assert from 'node:assert/strict';

import { parseRappiWebhook } from './rappi';
import { signRappiPayload } from '../security/signatures';
import { AppError } from '../shared/errors';

const SECRET = 'mocks-secret';

test('parsea STORE_CONNECTIVITY válido', () => {
  const raw = JSON.stringify({ external_store_id: '900105814', enabled: false, message: 'x' });
  const header = signRappiPayload(raw, SECRET, 1000);
  const event = parseRappiWebhook('STORE_CONNECTIVITY', header, raw, SECRET);
  assert.equal(event.type, 'STORE_CONNECTIVITY');
  assert.equal(event.storeId, '900105814');
  assert.equal(event.enabled, false);
});

test('parsea NEW_ORDER desde order_detail', () => {
  const raw = JSON.stringify({ order_detail: { order_id: 'A1', store_id: 'S1', items: [] } });
  const header = signRappiPayload(raw, SECRET, 1000);
  const event = parseRappiWebhook('NEW_ORDER', header, raw, SECRET);
  assert.equal(event.orderId, 'A1');
  assert.equal(event.storeId, 'S1');
});

test('firma inválida lanza AppError invalid_signature', () => {
  assert.throws(
    () => parseRappiWebhook('NEW_ORDER', 't=1,sign=deadbeef', '{}', SECRET),
    (error: unknown) => AppError.isAppError(error) && error.code === 'invalid_signature',
  );
});
