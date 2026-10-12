import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/reports_repository.dart';

final Provider<ReportsRepository> reportsRepositoryProvider =
    Provider<ReportsRepository>((ref) => ReportsRepository());

/// Indicadores reales desde el bridge (Portal Rappi). Si falla, source=none.
final FutureProvider<Map<String, dynamic>> bridgeReportsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    return await ref.read(apiClientProvider).getReports();
  } catch (_) {
    return <String, dynamic>{'source': 'none'};
  }
});
