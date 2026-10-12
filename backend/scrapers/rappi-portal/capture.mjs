import { mkdir, writeFile } from 'node:fs/promises';
import readline from 'node:readline';
import { chromium } from 'playwright';

/**
 * Capturador del Portal Partners de Rappi.
 *
 * Abre Chrome (visible), navega al portal y espera a que INICIES SESIÓN
 * manualmente. Guarda TODAS las respuestas JSON (las APIs internas que usa
 * el portal) y el HTML final, para luego construir conectores estables.
 *
 * Uso:
 *   npm install
 *   npx playwright install chromium
 *   TARGET_URL="https://partners.rappi.com/home?..." npm run capture
 */

const DEFAULT_URL =
  'https://partners.rappi.com/home?from=2026-10-03&to=2026-10-10&brandId=PE57159&storeIds=PE73017,PE73507,PE73506,PE73505';

const target = process.env.TARGET_URL || DEFAULT_URL;
const outDir = new URL('./out/', import.meta.url).pathname;

await mkdir(outDir, { recursive: true });

function safeJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return text.slice(0, 2000);
  }
}

function isInteresting(url) {
  if (/\.(js|css|png|jpe?g|svg|gif|webp|woff2?|ico|map)(\?|$)/i.test(url)) return false;
  return true;
}

const browser = await chromium.launch({ headless: false });
const context = await browser.newContext();
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
      at: new Date().toISOString(),
      body: safeJson(body),
    });
    console.log(`[capturado ${response.status()}] ${url}`);
  } catch {
    // ignora respuestas sin body
  }
});

console.log('▶ Abriendo el portal. Inicia sesión y navega a las secciones que quieras capturar.');
await page.goto(target, { waitUntil: 'domcontentloaded' });

console.log('▶ Cuando termines de navegar, pulsa ENTER aquí para guardar los datos…');
await new Promise((resolve) => {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  rl.question('', () => {
    rl.close();
    resolve();
  });
});

await writeFile(`${outDir}network.json`, JSON.stringify(captured, null, 2));
await writeFile(`${outDir}page.html`, await page.content());

console.log(`✅ Guardadas ${captured.length} respuestas JSON en ${outDir}network.json`);
console.log('   y el DOM en out/page.html');

await browser.close();
