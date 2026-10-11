import type {
  Capability,
  ChannelProvider,
  MenuItem,
  Order,
  ScheduleWindow,
  StoreAvailability,
  StoreSummary,
  TakeOrderOptions,
} from './types';

/** Contexto resuelto para instanciar un conector. */
export interface ConnectorContext {
  baseUrl: string;
  accessToken?: string;
  /** Para canales con doble token (Rappi self-onboarding). */
  merchantToken?: string;
  /** Contenedor multi-local de algunos canales (PedidosYa chain_id). */
  chainId?: string;
}

/** Contrato común que implementa cada canal de delivery. */
export interface DeliveryConnector {
  readonly provider: ChannelProvider;
  readonly capabilities: Capability[];

  listStores(): Promise<StoreSummary[]>;
  getMenuItems(storeId: string): Promise<MenuItem[]>;
  getStoreSchedule(storeId: string): Promise<ScheduleWindow[]>;
  getAvailability(storeIds: string[]): Promise<StoreAvailability[]>;
  getOrders(storeId: string): Promise<Order[]>;
  takeOrder(storeId: string, orderId: string, options?: TakeOrderOptions): Promise<void>;
}
