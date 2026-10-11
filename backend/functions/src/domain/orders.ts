import type { ChannelProvider, Order } from '../connectors/common/types';

export interface OrderRow {
  channel: ChannelProvider;
  storeId: string;
  storeName?: string;
  orderId: string;
  status: string;
  itemCount: number;
  total: number;
}

/** Normaliza órdenes de distintos canales a un formato común. */
export function buildOrderRows(
  entries: Array<{ channel: ChannelProvider; storeId: string; storeName?: string; order: Order }>,
): OrderRow[] {
  return entries.map(({ channel, storeId, storeName, order }) => {
    const itemCount = order.items.reduce((sum, item) => sum + item.quantity, 0);
    const total = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    return {
      channel,
      storeId: order.storeId || storeId,
      storeName,
      orderId: order.orderId,
      status: order.status,
      itemCount,
      total: Math.round(total * 100) / 100,
    };
  });
}
