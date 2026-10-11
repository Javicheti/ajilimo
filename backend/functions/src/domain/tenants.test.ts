import { test } from 'node:test';
import assert from 'node:assert/strict';

import { buildTenant, slugify } from './tenants';
import { AppError } from '../shared/errors';

test('slugify normaliza acentos y espacios', () => {
  assert.equal(slugify('Ají Limo Perú'), 'aji-limo-peru');
  assert.equal(slugify('  PINWINGS 2026 '), 'pinwings-2026');
});

test('buildTenant deriva slug y namespace de secretos', () => {
  const { tenant, secretNamespace } = buildTenant('AjíLimo', 'dev');
  assert.equal(tenant.slug, 'ajilimo');
  assert.equal(tenant.environment, 'dev');
  assert.equal(secretNamespace, 'tenants/ajilimo');
});

test('buildTenant rechaza nombres vacíos', () => {
  assert.throws(
    () => buildTenant('   ', 'dev'),
    (error: unknown) => AppError.isAppError(error) && error.code === 'invalid_config',
  );
});
