import type { ChannelProvider, StoreOnlineStatus } from '../connectors/common/types';
import { resolveStoreStatus, type StoreStatusInput } from './store-status';

export interface ChannelStoreInput extends StoreStatusInput {
  channel: ChannelProvider;
  storeId: string;
  name: string;
  brand?: string;
}

export interface ControlTowerRow {
  channel: ChannelProvider;
  storeId: string;
  name: string;
  brand?: string;
  status: StoreOnlineStatus;
}

/** Construye las filas de la torre de control a partir de las señales por tienda. */
export function buildControlTower(inputs: ChannelStoreInput[]): ControlTowerRow[] {
  return inputs.map((input) => ({
    channel: input.channel,
    storeId: input.storeId,
    name: input.name,
    brand: input.brand,
    status: resolveStoreStatus(input),
  }));
}
