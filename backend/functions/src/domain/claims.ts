export type ClaimUrgency = 'ok' | 'warning' | 'critical' | 'expired';

export interface ClaimDeadline {
  hoursLeft: number;
  urgency: ClaimUrgency;
}

/**
 * Evalúa el plazo de un reclamo (DiDi da 24 h para responder). Si no se responde,
 * la app suele devolver el 100% del valor.
 */
export function evaluateClaimDeadline(
  createdAt: Date,
  now: Date,
  windowHours = 24,
): ClaimDeadline {
  const elapsedHours = (now.getTime() - createdAt.getTime()) / 3_600_000;
  const hoursLeft = windowHours - elapsedHours;

  let urgency: ClaimUrgency = 'ok';
  if (hoursLeft <= 0) urgency = 'expired';
  else if (hoursLeft <= 4) urgency = 'critical';
  else if (hoursLeft <= 8) urgency = 'warning';

  return { hoursLeft, urgency };
}
