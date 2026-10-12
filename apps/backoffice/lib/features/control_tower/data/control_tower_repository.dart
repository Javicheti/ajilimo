import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

/// Fila de estado de tienda para la torre de control.
class StoreStatusRow {
  const StoreStatusRow({
    required this.storeId,
    required this.name,
    required this.brand,
    required this.channel,
    required this.status,
  });

  final String storeId;
  final String name;
  final String brand;
  final DeliveryChannel channel;
  final StoreStatus status;
}

/// Repositorio de la torre de control. Intenta leer del BFF y, si no está
/// disponible, cae a los datos ficticios locales (seed).
class ControlTowerRepository {
  ControlTowerRepository({this.api});

  final ApiClient? api;

  List<StoreStatusRow> seed() => const <StoreStatusRow>[
        StoreStatusRow(
          storeId: '900105814',
          name: 'PINWINGS — Surco',
          brand: 'PINWINGS',
          channel: DeliveryChannel.rappi,
          status: StoreStatus.open,
        ),
        StoreStatusRow(
          storeId: '900105815',
          name: 'PINWINGS — Miraflores',
          brand: 'PINWINGS',
          channel: DeliveryChannel.rappi,
          status: StoreStatus.paused,
        ),
        StoreStatusRow(
          storeId: '900105816',
          name: 'Makis — Centro',
          brand: 'Makis',
          channel: DeliveryChannel.rappi,
          status: StoreStatus.suspended,
        ),
        StoreStatusRow(
          storeId: '900105817',
          name: 'Makis — San Isidro',
          brand: 'Makis',
          channel: DeliveryChannel.rappi,
          status: StoreStatus.closed,
        ),
        StoreStatusRow(
          storeId: 'didi-201',
          name: 'PINWINGS — Miraflores',
          brand: 'PINWINGS',
          channel: DeliveryChannel.didi,
          status: StoreStatus.open,
        ),
        StoreStatusRow(
          storeId: 'didi-202',
          name: 'Makis — Centro',
          brand: 'Makis',
          channel: DeliveryChannel.didi,
          status: StoreStatus.highDemand,
        ),
      ];

  Future<({List<StoreStatusRow> rows, String? generatedAt})> fetchRemote({String? brand}) async {
    if (api == null) return (rows: const <StoreStatusRow>[], generatedAt: null);
    final ({List<Map<String, dynamic>> rows, String? generatedAt}) result =
        await api!.getControlTower(brand: brand);
    final List<StoreStatusRow> mapped = result.rows
        .map(
          (row) => StoreStatusRow(
            storeId: (row['storeId'] ?? '') as String,
            name: (row['name'] ?? '') as String,
            brand: (row['brand'] ?? '') as String,
            channel: _channel(row['channel'] as String?),
            status: _status(row['status'] as String?),
          ),
        )
        .toList();
    return (rows: mapped, generatedAt: result.generatedAt);
  }

  static DeliveryChannel _channel(String? value) {
    return DeliveryChannel.values.firstWhere(
      (channel) => channel.name == value,
      orElse: () => DeliveryChannel.rappi,
    );
  }

  static StoreStatus _status(String? value) => switch (value) {
        'open' => StoreStatus.open,
        'closed' => StoreStatus.closed,
        'paused' => StoreStatus.paused,
        'suspended' => StoreStatus.suspended,
        'high_demand' => StoreStatus.highDemand,
        _ => StoreStatus.open,
      };
}

final Provider<ControlTowerRepository> controlTowerRepositoryProvider = Provider<ControlTowerRepository>(
  (ref) => ControlTowerRepository(api: ref.read(apiClientProvider)),
);
