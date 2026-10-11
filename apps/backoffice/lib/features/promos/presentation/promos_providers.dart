import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/promos_repository.dart';

final Provider<PromosRepository> promosRepositoryProvider =
    Provider<PromosRepository>((ref) => PromosRepository());
