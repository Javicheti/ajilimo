import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../domain/order.dart';

/// Repositorio de órdenes. Fase 3: datos semilla (mock); en producción vendrá
/// del backend (RappiConnector.getOrders / webhooks).
class OrdersRepository {
  List<DeliveryOrder> seed(DateTime now) => <DeliveryOrder>[
        DeliveryOrder(
          id: 'R-4821',
          channel: DeliveryChannel.rappi,
          storeName: 'PINWINGS — Surco',
          items: const <String>['Promo Makis + Alas x2', 'Gaseosa 500ml'],
          total: 84.70,
          status: OrderStatus.pending,
          placedAt: now.subtract(const Duration(minutes: 1)),
        ),
        DeliveryOrder(
          id: 'R-4799',
          channel: DeliveryChannel.rappi,
          storeName: 'Makis — Centro',
          items: const <String>['Maki California x10'],
          total: 29.90,
          status: OrderStatus.preparing,
          placedAt: now.subtract(const Duration(minutes: 20)),
          takenAt: now.subtract(const Duration(minutes: 19)),
        ),
        DeliveryOrder(
          id: 'D-3310',
          channel: DeliveryChannel.didi,
          storeName: 'PINWINGS — Miraflores',
          items: const <String>['Alas BBQ x8', 'Gaseosa 500ml'],
          total: 31.80,
          status: OrderStatus.preparing,
          placedAt: now.subtract(const Duration(minutes: 24)),
          takenAt: now.subtract(const Duration(minutes: 24)),
        ),
      ];
}
