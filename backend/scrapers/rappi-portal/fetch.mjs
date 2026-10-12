import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright';

/**
 * Recolector: reutiliza la sesión guardada (out/state.json) y consulta los
 * endpoints internos del Portal Partners descubiertos en la captura.
 *
 * Uso (tras haber corrido `npm run capture` y tener out/state.json):
 *   ENDPOINTS="https://partners.rappi.com/api/...,https://..." npm run fetch
 *
 * Guarda los resultados en out/results.json.
 */

const endpoints = (process.env.ENDPOINTS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

if (endpoints.length === 0) {
  console.error('Define ENDPOINTS="url1,url2" (los obtenidos de la captura).');
  process.exit(1);
}

const outDir = new URL('./out/', import.meta.url).pathname;
await mkdir(outDir, { recursive: true });

let storageState;
try {
  storageState = JSON.parse(await readFile(`${outDir}state.json`, 'utf8'));
} catch {
  console.error('No hay out/state.json. Corre primero: npm run capture (inicia sesión).');
  process.exit(1);
}

function safeJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return text.slice(0, 4000);
  }
}

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ storageState });
const page = await context.newPage();

const results = [];
for (const url of endpoints) {
  try {
    const response = await page.request.get(url);
    const body = await response.text();
    results.push({ url, status: response.status(), body: safeJson(body) });
    console.log(`[${response.status()}] ${url}`);
  } catch (error) {
    results.push({ url, error: String(error) });
    console.error(`[error] ${url}: ${error}`);
  }
}

await writeFile(`${outDir}results.json`, JSON.stringify(results, null, 2));
console.log(`✅ Guardado out/results.json (${results.length} endpoints)`);

await browser.close();
