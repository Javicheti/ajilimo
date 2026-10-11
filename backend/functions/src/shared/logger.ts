type Level = 'debug' | 'info' | 'warn' | 'error';

/**
 * Logger estructurado mínimo (JSON por línea), compatible con Cloud Logging.
 */
class Logger {
  constructor(private readonly scope: string) {}

  child(scope: string): Logger {
    return new Logger(`${this.scope}.${scope}`);
  }

  private write(level: Level, message: string, meta?: Record<string, unknown>): void {
    const entry = {
      severity: level.toUpperCase(),
      scope: this.scope,
      message,
      time: new Date().toISOString(),
      ...(meta ?? {}),
    };
    const line = JSON.stringify(entry);
    if (level === 'error') {
      // eslint-disable-next-line no-console
      console.error(line);
    } else {
      // eslint-disable-next-line no-console
      console.log(line);
    }
  }

  debug(message: string, meta?: Record<string, unknown>): void {
    this.write('debug', message, meta);
  }
  info(message: string, meta?: Record<string, unknown>): void {
    this.write('info', message, meta);
  }
  warn(message: string, meta?: Record<string, unknown>): void {
    this.write('warn', message, meta);
  }
  error(message: string, meta?: Record<string, unknown>): void {
    this.write('error', message, meta);
  }
}

export const logger = new Logger('ajilimo');
export type { Logger };
