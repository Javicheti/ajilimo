import { fileURLToPath } from 'node:url';
import { mkdir, readFile, writeFile } from 'node:fs/promises';

/**
 * Normaliza la captura del Portal Partners (out/network.json) a datos de AjíLimo.
 * Salida: out/summary.json
 *
 * Uso: node parse.mjs
 */

const outDir = fileURLToPath(new URL('./out/', import.meta.url));
await mkdir(outDir, { recursive: true });

const network = JSON.parse(await readFile(`${outDir}network.json`, 'utf8'));
const findBody = (sub) => {
  const hit = network.find((r) => r.url.includes(sub) && r.body && typeof r.body === 'object');
  return hit ? hit.body : undefined;
};

// Tiendas (conectividad / estado).
const storesRaw = findBody('stores-router/stores/info') || [];
const stores = (Array.isArray(storesRaw) ? storesRaw : []).map((s) => ({
  storeId: String(s.store_id ?? ''),
  name: s.name ?? '',
  brand: s.brand?.name ?? '',
  cityAddressId: s.city_address_id ?? null,
  isEnabled: s.is_enabled === true,
  isPublished: s.is_published === true,
  tier: s.tier ?? null,
  maxCookingTime: s.max_cooking_time ?? null,
  minCookingTime: s.min_cooking_time ?? null,
}));

// Métricas de servicio.
const ind = findBody('summary/sales/indicators') || {};
const serviceMetrics = {
  reclamosPct: ind.error?.percentage?.value ?? null,
  reclamosPctVariation: ind.error?.percentage?.variation ?? null,
  cancelacionesPct: ind.cancellation?.percentage?.value ?? null,
  disponibilidadPct: ind.availability?.percentage?.value ?? null,
  disponibilidadVariation: ind.availability?.percentage?.variation ?? null,
  sinDisponibilidadPct: ind.unavailability?.percentage?.value ?? null,
  esperaRepartidorMin: ind.rt_wait_time?.average?.value ?? null,
  mostFrequentError: ind.error_metrics_detail?.most_frequent_error ?? null,
  totalOrders: ind.cancellation?.total_orders?.value ?? null,
};

// Ventas (Inicio).
const prime = findBody('indicator/sales/prime') || {};
const sales = {
  totalAmount: prime.total_amount ?? null,
  totalOrders: prime.total_orders ?? null,
  avgTicket: prime.orders_avg ?? null,
  primeAmount: prime.total_amount_prime ?? null,
  primeOrders: prime.total_orders_prime ?? null,
  usersCount: prime.users_count ?? null,
  newUsers: prime.new_users_count ?? null,
  byDay: prime.last_week ?? [],
};

// Órdenes (historial).
const ordersRaw = findBody('orders/by-stores')?.results || [];
let orders = ordersRaw.map((o) => ({
  orderId: o.id ?? '',
  user: (o.application_user_full_name ?? '').trim(),
  store: o.store_name ?? '',
  createdAt: o.created_at ?? null,
  total: o.order_product_total_price ?? null,
  state: o.state_name ?? o.state ?? '',
  paymentMethod: o.payment_method ?? '',
  isDispute: o.is_dispute === true,
}));

// Fusiona con el summary previo si esta corrida no trajo órdenes (evita regresión).
let previous = null;
try {
  previous = JSON.parse(await readFile(`${outDir}summary.json`, 'utf8'));
} catch {
  // sin summary previo
}
if (orders.length === 0 && previous?.orders?.length) orders = previous.orders;

// Menú (por tienda). Preferimos out/menus.json (consulta directa) si existe.
let menus = network
  .filter((r) => r.url.includes('complete-menu') && r.body && typeof r.body === 'object')
  .map((r) => ({
    storeId: r.body.store_id ?? null,
    items: Object.values(r.body.items || {}).map((it) => ({
      id: it.id,
      title: it.title,
      price: it.price,
      isAvailable: it.is_available === true,
      suspendReason: it.suspend_reason ?? null,
    })),
  }));
try {
  const direct = JSON.parse(await readFile(`${outDir}menus.json`, 'utf8'));
  if (Array.isArray(direct) && direct.length > 0) menus = direct;
} catch {
  // sin out/menus.json: usa lo capturado
}

// Catálogo de todas las marcas (si existe).
let brandsCatalog = [];
try {
  const catalog = JSON.parse(await readFile(`${outDir}brands.json`, 'utf8'));
  if (Array.isArray(catalog)) brandsCatalog = catalog;
} catch {
  // sin catálogo
}

const summary = {
  generatedAt: new Date().toISOString(),
  brandId: String(storesRaw[0]?.brand_id ?? '57159').startsWith('PE')
    ? String(storesRaw[0]?.brand_id)
    : `PE${storesRaw[0]?.brand_id ?? '57159'}`,
  brandName: storesRaw[0]?.brand?.name ?? 'Alenkas Bakery',
  counts: { stores: stores.length, orders: orders.length, menus: menus.length },
  brandsCatalog,
  serviceMetrics,
  sales,
  stores,
  orders,
  menus,
};

// Conserva métricas/ventas previas si esta corrida no las trajo.
if ((summary.serviceMetrics?.reclamosPct ?? null) === null && previous?.serviceMetrics) {
  summary.serviceMetrics = previous.serviceMetrics;
}
if ((summary.sales?.totalAmount ?? null) === null && previous?.sales) {
  summary.sales = previous.sales;
}

await writeFile(`${outDir}summary.json`, JSON.stringify(summary, null, 2));

console.log('✅ out/summary.json');
console.log('  Tiendas:', stores.length);
console.log('  Órdenes:', orders.length);
console.log('  Menús:', menus.length);
console.log('  Métricas de servicio:', JSON.stringify(serviceMetrics));
console.log('  Ventas:', JSON.stringify(sales.totalAmount), 'en', sales.totalOrders, 'órdenes');
