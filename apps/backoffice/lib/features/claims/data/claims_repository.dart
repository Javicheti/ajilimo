import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../domain/claim.dart';

/// Repositorio de reclamos. Fase 7: datos semilla (mock); en producción vendrá
/// de DiDi (webhooks `orderCancelApply` / `orderRefundApply`).
class ClaimsRepository {
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
}
