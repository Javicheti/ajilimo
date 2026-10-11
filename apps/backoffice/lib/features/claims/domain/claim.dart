import 'package:ajilimo_shared/ajilimo_shared.dart';

enum ClaimReason { incomplete, insufficient, quality }

extension ClaimReasonX on ClaimReason {
  String get label => switch (this) {
        ClaimReason.incomplete => 'Pedido incompleto',
        ClaimReason.insufficient => 'Cantidad insuficiente',
        ClaimReason.quality => 'Calidad del producto',
      };
}

enum ClaimUrgency { ok, warning, critical, expired }

class Claim {
  const Claim({
    required this.id,
    required this.orderId,
    required this.channel,
    required this.reason,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final DeliveryChannel channel;
  final ClaimReason reason;
  final double amount;
  final DateTime createdAt;

  static const int windowHours = 24;

  double _hoursLeft(DateTime now) =>
      windowHours - now.difference(createdAt).inMinutes / 60.0;

  ClaimUrgency urgencyAt(DateTime now) {
    final double hoursLeft = _hoursLeft(now);
    if (hoursLeft <= 0) return ClaimUrgency.expired;
    if (hoursLeft <= 4) return ClaimUrgency.critical;
    if (hoursLeft <= 8) return ClaimUrgency.warning;
    return ClaimUrgency.ok;
  }

  String countdown(DateTime now) {
    final int remaining = windowHours * 3600 - now.difference(createdAt).inSeconds;
    if (remaining <= 0) return 'Expirado';
    final int h = remaining ~/ 3600;
    final int m = (remaining % 3600) ~/ 60;
    final int s = remaining % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }
}
