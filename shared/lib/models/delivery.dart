/// Canales de delivery soportados.
enum DeliveryChannel { rappi, didi, pedidosya }

extension DeliveryChannelX on DeliveryChannel {
  String get label => switch (this) {
        DeliveryChannel.rappi => 'Rappi',
        DeliveryChannel.didi => 'DiDi',
        DeliveryChannel.pedidosya => 'PedidosYa',
      };

  String get short => switch (this) {
        DeliveryChannel.rappi => 'RP',
        DeliveryChannel.didi => 'DD',
        DeliveryChannel.pedidosya => 'PY',
      };
}

/// Estado operativo de una tienda.
enum StoreStatus { open, closed, paused, suspended, highDemand }

extension StoreStatusX on StoreStatus {
  String get label => switch (this) {
        StoreStatus.open => 'Abierto',
        StoreStatus.closed => 'Cerrado',
        StoreStatus.paused => 'Pausado',
        StoreStatus.suspended => 'Suspendido',
        StoreStatus.highDemand => 'Alta demanda',
      };
}
