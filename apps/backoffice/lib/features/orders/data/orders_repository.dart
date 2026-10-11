import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../../../core/api/api_client.dart';
import '../domain/order.dart';

/// Repositorio de órdenes. Intenta leer del BFF y cae a datos ficticios locales.
class OrdersRepository {
  OrdersRepository({this.api});

  final ApiClient? api;

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

  Future<List<DeliveryOrder>> fetchRemote() async {
    if (api == null) return const <DeliveryOrder>[];
    final List<Map<String, dynamic>> rows = await api!.getOrders();
    final DateTime now = DateTime.now();
    return rows
        .map(
          (row) => DeliveryOrder(
            id: (row['orderId'] ?? '').toString(),
            channel: _channel(row['channel'] as String?),
            storeName: (row['storeName'] ?? row['storeId'] ?? '').toString(),
            items: <String>['${row['itemCount'] ?? 0} ítems'],
            total: ((row['total'] as num?) ?? 0).toDouble(),
            status: _status(row['status'] as String?),
            placedAt: now,
          ),
        )
        .toList();
  }

  static DeliveryChannel _channel(String? value) => DeliveryChannel.values.firstWhere(
        (channel) => channel.name == value,
        orElse: () => DeliveryChannel.rappi,
      );

  static OrderStatus _status(String? value) => switch (value) {
        'TAKEN' || 'PREPARING' => OrderStatus.preparing,
        'READY_FOR_PICKUP' => OrderStatus.ready,
        _ => OrderStatus.pending,
      };
}
