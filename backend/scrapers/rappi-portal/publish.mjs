import { readFile } from 'node:fs/promises';

/**
 * Publica el resumen capturado (out/summary.json) al BFF (modo bridge).
 *
 * Uso:
 *   BRIDGE_TOKEN=xxxx npm run publish
 * Variables:
 *   BRIDGE_URL  (default: api desplegada)
 *   BRIDGE_TOKEN (obligatorio)
 */

const summaryPath = new URL('./out/summary.json', import.meta.url).pathname;
const summary = JSON.parse(await readFile(summaryPath, 'utf8'));

const url = process.env.BRIDGE_URL || 'https://api-mor35f5doa-uc.a.run.app/bridge/rappi/summary';
const token = process.env.BRIDGE_TOKEN;
if (!token) {
  console.error('Define BRIDGE_TOKEN (ver backend/functions/.env).');
  process.exit(1);
}

const response = await fetch(url, {
  method: 'POST',
  headers: { 'content-type': 'application/json', 'x-bridge-token': token },
  body: JSON.stringify(summary),
});

console.log(`[${response.status}] ${url}`);
console.log(await response.text());
