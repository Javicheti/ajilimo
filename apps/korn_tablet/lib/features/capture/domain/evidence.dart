class EvidenceValidation {
  const EvidenceValidation({required this.valid, required this.issues});

  final bool valid;
  final List<String> issues;
}

/// Valida la evidencia KORN antes de permitir la entrega al rider.
EvidenceValidation validateEvidence({
  required String orderId,
  required bool checklistComplete,
  required bool hasPhoto,
}) {
  final List<String> issues = <String>[];
  if (orderId.trim().isEmpty) issues.add('Falta el número de pedido');
  if (!checklistComplete) issues.add('Checklist incompleto');
  if (!hasPhoto) issues.add('Falta la foto de evidencia');
  return EvidenceValidation(valid: issues.isEmpty, issues: issues);
}
