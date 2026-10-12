import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { chromium } from 'playwright';

/**
 * Obtiene el catálogo de TODAS las marcas de la cuenta (Portal Partners).
 * Guarda out/brands.json = [{ brandId, brandName, storeIds }]
 */

const outDir = new URL('./out/', import.meta.url).pathname;
await mkdir(outDir, { recursive: true });

const state = JSON.parse(await readFile(`${outDir}state.json`, 'utf8'));
const network = JSON.parse(await readFile(`${outDir}network.json`, 'utf8'));
const auth = network.find((r) => r.requestHeaders?.authorization)?.requestHeaders.authorization;
if (!auth) {
  console.error('No hay Authorization en network.json. Re-corre la captura.');
  process.exit(1);
}

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ storageState: state });
const page = await context.newPage();

const url = 'https://services.rappi.com/rests-partners-gateway/cauth/rests-partners-accounts/brand/family/email?country=PE';
const response = await page.request.get(url, { headers: { authorization: auth, accept: 'application/json' } });
const data = JSON.parse(await response.text());

const flattenStores = (stores) => {
  const list = [];
  for (const s of stores || []) {
    if (s.id) list.push({ id: s.id, name: s.name });
    for (const c of s.children || []) if (c.id) list.push({ id: c.id, name: c.name });
  }
  return list;
};

const brands = (Array.isArray(data) ? data : []).map((b) => ({
  brandId: b.brand_id,
  brandName: b.brand_name,
  stores: flattenStores(b.stores),
}));

await writeFile(`${outDir}brands.json`, JSON.stringify(brands, null, 2));
console.log(`[${response.status()}] ${brands.length} marcas`);
for (const b of brands) console.log(`  - ${b.brandId} · ${b.brandName} (${b.stores.length} tiendas)`);

await browser.close();
