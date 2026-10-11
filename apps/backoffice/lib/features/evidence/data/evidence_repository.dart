import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../domain/evidence_record.dart';

/// Repositorio de evidencia KORN. Fase 6: datos semilla (mock); en producción
/// vendrá de Cloud Storage `tenants/{id}/evidence/{orderId}/`.
class EvidenceRepository {
  List<EvidenceRecord> seed() => <EvidenceRecord>[
        EvidenceRecord(
          orderId: 'R-4821',
          channel: DeliveryChannel.rappi,
          storeName: 'PINWINGS — Surco',
          capturedAt: DateTime.now().subtract(const Duration(minutes: 3)),
          complete: true,
        ),
        EvidenceRecord(
          orderId: 'R-4799',
          channel: DeliveryChannel.rappi,
          storeName: 'Makis — Centro',
          capturedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          complete: true,
        ),
        EvidenceRecord(
          orderId: 'D-3310',
          channel: DeliveryChannel.didi,
          storeName: 'PINWINGS — Miraflores',
          capturedAt: DateTime.now().subtract(const Duration(minutes: 25)),
          complete: false,
        ),
      ];
}
