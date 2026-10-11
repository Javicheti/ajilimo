import { createHash, createHmac, timingSafeEqual } from 'node:crypto';

/**
 * Firma un payload como lo hace Rappi: `t=<timestamp>,sign=<hmac-sha256(t + '.' + payload)>`.
 */
export function signRappiPayload(
  payload: string,
  secret: string,
  timestamp: number = Math.floor(Date.now() / 1000),
): string {
  const sign = createHmac('sha256', secret).update(`${timestamp}.${payload}`).digest('hex');
  return `t=${timestamp},sign=${sign}`;
}

interface ParsedSignature {
  timestamp: string;
  signature: string;
}

function parseHeader(header: string): ParsedSignature | null {
  const parts = header.split(',');
  let timestamp: string | undefined;
  let signature: string | undefined;
  for (const part of parts) {
    const [key, value] = part.split('=');
    if (key?.trim() === 't') timestamp = value;
    if (key?.trim() === 'sign') signature = value;
  }
  if (!timestamp || !signature) return null;
  return { timestamp, signature };
}

/**
 * Verifica el header `Rappi-Signature` contra el payload crudo (tal como llegó).
 * Devuelve false si falta, está mal formado o no coincide.
 */
export function verifyRappiSignature(header: string | undefined, payload: string, secret: string): boolean {
  if (!header) return false;
  const parsed = parseHeader(header);
  if (!parsed) return false;

  const expected = createHmac('sha256', secret)
    .update(`${parsed.timestamp}.${payload}`)
    .digest('hex');

  const a = Buffer.from(expected, 'utf8');
  const b = Buffer.from(parsed.signature, 'utf8');
  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

/**
 * Firma de DiDi: `MD5(rawBody + app_secret)`, enviada en el header `didi-header-sign`.
 */
export function signDidiPayload(payload: string, secret: string): string {
  return createHash('md5').update(`${payload}${secret}`).digest('hex');
}

/** Verifica el header de firma de DiDi. */
export function verifyDidiSignature(
  header: string | undefined,
  payload: string,
  secret: string,
): boolean {
  if (!header) return false;
  const expected = Buffer.from(signDidiPayload(payload, secret), 'utf8');
  const provided = Buffer.from(header, 'utf8');
  if (expected.length !== provided.length) return false;
  return timingSafeEqual(expected, provided);
}
