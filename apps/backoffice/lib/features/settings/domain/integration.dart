import 'package:ajilimo_shared/ajilimo_shared.dart';

/// Entorno de una integración.
enum IntegrationEnvironment { mock, dev, prod }

extension IntegrationEnvironmentX on IntegrationEnvironment {
  String get label => switch (this) {
        IntegrationEnvironment.mock => 'Mock',
        IntegrationEnvironment.dev => 'Dev',
        IntegrationEnvironment.prod => 'Prod',
      };

  String get wire => name;
}

/// Estado de una integración (canal) para un tenant.
class Integration {
  const Integration({
    required this.channel,
    required this.environment,
    required this.baseUrl,
    required this.status,
    required this.credentialsConfigured,
  });

  final DeliveryChannel channel;
  final IntegrationEnvironment environment;
  final String baseUrl;
  final IntegrationStatus status;
  final bool credentialsConfigured;

  Integration copyWith({
    IntegrationEnvironment? environment,
    String? baseUrl,
    IntegrationStatus? status,
    bool? credentialsConfigured,
  }) {
    return Integration(
      channel: channel,
      environment: environment ?? this.environment,
      baseUrl: baseUrl ?? this.baseUrl,
      status: status ?? this.status,
      credentialsConfigured: credentialsConfigured ?? this.credentialsConfigured,
    );
  }
}

enum IntegrationStatus { connected, error, pendingAuth }

extension IntegrationStatusX on IntegrationStatus {
  String get label => switch (this) {
        IntegrationStatus.connected => 'Conectado',
        IntegrationStatus.error => 'Error',
        IntegrationStatus.pendingAuth => 'Pendiente de credenciales',
      };
}
