import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright';

/**
 * Replay: reproduce las peticiones capturadas (método + headers + body exactos)
 * usando la sesión guardada, para endpoints identificados por patrón de URL.
 *
 * Uso:
 *   PATTERNS="stores-router/stores/info,partners-indicators/summary/sales/indicators" npm run fetch
 * (o ENDPOINTS con el mismo significado: substrings de la URL)
 */

const patterns = (process.env.PATTERNS || process.env.ENDPOINTS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

if (patterns.length === 0) {
  console.error('Define PATTERNS="substr1,substr2".');
  process.exit(1);
}

const outDir = new URL('./out/', import.meta.url).pathname;
await mkdir(outDir, { recursive: true });

function safeJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return text.slice(0, 4000);
  }
}

const state = JSON.parse(await readFile(`${outDir}state.json`, 'utf8'));
const network = JSON.parse(await readFile(`${outDir}network.json`, 'utf8'));

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ storageState: state });
const page = await context.newPage();

const results = [];
for (const pattern of patterns) {
  const entry = network.find((r) => r.url.includes(pattern) && r.status === 200);
  if (!entry) {
    console.log(`[skip] sin captura para: ${pattern}`);
    results.push({ pattern, error: 'not_captured' });
    continue;
  }
  try {
    const response = await page.request.fetch(entry.url, {
      method: entry.method,
      headers: {
        authorization: entry.requestHeaders.authorization,
        'content-type': entry.requestHeaders['content-type'] || 'application/json;charset=UTF-8',
        accept: 'application/json',
      },
      data: entry.postData || undefined,
    });
    const body = await response.text();
    results.push({ pattern, url: entry.url, status: response.status(), body: safeJson(body) });
    console.log(`[${response.status()}] ${entry.method} ${entry.url.slice(0, 90)}`);
  } catch (error) {
    results.push({ pattern, url: entry.url, error: String(error) });
    console.error(`[error] ${pattern}: ${error}`);
  }
}

await writeFile(`${outDir}results.json`, JSON.stringify(results, null, 2));
console.log(`✅ out/results.json (${results.length})`);
await browser.close();
