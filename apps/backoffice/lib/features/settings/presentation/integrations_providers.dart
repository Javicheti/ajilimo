import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/integrations_repository.dart';

final Provider<IntegrationsRepository> integrationsRepositoryProvider = Provider<IntegrationsRepository>(
  (ref) => IntegrationsRepository(api: ref.read(apiClientProvider)),
);
