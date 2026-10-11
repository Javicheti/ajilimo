import { requestJson } from '../../shared/http';
import { AppError } from '../../shared/errors';
import type {
  Capability,
  MenuItem,
  Order,
  ScheduleWindow,
  StoreAvailability,
  StoreSummary,
} from '../common/types';
import type { ConnectorContext, DeliveryConnector } from '../common/delivery-connector';

interface PeYaVendorDto {
  id?: string;
  vendor_id?: string;
  name?: string;
}
interface PeYaProductDto {
  sku?: string;
  name?: string;
  price?: number;
  available?: boolean;
}
interface PeYaOrderDto {
  order_id?: string;
  vendor_id?: string;
  status?: string;
  items?: Array<{ sku?: string; name?: string; quantity?: number; price?: number }>;
}

/**
 * Conector de PedidosYa (Partner API / Delivery Hero). Requiere `chain_id` en el
 * contexto. Probado contra `mocks/mock-pedidosya`.
 */
export class PedidosYaConnector implements DeliveryConnector {
  readonly provider = 'pedidosya' as const;
  readonly capabilities: Capability[] = ['stores', 'menu', 'availability', 'orders', 'promos'];

  constructor(private readonly context: ConnectorContext) {}

  private headers(): Record<string, string> {
    return this.context.accessToken ? { authorization: `Bearer ${this.context.accessToken}` } : {};
  }

  private chainId(): string {
    if (!this.context.chainId) {
      throw new AppError('invalid_config', 'PedidosYa requiere chainId en el contexto');
    }
    return this.context.chainId;
  }

  async listStores(): Promise<StoreSummary[]> {
    const data = await requestJson<{ vendors?: PeYaVendorDto[] }>({
      url: `${this.context.baseUrl}/v2/chains/${this.chainId()}/vendors`,
      headers: this.headers(),
    });
    return (data.vendors ?? []).map((vendor) => ({
      storeId: vendor.id ?? vendor.vendor_id ?? '',
      name: vendor.name ?? '',
    }));
  }

  async getMenuItems(storeId: string): Promise<MenuItem[]> {
    const data = await requestJson<{ products?: PeYaProductDto[] }>({
      url: `${this.context.baseUrl}/v2/vendors/${storeId}/catalog`,
      headers: this.headers(),
    });
    return (data.products ?? []).map((product) => ({
      id: product.sku ?? '',
      sku: product.sku ?? '',
      title: product.name ?? '',
      price: product.price ?? 0,
      available: product.available ?? true,
    }));
  }

  async getStoreSchedule(_storeId: string): Promise<ScheduleWindow[]> {
    return [];
  }

  async getAvailability(storeIds: string[]): Promise<StoreAvailability[]> {
    const results: StoreAvailability[] = [];
    for (const storeId of storeIds) {
      const data = await requestJson<{ online?: boolean }>({
        url: `${this.context.baseUrl}/v2/vendors/${storeId}/status`,
        headers: this.headers(),
      });
      results.push({ storeId, online: data.online ?? false });
    }
    return results;
  }

  async getOrders(storeId: string): Promise<Order[]> {
    const data = await requestJson<{ orders?: PeYaOrderDto[] }>({
      url: `${this.context.baseUrl}/v2/chains/${this.chainId()}/orders?vendor_id=${encodeURIComponent(storeId)}`,
      headers: this.headers(),
    });
    return (data.orders ?? []).map((order) => ({
      orderId: order.order_id ?? '',
      storeId: order.vendor_id ?? storeId,
      status: order.status ?? 'NEW',
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
      url: `${this.context.baseUrl}/v2/chains/${this.chainId()}/orders/${orderId}`,
      method: 'PUT',
      headers: this.headers(),
      body: { vendor_id: storeId, status: 'ACCEPTED' },
    });
  }
}
