import { test } from 'node:test';
import assert from 'node:assert/strict';

import { InMemorySecretService, secretRef } from './secret-service';
import { InMemoryTenantResolver } from './tenant-resolver';
import type { IntegrationConfig } from './types';

test('secretRef construye la ruta estándar', () => {
  assert.equal(secretRef('t1', 'rappi', 'mock', 'oauth'), 'tenants/t1/rappi/mock/oauth');
  assert.equal(secretRef('t1', 'rappi', 'dev', 'webhook'), 'tenants/t1/rappi/dev/webhook');
});

test('InMemorySecretService guarda y lee; nunca expone si no existe', async () => {
  const ref = secretRef('t1', 'rappi', 'mock', 'oauth');
  const service = new InMemorySecretService();
  assert.equal(await service.get(ref), null);
  await service.put(ref, 'clientId:secret');
  assert.equal(await service.get(ref), 'clientId:secret');
});

test('InMemoryTenantResolver resuelve configuración por tenant y proveedor', async () => {
  const config: IntegrationConfig = {
    tenantId: 't1',
    provider: 'rappi',
    environment: 'mock',
    baseUrl: 'http://localhost:8799',
    credentialsRef: secretRef('t1', 'rappi', 'mock', 'oauth'),
    capabilities: ['stores', 'menu'],
    status: 'connected',
  };
  const resolver = new InMemoryTenantResolver([config]);
  assert.equal((await resolver.resolveIntegration('t1', 'rappi'))?.baseUrl, 'http://localhost:8799');
  assert.equal(await resolver.resolveIntegration('t1', 'didi'), undefined);
  assert.equal((await resolver.listIntegrations('t1')).length, 1);
});
