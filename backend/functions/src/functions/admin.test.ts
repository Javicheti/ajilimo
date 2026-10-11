import { test } from 'node:test';
import assert from 'node:assert/strict';

import { isValidRole, VALID_ROLES } from './admin';

test('isValidRole acepta roles válidos y rechaza otros', () => {
  assert.equal(isValidRole('owner'), true);
  assert.equal(isValidRole('viewer'), true);
  assert.equal(isValidRole('root'), false);
  assert.equal(isValidRole(undefined), false);
  assert.equal(isValidRole(42), false);
});

test('VALID_ROLES incluye los 6 roles esperados', () => {
  assert.deepEqual([...VALID_ROLES], [
    'owner',
    'superadmin',
    'admin',
    'supervisor',
    'operator',
    'viewer',
  ]);
});
