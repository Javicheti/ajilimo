import { test } from 'node:test';
import assert from 'node:assert/strict';

import { evidencePath, validateEvidence } from './evidence';

test('evidencia válida con pedido, checklist y foto', () => {
  const result = validateEvidence({ orderId: 'R-4821', checklistComplete: true, hasPhoto: true });
  assert.equal(result.valid, true);
  assert.equal(result.issues.length, 0);
});

test('evidencia inválida acumula todos los problemas', () => {
  const result = validateEvidence({ orderId: '', checklistComplete: false, hasPhoto: false });
  assert.equal(result.valid, false);
  assert.equal(result.issues.length, 3);
  assert.ok(result.issues.some((issue) => issue.includes('foto')));
});

test('evidencePath genera la ruta por tenant y pedido', () => {
  assert.equal(evidencePath('t1', 'R-4821'), 'tenants/t1/evidence/R-4821/evidence.jpg');
});
