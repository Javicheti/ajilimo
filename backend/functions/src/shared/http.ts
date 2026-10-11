import { AppError, toAppError } from './errors';
import { logger } from './logger';

export interface HttpRequest {
  url: string;
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  headers?: Record<string, string>;
  body?: unknown;
  timeoutMs?: number;
  retries?: number;
}

const sleep = (ms: number): Promise<void> => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Cliente HTTP con timeout y reintentos con backoff exponencial.
 * Reintenta en errores de red/5xx/429 (no en 4xx de negocio).
 */
export async function requestJson<T>(request: HttpRequest): Promise<T> {
  const {
    url,
    method = 'GET',
    headers = {},
    body,
    timeoutMs = 15_000,
    retries = 2,
  } = request;

  let attempt = 0;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const response = await fetch(url, {
        method,
        headers: {
          accept: 'application/json',
          ...(body !== undefined ? { 'content-type': 'application/json' } : {}),
          ...headers,
        },
        body: body !== undefined ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      const text = await response.text();
      const parsed = text ? (JSON.parse(text) as unknown) : undefined;

      if (response.ok) {
        return parsed as T;
      }

      const retriable = response.status >= 500 || response.status === 429;
      if (retriable && attempt < retries) {
        attempt += 1;
        await sleep(backoffMs(attempt));
        continue;
      }

      throw new AppError(
        response.status === 401 || response.status === 403
          ? 'auth'
          : response.status === 404
            ? 'not_found'
            : response.status === 429
              ? 'rate_limit'
              : 'http',
        `HTTP ${response.status} en ${method} ${url}`,
        { status: response.status, details: { body: parsed } },
      );
    } catch (error) {
      if (AppError.isAppError(error)) throw error;

      const aborted = error instanceof Error && error.name === 'AbortError';
      if (attempt < retries) {
        attempt += 1;
        logger.warn('Reintentando request', { url, method, attempt, aborted });
        await sleep(backoffMs(attempt));
        continue;
      }
      throw new AppError(aborted ? 'timeout' : 'network', `Fallo de red en ${method} ${url}`, {
        cause: error,
      });
    } finally {
      clearTimeout(timer);
    }
  }
}

function backoffMs(attempt: number): number {
  return Math.min(200 * 2 ** (attempt - 1), 2_000);
}

export { toAppError };
