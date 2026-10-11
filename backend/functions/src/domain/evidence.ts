export interface EvidenceInput {
  orderId: string;
  checklistComplete: boolean;
  hasPhoto: boolean;
}

export interface EvidenceValidation {
  valid: boolean;
  issues: string[];
}

/**
 * Valida la evidencia KORN antes de permitir la entrega al rider:
 * pedido identificado, checklist completo y foto capturada.
 */
export function validateEvidence(input: EvidenceInput): EvidenceValidation {
  const issues: string[] = [];
  if (!input.orderId.trim()) issues.push('Falta el número de pedido');
  if (!input.checklistComplete) issues.push('Checklist incompleto');
  if (!input.hasPhoto) issues.push('Falta la foto de evidencia');
  return { valid: issues.length === 0, issues };
}

/** Ruta estándar de la evidencia en Cloud Storage. */
export function evidencePath(tenantId: string, orderId: string, fileName = 'evidence.jpg'): string {
  return `tenants/${tenantId}/evidence/${orderId}/${fileName}`;
}
