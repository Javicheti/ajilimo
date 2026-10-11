export type CookingSlaState = 'on_time' | 'at_risk' | 'overdue';

export interface CookingEvaluation {
  elapsedMinutes: number;
  remainingMinutes: number;
  state: CookingSlaState;
}

/**
 * Evalúa el cumplimiento del tiempo de preparación (objetivo por defecto 22 min).
 * - `on_time`: holgado.
 * - `at_risk`: ≥ 80% del objetivo.
 * - `overdue`: superó el objetivo.
 */
export function evaluateCooking(
  takenAt: Date,
  now: Date,
  targetMinutes: number,
): CookingEvaluation {
  const elapsedMinutes = Math.max(0, (now.getTime() - takenAt.getTime()) / 60_000);
  const remainingMinutes = targetMinutes - elapsedMinutes;

  let state: CookingSlaState = 'on_time';
  if (elapsedMinutes >= targetMinutes) {
    state = 'overdue';
  } else if (elapsedMinutes >= targetMinutes * 0.8) {
    state = 'at_risk';
  }

  return { elapsedMinutes, remainingMinutes, state };
}
