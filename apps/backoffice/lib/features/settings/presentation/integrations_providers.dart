import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/integrations_repository.dart';

final Provider<IntegrationsRepository> integrationsRepositoryProvider =
    Provider<IntegrationsRepository>((ref) => IntegrationsRepository());
