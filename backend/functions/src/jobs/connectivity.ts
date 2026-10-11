import type { StoreOnlineStatus } from '../connectors/common/types';
import { resolveStoreStatus } from '../domain/store-status';

export interface StoreConnectivityInput {
  storeId: string;
  name: string;
  online: boolean;
  withinSchedule: boolean;
  suspended?: boolean;
}

export interface ConnectivityAlert {
  storeId: string;
  name: string;
  status: StoreOnlineStatus;
  severity: 'warning' | 'critical';
  message: string;
}

/** Genera alertas para las tiendas que no están `open`. */
export function buildConnectivityAlerts(items: StoreConnectivityInput[]): ConnectivityAlert[] {
  const alerts: ConnectivityAlert[] = [];
  for (const item of items) {
    const status = resolveStoreStatus(item);
    if (status === 'open') continue;
    alerts.push({
      storeId: item.storeId,
      name: item.name,
      status,
      severity: status === 'closed' ? 'warning' : 'critical',
      message: `${item.name}: ${label(status)}`,
    });
  }
  return alerts;
}

function label(status: StoreOnlineStatus): string {
  switch (status) {
    case 'suspended':
      return 'suspendida por la app';
    case 'paused':
      return 'pausada en horario de operación';
    case 'closed':
      return 'cerrada (fuera de horario)';
    default:
      return 'en operación';
  }
}
