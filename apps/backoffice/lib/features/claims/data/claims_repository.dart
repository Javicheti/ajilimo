import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../../../core/api/api_client.dart';
import '../domain/claim.dart';

/// Repositorio de reclamos. Intenta leer del BFF y cae a datos ficticios locales.
class ClaimsRepository {
  ClaimsRepository({this.api});

  final ApiClient? api;

  List<Claim> seed(DateTime now) => <Claim>[
        Claim(
          id: 'C-1',
          orderId: 'D-3310',
          channel: DeliveryChannel.didi,
          reason: ClaimReason.quality,
          amount: 31.80,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        Claim(
          id: 'C-2',
          orderId: 'D-3305',
          channel: DeliveryChannel.didi,
          reason: ClaimReason.incomplete,
          amount: 45.00,
          createdAt: now.subtract(const Duration(hours: 18)),
        ),
        Claim(
          id: 'C-3',
          orderId: 'D-3299',
          channel: DeliveryChannel.didi,
          reason: ClaimReason.insufficient,
          amount: 22.50,
          createdAt: now.subtract(const Duration(hours: 21)),
        ),
      ];

  Future<List<Claim>> fetchRemote() async {
    if (api == null) return const <Claim>[];
    final List<Map<String, dynamic>> rows = await api!.getClaims();
    return rows
        .map(
          (row) => Claim(
            id: (row['claimId'] ?? '').toString(),
            orderId: (row['orderId'] ?? '').toString(),
            channel: _channel(row['channel'] as String?),
            reason: _reason(row['reason'] as String?),
            amount: ((row['amount'] as num?) ?? 0).toDouble(),
            createdAt: DateTime.tryParse((row['createdAt'] ?? '').toString()) ?? DateTime.now(),
          ),
        )
        .toList();
  }

  static DeliveryChannel _channel(String? value) => DeliveryChannel.values.firstWhere(
        (channel) => channel.name == value,
        orElse: () => DeliveryChannel.didi,
      );

  static ClaimReason _reason(String? value) => switch (value) {
        'incomplete' => ClaimReason.incomplete,
        'insufficient' => ClaimReason.insufficient,
        _ => ClaimReason.quality,
      };
}
