import 'package:ajilimo_shared/ajilimo_shared.dart';

class EvidenceRecord {
  const EvidenceRecord({
    required this.orderId,
    required this.channel,
    required this.storeName,
    required this.capturedAt,
    required this.complete,
  });

  final String orderId;
  final DeliveryChannel channel;
  final String storeName;
  final DateTime capturedAt;
  final bool complete;
}
