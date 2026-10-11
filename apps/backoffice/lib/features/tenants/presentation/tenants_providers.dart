import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tenants_repository.dart';

final Provider<TenantsRepository> tenantsRepositoryProvider =
    Provider<TenantsRepository>((ref) => TenantsRepository());
