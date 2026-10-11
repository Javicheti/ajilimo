import 'package:ajilimo_shared/ajilimo_shared.dart';

import '../domain/promo.dart';

/// Repositorio de promos/sabores. Fase 4: datos semilla (mock); en producción
/// vendrá del backend (Rests Menu `suspension_info` + `is_category_active`).
class PromosRepository {
  List<PromoItem> seed() => const <PromoItem>[
        PromoItem(
          sku: 'promo_makis_alas',
          title: 'Promo Makis + Alas',
          type: PromoType.promo,
          available: true,
          price: 39.9,
          promoPrice: 39.9,
          channel: DeliveryChannel.rappi,
        ),
        PromoItem(
          sku: 'gaseosa_500',
          title: 'Promo con Gaseosa 500ml',
          type: PromoType.promo,
          available: true,
          price: 9.9,
          promoPrice: 6.9,
          channel: DeliveryChannel.rappi,
        ),
        PromoItem(
          sku: 'alas_bbq',
          title: 'Alas BBQ (x8)',
          type: PromoType.sabor,
          available: false,
          price: 24.9,
          suspendReason: 'Is stocked out',
          channel: DeliveryChannel.rappi,
        ),
        PromoItem(
          sku: 'maki_california',
          title: 'Maki California (x10)',
          type: PromoType.sabor,
          available: false,
          price: 29.9,
          channel: DeliveryChannel.didi,
        ),
      ];
}
