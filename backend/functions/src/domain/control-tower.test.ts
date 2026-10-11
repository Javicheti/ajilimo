import { test } from 'node:test';
import assert from 'node:assert/strict';

import { buildControlTower } from './control-tower';
import { loadIntegrations, defaultTenantId } from '../config/runtime-config';

test('buildControlTower resuelve estados por tienda', () => {
  const rows = buildControlTower([
    { channel: 'rappi', storeId: 'S1', name: 'Abierta', online: true, withinSchedule: true },
    { channel: 'rappi', storeId: 'S2', name: 'Pausada', online: false, withinSchedule: true },
    { channel: 'didi', storeId: 'S3', name: 'Cerrada', online: false, withinSchedule: false },
    { channel: 'didi', storeId: 'S4', name: 'Suspendida', online: true, withinSchedule: true, suspended: true },
  ]);

  const statusOf = (id: string) => rows.find((row) => row.storeId === id)?.status;
  assert.equal(statusOf('S1'), 'open');
  assert.equal(statusOf('S2'), 'paused');
  assert.equal(statusOf('S3'), 'closed');
  assert.equal(statusOf('S4'), 'suspended');
  assert.equal(rows[0].channel, 'rappi');
});

test('loadIntegrations apunta a los mocks por defecto', () => {
  const previous = process.env.RAPPI_BASE_URL;
  delete process.env.RAPPI_BASE_URL;
  const integrations = loadIntegrations();
  const rappi = integrations.find((c) => c.provider === 'rappi');
  assert.ok(rappi);
  assert.equal(rappi?.baseUrl, 'http://localhost:8787');
  assert.equal(rappi?.environment, 'mock');
  assert.equal(rappi?.tenantId, defaultTenantId());
  if (previous) process.env.RAPPI_BASE_URL = previous;
});

test('loadIntegrations respeta overrides por entorno', () => {
  process.env.RAPPI_BASE_URL = 'https://api.dev.rappi.com';
  process.env.AJILIMO_ENV = 'dev';
  const rappi = loadIntegrations().find((c) => c.provider === 'rappi');
  assert.equal(rappi?.baseUrl, 'https://api.dev.rappi.com');
  assert.equal(rappi?.environment, 'dev');
  delete process.env.RAPPI_BASE_URL;
  delete process.env.AJILIMO_ENV;
});
