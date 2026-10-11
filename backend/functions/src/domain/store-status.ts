import type { StoreOnlineStatus } from '../connectors/common/types';

export interface StoreStatusInput {
  /** Disponibilidad según la API (online/offline). */
  online: boolean;
  /** Si el momento actual cae dentro del horario configurado. */
  withinSchedule: boolean;
  /** Suspensión por parte de la app (si se conoce). */
  suspended?: boolean;
}

/**
 * Resuelve el estado operativo cruzando disponibilidad × horario × suspensión:
 * - suspendido por la app → `suspended`
 * - online → `open`
 * - offline dentro de horario → `paused` (pausa manual / problema)
 * - offline fuera de horario → `closed`
 */
export function resolveStoreStatus(input: StoreStatusInput): StoreOnlineStatus {
  if (input.suspended) return 'suspended';
  if (input.online) return 'open';
  return input.withinSchedule ? 'paused' : 'closed';
}
