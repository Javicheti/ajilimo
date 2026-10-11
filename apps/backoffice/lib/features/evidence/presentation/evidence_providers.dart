import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/evidence_repository.dart';

final Provider<EvidenceRepository> evidenceRepositoryProvider =
    Provider<EvidenceRepository>((ref) => EvidenceRepository());
