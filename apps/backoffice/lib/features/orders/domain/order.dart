import 'package:ajilimo_shared/ajilimo_shared.dart';

enum OrderStatus { pending, preparing, ready }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Nueva',
        OrderStatus.preparing => 'En preparación',
        OrderStatus.ready => 'Lista',
      };
}

enum CookingState { onTime, atRisk, overdue }

extension CookingStateX on CookingState {
  String get label => switch (this) {
        CookingState.onTime => 'En tiempo',
        CookingState.atRisk => 'En riesgo',
        CookingState.overdue => 'Excedido',
      };
}

class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.channel,
    required this.storeName,
    required this.items,
    required this.total,
    required this.status,
    required this.placedAt,
    this.takenAt,
    this.targetMinutes = 22,
  });

  final String id;
  final DeliveryChannel channel;
  final String storeName;
  final List<String> items;
  final double total;
  final OrderStatus status;
  final DateTime placedAt;
  final DateTime? takenAt;
  final int targetMinutes;

  int elapsedSeconds(DateTime now) =>
      takenAt == null ? 0 : now.difference(takenAt!).inSeconds;

  CookingState cookingState(DateTime now) {
    if (takenAt == null) return CookingState.onTime;
    final double elapsedMinutes = elapsedSeconds(now) / 60;
    if (elapsedMinutes >= targetMinutes) return CookingState.overdue;
    if (elapsedMinutes >= targetMinutes * 0.8) return CookingState.atRisk;
    return CookingState.onTime;
  }

  DeliveryOrder take(DateTime now) => DeliveryOrder(
        id: id,
        channel: channel,
        storeName: storeName,
        items: items,
        total: total,
        status: OrderStatus.preparing,
        placedAt: placedAt,
        takenAt: now,
        targetMinutes: targetMinutes,
      );
}
