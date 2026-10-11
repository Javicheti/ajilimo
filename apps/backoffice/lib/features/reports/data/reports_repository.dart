import '../domain/sales.dart';

/// Repositorio de ventas. Fase 5: datos semilla (mock); en producción vendrá de
/// BigQuery (ingesta de órdenes + Financial API).
class ReportsRepository {
  List<SalesOrder> seed() => <SalesOrder>[
        SalesOrder(
          orderId: 'R-4821',
          brand: 'PINWINGS',
          channel: 'Rappi',
          storeId: 'Surco',
          outcome: OrderOutcome.completed,
          paidAmount: 84.70,
          date: DateTime(2026, 1, 5),
          lines: const <SalesLine>[
            SalesLine(category: ProductCategory.alas, quantity: 8),
            SalesLine(category: ProductCategory.gaseosa, quantity: 2),
          ],
        ),
        SalesOrder(
          orderId: 'R-4799',
          brand: 'Makis',
          channel: 'Rappi',
          storeId: 'Centro',
          outcome: OrderOutcome.completed,
          paidAmount: 59.80,
          date: DateTime(2026, 1, 5),
          lines: const <SalesLine>[
            SalesLine(category: ProductCategory.makis, quantity: 20),
            SalesLine(category: ProductCategory.gaseosa, quantity: 1),
          ],
        ),
        SalesOrder(
          orderId: 'R-4780',
          brand: 'PINWINGS',
          channel: 'Rappi',
          storeId: 'Surco',
          outcome: OrderOutcome.cancelledPaid,
          paidAmount: 30.00,
          date: DateTime(2026, 1, 5),
          lines: const <SalesLine>[SalesLine(category: ProductCategory.alas, quantity: 4)],
        ),
        SalesOrder(
          orderId: 'D-3310',
          brand: 'PINWINGS',
          channel: 'DiDi',
          storeId: 'Miraflores',
          outcome: OrderOutcome.completed,
          paidAmount: 31.80,
          date: DateTime(2026, 1, 6),
          lines: const <SalesLine>[
            SalesLine(category: ProductCategory.alas, quantity: 8),
            SalesLine(category: ProductCategory.gaseosa, quantity: 1),
          ],
        ),
        SalesOrder(
          orderId: 'D-3305',
          brand: 'Makis',
          channel: 'DiDi',
          storeId: 'Centro',
          outcome: OrderOutcome.cancelledUnpaid,
          paidAmount: 0,
          date: DateTime(2026, 1, 6),
          lines: const <SalesLine>[SalesLine(category: ProductCategory.makis, quantity: 10)],
        ),
      ];
}
