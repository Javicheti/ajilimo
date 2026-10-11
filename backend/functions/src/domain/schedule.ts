import type { ScheduleWindow } from '../connectors/common/types';

const WEEKDAYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

function toMinutes(value: string): number {
  const [hours, minutes] = value.split(':').map((part) => Number.parseInt(part, 10));
  return (Number.isFinite(hours) ? hours : 0) * 60 + (Number.isFinite(minutes) ? minutes : 0);
}

/**
 * Indica si `now` cae dentro de alguna ventana de horario.
 * Sin ventanas, se asume siempre disponible. Soporta horarios que cruzan medianoche.
 */
export function isWithinSchedule(now: Date, windows: ScheduleWindow[]): boolean {
  if (windows.length === 0) return true;

  const today = WEEKDAYS[now.getDay()];
  const minutes = now.getHours() * 60 + now.getMinutes();

  return windows.some((window) => {
    const days = window.daysOfWeek.map((day) => day.trim().toLowerCase());
    if (!days.includes(today) && !days.includes('daily')) return false;
    const start = toMinutes(window.startTime);
    const end = toMinutes(window.endTime);
    if (start <= end) return minutes >= start && minutes < end;
    return minutes >= start || minutes < end;
  });
}
