/** Códigos de error del backend. */
export type ErrorCode =
  | 'network'
  | 'timeout'
  | 'http'
  | 'auth'
  | 'rate_limit'
  | 'not_found'
  | 'invalid_signature'
  | 'invalid_config'
  | 'unknown';

/** Error tipado del backend con código y contexto. */
export class AppError extends Error {
  readonly code: ErrorCode;
  readonly status?: number;
  readonly details?: Record<string, unknown>;

  constructor(
    code: ErrorCode,
    message: string,
    options?: { status?: number; details?: Record<string, unknown>; cause?: unknown },
  ) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.status = options?.status;
    this.details = options?.details;
    if (options?.cause !== undefined) {
      (this as { cause?: unknown }).cause = options.cause;
    }
  }

  static isAppError(value: unknown): value is AppError {
    return value instanceof AppError;
  }
}

/** Envuelve cualquier error en un [AppError]. */
export function toAppError(error: unknown, code: ErrorCode = 'unknown'): AppError {
  if (AppError.isAppError(error)) return error;
  const message = error instanceof Error ? error.message : String(error);
  return new AppError(code, message, { cause: error });
}
