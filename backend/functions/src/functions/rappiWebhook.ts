import { onRequest } from 'firebase-functions/v2/https';

import { parseRappiWebhook } from '../webhooks/rappi';
import { logger } from '../shared/logger';

/**
 * Endpoint receptor de webhooks de Rappi.
 * Verifica la firma HMAC-SHA256 y responde rápido. El encolado a Pub/Sub se
 * añadirá en la Fase 2 (normalizadores).
 */
export const rappiWebhook = onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ ok: false, error: 'method_not_allowed' });
    return;
  }

  const eventType = (req.query.event as string | undefined) ?? req.get('x-rappi-event') ?? 'UNKNOWN';
  const secret = process.env.RAPPI_WEBHOOK_SECRET ?? '';
  const signature = req.get('rappi-signature') ?? undefined;
  const raw =
    (req as unknown as { rawBody?: Buffer }).rawBody?.toString('utf8') ??
    JSON.stringify(req.body ?? {});

  try {
    const event = parseRappiWebhook(eventType, signature, raw, secret);
    logger.info('Webhook Rappi recibido', { event: event.type, storeId: event.storeId, orderId: event.orderId });
    res.status(200).json({ ok: true });
  } catch (error) {
    logger.warn('Webhook Rappi rechazado', { eventType, error: String(error) });
    res.status(401).json({ ok: false, error: 'invalid_signature' });
  }
});
