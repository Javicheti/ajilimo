import { test } from 'node:test';
import assert from 'node:assert/strict';

import { isWithinSchedule } from './schedule';
import { resolveStoreStatus } from './store-status';
import { buildConnectivityAlerts } from '../jobs/connectivity';
import type { ScheduleWindow } from '../connectors/common/types';

const window: ScheduleWindow = {
  daysOfWeek: ['mon', 'tue', 'wed', 'thu', 'fri'],
  startTime: '11:00',
  endTime: '23:30',
};

test('isWithinSchedule: dentro y fuera del horario', () => {
  const mondayNoon = new Date(2026, 0, 5, 12, 0, 0);
  const mondayEarly = new Date(2026, 0, 5, 9, 0, 0);
  assert.equal(isWithinSchedule(mondayNoon, [window]), true);
  assert.equal(isWithinSchedule(mondayEarly, [window]), false);
});

test('isWithinSchedule: sin ventanas se asume disponible', () => {
  assert.equal(isWithinSchedule(new Date(), []), true);
});

test('isWithinSchedule: horario que cruza medianoche', () => {
  const overnight: ScheduleWindow = { daysOfWeek: ['mon'], startTime: '22:00', endTime: '02:00' };
  assert.equal(isWithinSchedule(new Date(2026, 0, 5, 23, 0, 0), [overnight]), true);
  assert.equal(isWithinSchedule(new Date(2026, 0, 5, 1, 0, 0), [overnight]), true);
  assert.equal(isWithinSchedule(new Date(2026, 0, 5, 12, 0, 0), [overnight]), false);
});

test('resolveStoreStatus: combina disponibilidad × horario × suspensión', () => {
  assert.equal(resolveStoreStatus({ online: true, withinSchedule: true }), 'open');
  assert.equal(resolveStoreStatus({ online: false, withinSchedule: true }), 'paused');
  assert.equal(resolveStoreStatus({ online: false, withinSchedule: false }), 'closed');
  assert.equal(
    resolveStoreStatus({ online: true, withinSchedule: true, suspended: true }),
    'suspended',
  );
});

test('buildConnectivityAlerts: solo genera alertas para tiendas no operativas', () => {
  const alerts = buildConnectivityAlerts([
    { storeId: '1', name: 'Abierta', online: true, withinSchedule: true },
    { storeId: '2', name: 'Pausada', online: false, withinSchedule: true },
    { storeId: '3', name: 'Cerrada', online: false, withinSchedule: false },
    { storeId: '4', name: 'Suspendida', online: true, withinSchedule: true, suspended: true },
  ]);

  assert.equal(alerts.length, 3);
  assert.equal(alerts.find((a) => a.storeId === '2')?.severity, 'critical');
  assert.equal(alerts.find((a) => a.storeId === '3')?.severity, 'warning');
  assert.ok(alerts.find((a) => a.storeId === '4')?.message.includes('suspendida'));
});
