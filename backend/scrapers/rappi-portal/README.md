# Capturador — Portal Partners de Rappi

Herramienta de **captura de sesión** para descubrir las APIs internas que usa el
Portal Partners (`partners.rappi.com`), ya que el portal es una SPA con login y no
expone datos por HTTP directo.

> ⚠️ Uso responsable: es tu propia cuenta/operación. Automatizar el portal puede
> chocar con los Términos de uso de Rappi. Preferible: solicitar acceso oficial
> (API Growth/Promotions, Claims) al TAM. Usa esto solo como puente y bajo tu responsabilidad.

## Uso
```bash
cd backend/scrapers/rappi-portal
npm install
npx playwright install chromium

# Portal de ejemplo (ajusta fechas/brandId/storeIds):
TARGET_URL="https://partners.rappi.com/home?from=2026-10-03&to=2026-10-10&brandId=PE57159&storeIds=PE73017,PE73507" npm run capture
```

1. Se abre Chrome **visible** con el portal.
2. **Inicia sesión** manualmente (tu usuario) y navega a las secciones a capturar
   (Inicio, Conectividad, Órdenes, Financiero, Menú…).
3. Vuelve a la terminal y pulsa **ENTER**.
4. Se guarda:
   - `out/network.json` → todas las respuestas JSON (APIs internas).
   - `out/page.html` → el DOM final.

## Siguiente paso
Con `out/network.json` identificamos los endpoints internos (p. ej. `/api/.../stores`,
`/api/.../orders`) y construimos un **conector estable** (sesión → endpoints) que
alimente el BFF, o bien un scraper de DOM si no hay API.
