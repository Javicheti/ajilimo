import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reports_repository.dart';

final Provider<ReportsRepository> reportsRepositoryProvider =
    Provider<ReportsRepository>((ref) => ReportsRepository());
