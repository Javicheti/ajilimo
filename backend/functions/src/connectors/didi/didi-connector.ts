import { requestJson } from '../../shared/http';
import type {
  Capability,
  MenuItem,
  Order,
  ScheduleWindow,
  StoreAvailability,
  StoreSummary,
} from '../common/types';
import type { ConnectorContext, DeliveryConnector } from '../common/delivery-connector';

export interface ClaimDecision {
  accept: boolean;
  note?: string;
}

/** Reclamo normalizado de DiDi. */
export interface DidiClaim {
  claimId: string;
  orderId: string;
  reason: string;
  amount: number;
  createdAt: string;
}

interface DidiClaimDto {
  claim_id?: string;
  order_id?: string;
  reason?: string;
  amount?: number;
  created_at?: string;
}

/** Interfaz opcional para canales que exponen gestión de reclamos (DiDi). */
export interface SupportsClaims {
  respondToClaim(orderId: string, decision: ClaimDecision): Promise<void>;
  getClaims(): Promise<DidiClaim[]>;
}

interface DidiStoreDto {
  shop_id?: string;
  id?: string;
  name?: string;
}
interface DidiOrderDto {
  order_id?: string;
  shop_id?: string;
  status?: string;
  items?: Array<{ sku?: string; name?: string; quantity?: number; price?: number }>;
}
interface DidiItemDto {
  sku?: string;
  name?: string;
  price?: number;
  available?: boolean;
}

/**
 * Conector de DiDi Food. Implementa el contrato común y la gestión de reclamos.
 * Probado contra `mocks/mock-didi`.
 */
export class DidiConnector implements DeliveryConnector, SupportsClaims {
  readonly provider = 'didi' as const;
  readonly capabilities: Capability[] = [
    'stores',
    'menu',
    'availability',
    'orders',
    'promos',
    'claims',
    'financial',
  ];

  constructor(private readonly context: ConnectorContext) {}

  private headers(): Record<string, string> {
    return this.context.accessToken ? { authorization: `Bearer ${this.context.accessToken}` } : {};
  }

  async listStores(): Promise<StoreSummary[]> {
    const data = await requestJson<{ stores?: DidiStoreDto[] }>({
      url: `${this.context.baseUrl}/v1/shop/list`,
      headers: this.headers(),
    });
    return (data.stores ?? []).map((store) => ({
      storeId: store.shop_id ?? store.id ?? '',
      name: store.name ?? '',
    }));
  }

  async getMenuItems(storeId: string): Promise<MenuItem[]> {
    const data = await requestJson<{ items?: DidiItemDto[] }>({
      url: `${this.context.baseUrl}/v1/menu/list?shop_id=${encodeURIComponent(storeId)}`,
      headers: this.headers(),
    });
    return (data.items ?? []).map((item) => ({
      id: item.sku ?? '',
      sku: item.sku ?? '',
      title: item.name ?? '',
      price: item.price ?? 0,
      available: item.available ?? true,
    }));
  }

  async getStoreSchedule(_storeId: string): Promise<ScheduleWindow[]> {
    return [];
  }

  async getAvailability(storeIds: string[]): Promise<StoreAvailability[]> {
    const data = await requestJson<{ statuses?: Record<string, boolean> }>({
      url: `${this.context.baseUrl}/v1/shop/status?shop_ids=${encodeURIComponent(storeIds.join(','))}`,
      headers: this.headers(),
    });
    return Object.entries(data.statuses ?? {}).map(([storeId, online]) => ({ storeId, online }));
  }

  async getOrders(storeId: string): Promise<Order[]> {
    const data = await requestJson<{ orders?: DidiOrderDto[] }>({
      url: `${this.context.baseUrl}/v1/order/list?shop_id=${encodeURIComponent(storeId)}`,
      headers: this.headers(),
    });
    return (data.orders ?? []).map((order) => ({
      orderId: order.order_id ?? '',
      storeId: order.shop_id ?? storeId,
      status: order.status ?? 'READY',
      items: (order.items ?? []).map((item) => ({
        sku: item.sku ?? '',
        name: item.name ?? '',
        quantity: item.quantity ?? 0,
        price: item.price ?? 0,
      })),
    }));
  }

  async takeOrder(storeId: string, orderId: string): Promise<void> {
    await requestJson<unknown>({
      url: `${this.context.baseUrl}/v1/order/confirm`,
      method: 'POST',
      headers: this.headers(),
      body: { shop_id: storeId, order_id: orderId },
    });
  }

  async respondToClaim(orderId: string, decision: ClaimDecision): Promise<void> {
    await requestJson<unknown>({
      url: `${this.context.baseUrl}/v1/order/apply/refund`,
      method: 'POST',
      headers: this.headers(),
      body: { order_id: orderId, accept: decision.accept, note: decision.note ?? '' },
    });
  }

  async getClaims(): Promise<DidiClaim[]> {
    const data = await requestJson<{ claims?: DidiClaimDto[] }>({
      url: `${this.context.baseUrl}/v1/order/claims`,
      headers: this.headers(),
    });
    return (data.claims ?? []).map((claim) => ({
      claimId: claim.claim_id ?? '',
      orderId: claim.order_id ?? '',
      reason: claim.reason ?? '',
      amount: claim.amount ?? 0,
      createdAt: claim.created_at ?? new Date().toISOString(),
    }));
  }
}
