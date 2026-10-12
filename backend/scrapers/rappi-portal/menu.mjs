import { fileURLToPath } from 'node:url';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright';

/**
 * Consulta el menú (complete-menu) de varias tiendas usando la sesión + token
 * capturados. Guarda out/menus.json para que parse.mjs lo incluya.
 *
 * Uso:
 *   STORES="73017,73507" node menu.mjs
 */

const outDir = fileURLToPath(new URL('./out/', import.meta.url));
await mkdir(outDir, { recursive: true });

const DEFAULT_STORES =
  '73017,73507,73506,73505,73504,73503,73502,73501,93745,104888,73019,73018,73016,102450';
const stores = (process.env.STORES || DEFAULT_STORES).split(',').map((s) => s.trim()).filter(Boolean);

const state = JSON.parse(await readFile(`${outDir}state.json`, 'utf8'));
const network = JSON.parse(await readFile(`${outDir}network.json`, 'utf8'));
const auth = network.find((r) => r.requestHeaders?.authorization)?.requestHeaders.authorization;
if (!auth) {
  console.error('No hay Authorization en network.json. Re-corrope la captura.');
  process.exit(1);
}

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ storageState: state });
const page = await context.newPage();

const menus = [];
for (const id of stores) {
  const url = `https://services.rappi.com/rests-partners-gateway/cauth/api/menu-reviews-ms/menu/${id}/complete-menu?country=PE&v2=true`;
  try {
    const response = await page.request.get(url, { headers: { authorization: auth, accept: 'application/json' } });
    const parsed = JSON.parse(await response.text());
    const items = parsed?.items ? Object.values(parsed.items) : [];
    console.log(`[${response.status()}] store ${id} · ${items.length} items`);
    menus.push({
      storeId: Number(id),
      items: items.map((it) => ({
        id: it.id,
        title: it.title,
        price: it.price,
        isAvailable: it.is_available === true,
        suspendReason: it.suspend_reason ?? null,
      })),
    });
  } catch (error) {
    console.error(`[error] store ${id}: ${error}`);
  }
}

await writeFile(`${outDir}menus.json`, JSON.stringify(menus, null, 2));
console.log(`✅ out/menus.json (${menus.length} tiendas)`);
await browser.close();
