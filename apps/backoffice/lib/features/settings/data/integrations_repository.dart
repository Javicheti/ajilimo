import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../domain/integration.dart';

/// Repositorio de integraciones. En Fase 1 usa datos en memoria (seed);
/// en producción leerá la configuración multi-tenant desde el backend.
class IntegrationsRepository {
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

  /// Simula una prueba de conexión. En producción llamará al backend.
  Future<bool> testConnection(Integration integration) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return integration.environment == IntegrationEnvironment.mock;
  }
}
