import { AppError } from '../shared/errors';
import { verifyRappiSignature } from '../security/signatures';

export interface RappiWebhookEvent {
  type: string;
  orderId?: string;
  storeId?: string;
  enabled?: boolean;
  raw: unknown;
}

/**
 * Verifica y normaliza un webhook de Rappi.
 * @param eventType Nombre del evento configurado (p.ej. STORE_CONNECTIVITY).
 * @param signatureHeader Valor del header `Rappi-Signature`.
 * @param rawBody Cuerpo crudo tal como llegó (string).
 * @param secret Secreto del webhook.
 */
export function parseRappiWebhook(
  eventType: string,
  signatureHeader: string | undefined,
  rawBody: string,
  secret: string,
): RappiWebhookEvent {
  if (!verifyRappiSignature(signatureHeader, rawBody, secret)) {
    throw new AppError('invalid_signature', 'Firma de webhook inválida');
  }

  let payload: Record<string, unknown> = {};
  try {
    payload = rawBody ? (JSON.parse(rawBody) as Record<string, unknown>) : {};
  } catch {
    throw new AppError('http', 'Payload de webhook no es JSON válido');
  }

  const detail = (payload.order_detail ?? {}) as Record<string, unknown>;
  const store = (payload.store ?? {}) as Record<string, unknown>;

  return {
    type: eventType,
    orderId: (detail.order_id as string) ?? (payload.order_id as string) ?? undefined,
    storeId:
      (detail.store_id as string) ??
      (store.internal_id as string) ??
      (payload.store_id as string) ??
      (payload.external_store_id as string) ??
      undefined,
    enabled: typeof payload.enabled === 'boolean' ? payload.enabled : undefined,
    raw: payload,
  };
}
