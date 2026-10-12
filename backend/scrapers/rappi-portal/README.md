# Puente temporal — Portal Partners de Rappi

**Solo mientras llegan las credenciales oficiales.** Recolecta datos de **tu propia
cuenta** del Portal Partners (SPA con login). No oculta ni evade el anti-bot: si el
portal pide verificación, la resuelves tú manualmente. Se apaga en cuanto llegue la API oficial.

> ⚠️ Uso responsable: es tu cuenta/operación. Automatizar el portal puede ir contra los
> Términos de uso de Rappi. Prioridad: solicitar acceso oficial (Growth/Promotions, Claims,
> Financial) al TAM. Mantén el ritmo bajo y apágalo cuando tengas la API.

## Paso 1 — Capturar sesión + descubrir endpoints
```bash
cd backend/scrapers/rappi-portal
npm install
npx playwright install chromium

TARGET_URL="https://partners.rappi.com/home?from=2026-10-03&to=2026-10-10&brandId=PE57159&storeIds=PE73017,PE73507,PE73506" npm run capture
```
- Chrome visible → **inicia sesión**.
- Navega por **Inicio, Conectividad, Órdenes, Financiero, Menú**.
- ENTER en la terminal.
- Genera: `out/network.json` (APIs internas), `out/page.html`, `out/state.json` (sesión).

## Paso 2 — Recolectar con la sesión guardada
Identifica en `out/network.json` las URLs de API y consúltalas:
```bash
ENDPOINTS="https://partners.rappi.com/api/.../stores,https://partners.rappi.com/api/.../orders" npm run fetch
```
- Guarda `out/results.json`.

## Paso 3 — Conector estable (siguiente)
Con los endpoints identificados construimos un **conector** en el backend que:
- usa la sesión guardada (o un login programático con tus credenciales por env),
- normaliza los datos hacia **Conectividad, Órdenes, Financiero, Promos**,
- se puede **desactivar** con una bandera cuando llegue la API oficial.

## Seguridad
- `out/` está en `.gitignore` (contiene tu sesión y datos). **No subas** `state.json` ni `network.json`.
- Guarda ritmo bajo; una sola sesión; en horarios de baja carga.
