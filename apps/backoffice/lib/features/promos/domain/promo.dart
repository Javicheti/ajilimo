import 'package:ajilimo_shared/ajilimo_shared.dart';

enum PromoType { promo, sabor }

extension PromoTypeX on PromoType {
  String get label => switch (this) {
        PromoType.promo => 'Promo',
        PromoType.sabor => 'Sabor',
      };
}

enum PromoState { active, off, suspended, fullPrice }

extension PromoStateX on PromoState {
  String get label => switch (this) {
        PromoState.active => 'Activo',
        PromoState.off => 'Apagado',
        PromoState.suspended => 'Suspendido',
        PromoState.fullPrice => 'A precio full',
      };
}

class PromoItem {
  const PromoItem({
    required this.sku,
    required this.title,
    required this.type,
    required this.available,
    required this.price,
    this.promoPrice,
    this.suspendReason,
    required this.channel,
  });

  final String sku;
  final String title;
  final PromoType type;
  final bool available;
  final double price;
  final double? promoPrice;
  final String? suspendReason;
  final DeliveryChannel channel;

  PromoState get state {
    if (!available) {
      return suspendReason != null ? PromoState.suspended : PromoState.off;
    }
    if (promoPrice != null && price > promoPrice!) return PromoState.fullPrice;
    return PromoState.active;
  }
}
