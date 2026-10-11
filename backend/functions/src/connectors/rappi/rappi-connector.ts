import { requestJson } from '../../shared/http';
import type {
  Capability,
  MenuItem,
  Order,
  OrderItem,
  ScheduleWindow,
  StoreAvailability,
  StoreSummary,
} from '../common/types';
import type { ConnectorContext, DeliveryConnector } from '../common/delivery-connector';

interface RappiStoreDto {
  store_id?: string;
  rappiId?: string;
  name?: string;
  brand?: string;
  integrated?: boolean;
}

interface RappiItemDto {
  id: number | string;
  sku: string;
  item_type?: string;
  title_info?: { title?: string };
  price_info?: { price?: number };
  suspension_info?: { is_available?: boolean; suspend_reason?: string | null };
  schedules_info?: { schedules?: Array<{ days_of_week?: string }> };
}

interface RappiScheduleDto {
  schedules?: Array<{
    days_of_week?: string;
    time_periods?: Array<{ start_time?: string; end_time?: string }>;
  }>;
}

interface RappiOrderDto {
  order_id: string;
  store_id?: string;
  status?: string;
  items?: Array<{ sku?: string; name?: string; quantity?: number; price?: number }>;
}

/**
 * Conector de Rappi. Implementa el contrato [DeliveryConnector] sobre la API
 * documentada (RESTs API + Public API). Probado contra `mocks/mock-rappi`.
 */
export class RappiConnector implements DeliveryConnector {
  readonly provider = 'rappi' as const;
  readonly capabilities: Capability[] = [
    'stores',
    'menu',
    'availability',
    'orders',
    'promos',
    'financial',
  ];

  constructor(private readonly context: ConnectorContext) {}

  private authHeaders(): Record<string, string> {
    const headers: Record<string, string> = {};
    if (this.context.accessToken) headers['x-authorization'] = `Bearer ${this.context.accessToken}`;
    if (this.context.merchantToken) {
      headers['Authorization-Partners'] = `Bearer ${this.context.merchantToken}`;
    }
    return headers;
  }

  async listStores(): Promise<StoreSummary[]> {
    const response = await requestJson<{ stores?: RappiStoreDto[] }>({
      url: `${this.context.baseUrl}/api/v2/restaurants-integrations-public-api/stores-pa`,
      headers: this.authHeaders(),
    });
    return (response.stores ?? []).map((store) => ({
      storeId: store.store_id ?? store.rappiId ?? '',
      name: store.name ?? '',
      brand: store.brand,
      integrated: store.integrated,
    }));
  }

  async getMenuItems(storeId: string): Promise<MenuItem[]> {
    const items = await requestJson<RappiItemDto[]>({
      url: `${this.context.baseUrl}/restaurants/menu/v1/stores/${storeId}/items`,
      headers: this.authHeaders(),
    });
    return items
      .filter((item) => (item.item_type ?? 'ITEM') === 'ITEM')
      .map((item) => ({
        id: String(item.id),
        sku: item.sku,
        title: item.title_info?.title ?? '',
        price: item.price_info?.price ?? 0,
        available: item.suspension_info?.is_available ?? true,
        suspendReason: item.suspension_info?.suspend_reason ?? null,
        daysOfWeek: item.schedules_info?.schedules?.flatMap(
          (schedule) => schedule.days_of_week?.split(',') ?? [],
        ),
      }));
  }

  async getStoreSchedule(storeId: string): Promise<ScheduleWindow[]> {
    const data = await requestJson<RappiScheduleDto>({
      url: `${this.context.baseUrl}/api/rest-ops-utils/store/schedule/${storeId}`,
      headers: this.authHeaders(),
    });
    return (data.schedules ?? []).flatMap((schedule) =>
      (schedule.time_periods ?? []).map((period) => ({
        daysOfWeek: (schedule.days_of_week ?? '').split(',').filter(Boolean),
        startTime: period.start_time ?? '00:00',
        endTime: period.end_time ?? '23:59',
      })),
    );
  }

  async getAvailability(storeIds: string[]): Promise<StoreAvailability[]> {
    const result = await requestJson<Record<string, boolean>>({
      url: `${this.context.baseUrl}/api/v2/restaurants-integrations-public-api/availability/stores`,
      method: 'POST',
      headers: this.authHeaders(),
      body: storeIds,
    });
    return Object.entries(result).map(([storeId, online]) => ({ storeId, online }));
  }

  async getOrders(storeId: string): Promise<Order[]> {
    const orders = await requestJson<RappiOrderDto[]>({
      url: `${this.context.baseUrl}/restaurants/orders/v1/stores/${storeId}/orders`,
      headers: this.authHeaders(),
    });
    return orders.map((order) => ({
      orderId: order.order_id,
      storeId: order.store_id ?? storeId,
      status: order.status ?? 'READY',
      items: (order.items ?? []).map<OrderItem>((item) => ({
        sku: item.sku ?? '',
        name: item.name ?? '',
        quantity: item.quantity ?? 0,
        price: item.price ?? 0,
      })),
    }));
  }

  async takeOrder(storeId: string, orderId: string, options?: { cookingTimeMinutes?: number }): Promise<void> {
    const cooking = options?.cookingTimeMinutes;
    const suffix = cooking !== undefined ? `/cooking_time/${cooking}/take` : '/take';
    await requestJson<unknown>({
      url: `${this.context.baseUrl}/restaurants/orders/v1/stores/${storeId}/orders/${orderId}${suffix}`,
      method: 'PUT',
      headers: this.authHeaders(),
    });
  }
}
