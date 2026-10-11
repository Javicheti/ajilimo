import 'package:ajilimo_shared/ajilimo_shared.dart';

class ConnectivityRow {
  const ConnectivityRow({
    required this.storeId,
    required this.name,
    required this.channel,
    required this.status,
    required this.detail,
  });

  final String storeId;
  final String name;
  final DeliveryChannel channel;
  final StoreStatus status;
  final String detail;
}
