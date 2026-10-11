import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/connectivity.dart';

/// Repositorio de conectividad. Intenta leer del BFF y cae a datos locales.
class ConnectivityRepository {
  ConnectivityRepository({this.api});

  final ApiClient? api;

  List<ConnectivityRow> seed() => const <ConnectivityRow>[
        ConnectivityRow(storeId: '73502', name: 'Alenka´s Bakery - Callao', channel: DeliveryChannel.rappi, status: StoreStatus.suspended, detail: 'Suspensión indefinida · Cancelaciones'),
        ConnectivityRow(storeId: '73501', name: 'Alenka´s Bakery - Sjl', channel: DeliveryChannel.rappi, status: StoreStatus.suspended, detail: 'Suspensión indefinida · Cancelaciones'),
        ConnectivityRow(storeId: '73503', name: 'Alenka´s Bakery - Sjm', channel: DeliveryChannel.rappi, status: StoreStatus.closed, detail: 'Fuera de horario regular'),
        ConnectivityRow(storeId: '73504', name: 'Alenka´s Bakery - Barranco', channel: DeliveryChannel.rappi, status: StoreStatus.closed, detail: '—'),
        ConnectivityRow(storeId: '93745', name: 'Alenka´s Bakery - Ejercito', channel: DeliveryChannel.rappi, status: StoreStatus.closed, detail: 'Abre 11/10 16:08'),
        ConnectivityRow(storeId: '104888', name: 'Alenkas - Chorrillos 1', channel: DeliveryChannel.rappi, status: StoreStatus.closed, detail: '—'),
        ConnectivityRow(storeId: '73017', name: 'Alenka´s Bakery - Benavides', channel: DeliveryChannel.rappi, status: StoreStatus.open, detail: 'Hasta 22:00'),
        ConnectivityRow(storeId: '73507', name: 'Alenka´s Bakery - San Miguel', channel: DeliveryChannel.rappi, status: StoreStatus.open, detail: 'Hasta 22:00'),
        ConnectivityRow(storeId: '73506', name: 'Alenka´s Bakery - Surquillo', channel: DeliveryChannel.rappi, status: StoreStatus.open, detail: 'Hasta 22:00'),
        ConnectivityRow(storeId: '73505', name: 'Alenka´s Bakery - Cercado', channel: DeliveryChannel.rappi, status: StoreStatus.open, detail: 'Hasta 22:00'),
      ];

  Future<List<ConnectivityRow>> fetchRemote() async {
    if (api == null) return const <ConnectivityRow>[];
    final List<Map<String, dynamic>> rows = await api!.getControlTower();
    return rows
        .map(
          (row) => ConnectivityRow(
            storeId: (row['storeId'] ?? '').toString(),
            name: (row['name'] ?? '').toString(),
            channel: DeliveryChannel.values.firstWhere(
              (c) => c.name == row['channel'],
              orElse: () => DeliveryChannel.rappi,
            ),
            status: _status(row['status'] as String?),
            detail: '—',
          ),
        )
        .toList();
  }

  static StoreStatus _status(String? value) => switch (value) {
        'closed' => StoreStatus.closed,
        'paused' => StoreStatus.paused,
        'suspended' => StoreStatus.suspended,
        'high_demand' => StoreStatus.highDemand,
        _ => StoreStatus.open,
      };
}

final Provider<ConnectivityRepository> connectivityRepositoryProvider =
    Provider<ConnectivityRepository>((ref) => ConnectivityRepository(api: ref.read(apiClientProvider)));
