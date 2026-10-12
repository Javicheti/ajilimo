import { mkdir, readFile, writeFile } from 'node:fs/promises';
import readline from 'node:readline';
import { chromium } from 'playwright';

/**
 * Capturador del Portal Partners de Rappi.
 *
 * - Abre Chrome (o headless con HEADLESS=1), navega al portal y captura TODAS
 *   las respuestas JSON del portal, incluyendo los HEADERS de la petición
 *   (Authorization, x-*, etc.) para poder reproducirlas.
 * - Con USE_STATE=1 reutiliza la sesión guardada (out/state.json) sin login.
 *
 * Uso:
 *   # primera vez (login manual):
 *   TARGET_URL="https://partners.rappi.com/home?..." npm run capture
 *   # re-captura headless reutilizando sesión:
 *   USE_STATE=1 HEADLESS=1 AUTO_SECONDS=30 node capture.mjs
 */

const DEFAULT_URL =
  'https://partners.rappi.com/home?from=2026-10-03&to=2026-10-10&brandId=PE57159&storeIds=PE73017,PE73507,PE73506,PE73505';

const target = process.env.TARGET_URL || DEFAULT_URL;
const outDir = new URL('./out/', import.meta.url).pathname;
const headless = process.env.HEADLESS === '1';
const useState = process.env.USE_STATE === '1';

await mkdir(outDir, { recursive: true });

function safeJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return text.slice(0, 2000);
  }
}

function pickHeaders(headers) {
  const out = {};
  for (const [key, value] of Object.entries(headers)) {
    if (/authorization|x-[a-z-]+|^accept$|^content-type$|^country$/i.test(key)) out[key] = value;
  }
  return out;
}

function isInteresting(url) {
  if (/\.(js|css|png|jpe?g|svg|gif|webp|woff2?|ico|map)(\?|$)/i.test(url)) return false;
  return true;
}

const browser = await chromium.launch({ headless });
let context;
if (useState) {
  const state = JSON.parse(await readFile(`${outDir}state.json`, 'utf8'));
  context = await browser.newContext({ storageState: state });
} else {
  context = await browser.newContext();
}
const page = await context.newPage();

const captured = [];
page.on('response', async (response) => {
  try {
    const url = response.url();
    if (!isInteresting(url)) return;
    const contentType = response.headers()['content-type'] || '';
    if (!/json/i.test(contentType)) return;
    const body = await response.text();
    captured.push({
      url,
      status: response.status(),
      method: response.request().method(),
      requestHeaders: pickHeaders(response.request().headers()),
      postData: response.request().postData() || null,
      at: new Date().toISOString(),
      body: safeJson(body),
    });
    console.log(`[capturado ${response.status()}] ${url}`);
  } catch {
    // ignora respuestas sin body
  }
});

console.log(`▶ Navegando… (headless=${headless}, reuseState=${useState})`);
await page.goto(target, { waitUntil: 'domcontentloaded' });

// Navegación automática por secciones (para disparar sus APIs) — headless con sesión.
const navUrls = (process.env.NAV_URLS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);
if (navUrls.length > 0) {
  for (const section of navUrls) {
    try {
      console.log(`▶ Sección: ${section}`);
      await page.goto(section, { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(5000);
    } catch (error) {
      console.error(`  (error navegando ${section}: ${error})`);
    }
  }
}

const autoSeconds = Number.parseInt(process.env.AUTO_SECONDS || '0', 10);
if (headless || (autoSeconds > 0 && useState)) {
  const wait = autoSeconds > 0 ? autoSeconds : 25;
  console.log(`▶ Esperando ${wait}s para capturar las llamadas…`);
  await page.waitForTimeout(wait * 1000);
} else {
  console.log('▶ Inicia sesión y navega. Pulsa ENTER para guardar…');
  await new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
    rl.question('', () => {
      rl.close();
      resolve();
    });
  });
}

await writeFile(`${outDir}network.json`, JSON.stringify(captured, null, 2));
await writeFile(`${outDir}page.html`, await page.content());
await context.storageState({ path: `${outDir}state.json` });

console.log(`✅ ${captured.length} respuestas en out/network.json · sesión en out/state.json`);
await browser.close();
