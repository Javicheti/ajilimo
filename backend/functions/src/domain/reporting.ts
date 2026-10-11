export type OrderOutcome = 'completed' | 'cancelled_paid' | 'cancelled_unpaid';

export type ProductCategory = 'makis' | 'alas' | 'gaseosa' | 'otro';

export interface SalesLine {
  category: ProductCategory;
  quantity: number;
}

export interface SalesOrder {
  orderId: string;
  brand: string;
  channel: string;
  storeId: string;
  outcome: OrderOutcome;
  paidAmount: number;
  /** Fecha local en formato `yyyy-mm-dd`. */
  date: string;
  lines: SalesLine[];
}

export interface SalesReportRow {
  key: string;
  completedOrders: number;
  cancelledPaidOrders: number;
  cancelledUnpaidOrders: number;
  paidAmount: number;
  wingUnits: number;
  sodaUnits: number;
}

export type GroupKeyFn = (order: SalesOrder) => string;

/**
 * Agrega órdenes en un reporte de ventas por una dimensión dada.
 * Incluye culminados, cancelados (pagados y no pagados), monto pagado y
 * unidades de alas y gaseosas (para PINWINGS y promos de makis).
 */
export function aggregateSales(orders: SalesOrder[], groupBy: GroupKeyFn): SalesReportRow[] {
  const rows = new Map<string, SalesReportRow>();

  for (const order of orders) {
    const key = groupBy(order);
    const row =
      rows.get(key) ??
      (rows
        .set(key, {
          key,
          completedOrders: 0,
          cancelledPaidOrders: 0,
          cancelledUnpaidOrders: 0,
          paidAmount: 0,
          wingUnits: 0,
          sodaUnits: 0,
        })
        .get(key) as SalesReportRow);

    if (order.outcome === 'completed') row.completedOrders += 1;
    if (order.outcome === 'cancelled_paid') row.cancelledPaidOrders += 1;
    if (order.outcome === 'cancelled_unpaid') row.cancelledUnpaidOrders += 1;

    row.paidAmount += order.paidAmount;

    for (const line of order.lines) {
      if (line.category === 'alas') row.wingUnits += line.quantity;
      if (line.category === 'gaseosa') row.sodaUnits += line.quantity;
    }
  }

  return [...rows.values()];
}

export const groupBy = {
  brand: (order: SalesOrder): string => order.brand,
  channel: (order: SalesOrder): string => order.channel,
  store: (order: SalesOrder): string => order.storeId,
  day: (order: SalesOrder): string => order.date,
  month: (order: SalesOrder): string => order.date.slice(0, 7),
  week: (order: SalesOrder): string => weekKey(order.date),
  product: (order: SalesOrder): string =>
    [...new Set(order.lines.map((line) => line.category))].sort().join('+') || 'sin-items',
};

/** Clave de semana ISO aproximada: `yyyy-Www`. */
export function weekKey(date: string): string {
  const [year, month, day] = date.split('-').map((part) => Number.parseInt(part, 10));
  const current = new Date(Date.UTC(year, (month ?? 1) - 1, day ?? 1));
  const start = new Date(Date.UTC(current.getUTCFullYear(), 0, 1));
  const days = Math.floor((current.getTime() - start.getTime()) / 86_400_000);
  const week = Math.floor(days / 7) + 1;
  return `${current.getUTCFullYear()}-W${String(week).padStart(2, '0')}`;
}
