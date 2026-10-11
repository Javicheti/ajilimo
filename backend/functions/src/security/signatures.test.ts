import { test } from 'node:test';
import assert from 'node:assert/strict';

import { signRappiPayload, verifyRappiSignature, signDidiPayload, verifyDidiSignature } from './signatures';

test('una firma válida verifica', () => {
  const payload = JSON.stringify({ a: 1 });
  const header = signRappiPayload(payload, 'secret', 1000);
  assert.equal(verifyRappiSignature(header, payload, 'secret'), true);
});

test('un payload alterado no verifica', () => {
  const header = signRappiPayload('{"a":1}', 'secret', 1000);
  assert.equal(verifyRappiSignature(header, '{"a":2}', 'secret'), false);
});

test('un secreto incorrecto no verifica', () => {
  const header = signRappiPayload('{"a":1}', 'secret', 1000);
  assert.equal(verifyRappiSignature(header, '{"a":1}', 'otro-secreto'), false);
});

test('header ausente o mal formado no verifica', () => {
  assert.equal(verifyRappiSignature(undefined, 'x', 'secret'), false);
  assert.equal(verifyRappiSignature('basura', 'x', 'secret'), false);
  assert.equal(verifyRappiSignature('t=1', 'x', 'secret'), false);
});

test('DiDi: firma MD5 válida verifica', () => {
  const payload = JSON.stringify({ order_id: 'D-1' });
  const header = signDidiPayload(payload, 'didi-secret');
  assert.equal(verifyDidiSignature(header, payload, 'didi-secret'), true);
  assert.equal(verifyDidiSignature(header, payload, 'otro'), false);
  assert.equal(verifyDidiSignature(undefined, payload, 'didi-secret'), false);
});
