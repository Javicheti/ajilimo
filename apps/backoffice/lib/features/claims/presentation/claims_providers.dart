import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/claims_repository.dart';

final Provider<ClaimsRepository> claimsRepositoryProvider =
    Provider<ClaimsRepository>((ref) => ClaimsRepository());
