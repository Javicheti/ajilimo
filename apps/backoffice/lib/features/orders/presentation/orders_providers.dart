import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/orders_repository.dart';

final Provider<OrdersRepository> ordersRepositoryProvider =
    Provider<OrdersRepository>((ref) => OrdersRepository());
