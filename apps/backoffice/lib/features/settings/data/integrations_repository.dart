import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../../../core/api/api_client.dart';
import '../domain/integration.dart';

/// Repositorio de integraciones. Intenta leer del BFF y cae a datos ficticios locales.
class IntegrationsRepository {
  IntegrationsRepository({this.api});

  final ApiClient? api;

  List<Integration> seed() => const <Integration>[
        Integration(
          channel: DeliveryChannel.rappi,
          environment: IntegrationEnvironment.mock,
          baseUrl: 'http://localhost:8787',
          status: IntegrationStatus.connected,
          credentialsConfigured: false,
        ),
        Integration(
          channel: DeliveryChannel.didi,
          environment: IntegrationEnvironment.mock,
          baseUrl: 'http://localhost:8790',
          status: IntegrationStatus.pendingAuth,
          credentialsConfigured: false,
        ),
        Integration(
          channel: DeliveryChannel.pedidosya,
          environment: IntegrationEnvironment.mock,
          baseUrl: 'https://sandbox.partner.deliveryhero.io',
          status: IntegrationStatus.pendingAuth,
          credentialsConfigured: false,
        ),
      ];

  Future<List<Integration>> fetchRemote() async {
    if (api == null) return const <Integration>[];
    final List<Map<String, dynamic>> rows = await api!.getConnections();
    return rows
        .map(
          (row) => Integration(
            channel: _channel(row['provider'] as String?),
            environment: _environment(row['environment'] as String?),
            baseUrl: (row['baseUrl'] ?? '').toString(),
            status: _status(row['status'] as String?),
            credentialsConfigured: row['credentialsConfigured'] == true,
          ),
        )
        .toList();
  }

  static DeliveryChannel _channel(String? value) => DeliveryChannel.values.firstWhere(
        (channel) => channel.name == value,
        orElse: () => DeliveryChannel.rappi,
      );

  static IntegrationEnvironment _environment(String? value) => switch (value) {
        'dev' => IntegrationEnvironment.dev,
        'prod' => IntegrationEnvironment.prod,
        _ => IntegrationEnvironment.mock,
      };

  static IntegrationStatus _status(String? value) => switch (value) {
        'error' => IntegrationStatus.error,
        'pending_auth' => IntegrationStatus.pendingAuth,
        _ => IntegrationStatus.connected,
      };

  /// Simula una prueba de conexión. En producción llamará al backend.
  Future<bool> testConnection(Integration integration) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return integration.environment == IntegrationEnvironment.mock;
  }
}
